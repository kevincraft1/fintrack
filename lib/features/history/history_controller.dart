import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../core/theme/app_colors.dart';
import 'package:isar/isar.dart';

class HistoryController extends GetxController {
  var transactions = <Transaction>[].obs;
  var categories = <Category>[].obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var searchQuery = ''.obs;

  late TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    fetchTransactions();
    fetchCategories();

    debounce(searchQuery, (_) => fetchTransactions(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    final data = await DatabaseService.isar.categorys.where().anyId().findAll();
    categories.assignAll(data);
  }

  Future<void> fetchTransactions() async {
    final start = DateTime(selectedYear.value, selectedMonth.value, 1);
    final end = DateTime(selectedYear.value, selectedMonth.value + 1, 1)
        .subtract(const Duration(microseconds: 1));

    final data = await DatabaseService.isar.transactions
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();

    for (var txn in data) {
      await txn.category.load();
    }

    if (searchQuery.value.isEmpty) {
      transactions.assignAll(data);
    } else {
      final term = searchQuery.value.toLowerCase();
      final filteredData = data.where((txn) {
        final catName = txn.category.value?.name.toLowerCase() ?? '';
        final note = txn.note?.toLowerCase() ?? '';
        final amountStr = txn.amount.toInt().toString();

        return catName.contains(term) ||
            note.contains(term) ||
            amountStr.contains(term);
      }).toList();

      transactions.assignAll(filteredData);
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.transactions.delete(id);
    });
    fetchTransactions();

    Get.snackbar(
      'Terhapus',
      'Transaksi berhasil dihapus dari catatan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.textPrimary,
    );
  }

  Future<void> updateTransaction(
      int id, double newAmount, Category newCategory) async {
    final txn = await DatabaseService.isar.transactions.get(id);
    if (txn != null) {
      txn.amount = newAmount;
      txn.category.value = newCategory;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactions.put(txn);
        await txn.category.save();
      });

      fetchTransactions();
      Get.back();

      Get.snackbar(
        'Diperbarui',
        'Data transaksi berhasil diubah.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: AppColors.textPrimary,
      );
    }
  }

  void changePeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    fetchTransactions();
  }
}
