import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../core/theme/app_colors.dart';

class CategoryController extends GetxController {
  var categories = <Category>[].obs;
  var selectedType = 'expense'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void setType(String type) {
    selectedType.value = type;
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await DatabaseService.isar.categorys
        .filter()
        .typeEqualTo(selectedType.value)
        .findAll();
    categories.value = data;
  }

  Future<void> addCategory(String name, String iconName) async {
    if (name.trim().isEmpty) return;

    final newCategory = Category()
      ..name = name.trim()
      ..iconName = iconName
      ..type = selectedType.value;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.categorys.put(newCategory);
    });

    loadCategories();
    Get.back();

    Get.snackbar(
      'Berhasil',
      'Kategori baru ditambahkan.',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteCategory(int id) async {
    // PROTEKSI: Cek apakah kategori ini masih dipakai di transaksi
    final linkedTxnCount = await DatabaseService.isar.transactions
        .filter()
        .category((q) => q.idEqualTo(id))
        .count();

    if (linkedTxnCount > 0) {
      Get.snackbar(
        'Penolakan Sistem',
        'Kategori ini sedang digunakan oleh $linkedTxnCount transaksi. Hapus atau ubah transaksi tersebut terlebih dahulu.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return; // Batalkan proses penghapusan
    }

    // Jika aman, lakukan penghapusan
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.categorys.delete(id);
    });

    loadCategories();
  }
}
