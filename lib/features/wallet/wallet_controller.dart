import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/wallet.dart';
import '../../data/models/transaction.dart';
import '../../core/theme/app_colors.dart';

class WalletController extends GetxController {
  var wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    final data = await DatabaseService.isar.wallets.where().anyId().findAll();
    wallets.assignAll(data);
  }

  Future<void> addWallet(
      String name, String iconName, double initialBalance) async {
    if (name.trim().isEmpty) return;

    final newWallet = Wallet()
      ..name = name.trim()
      ..iconName = iconName
      ..initialBalance = initialBalance;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.wallets.put(newWallet);
    });

    loadWallets();
    Get.back();

    Get.snackbar(
      'Berhasil',
      'Dompet baru ditambahkan.',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteWallet(int id) async {
    final linkedTxnCount = await DatabaseService.isar.transactions
        .filter()
        .wallet((q) => q.idEqualTo(id))
        .count();

    if (linkedTxnCount > 0) {
      Get.snackbar(
        'Penolakan Sistem',
        'Dompet ini sedang digunakan oleh $linkedTxnCount transaksi.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final count = await DatabaseService.isar.wallets.count();
    if (count <= 1) {
      Get.snackbar(
        'Penolakan Sistem',
        'Anda harus memiliki setidaknya satu dompet aktif.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.wallets.delete(id);
    });

    loadWallets();
  }
}
