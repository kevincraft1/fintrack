import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../data/models/wallet.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';

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
      await txn.wallet.load();
      await txn.toWallet.load();
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
    final isar = DatabaseService.isar;
    final txn = await isar.transactions.get(id);

    if (txn != null) {
      await txn.category.load();
      await txn.wallet.load();
      await txn.toWallet.load();

      final type = txn.category.value?.type;
      final amount = txn.amount;
      final wallet = txn.wallet.value;

      await isar.writeTxn(() async {
        if (wallet != null) {
          if (type == 'income') {
            wallet.balance -= amount;
          } else if (type == 'expense') {
            wallet.balance += amount;
          } else if (type == 'transfer') {
            wallet.balance += amount;
            final toWallet = txn.toWallet.value;
            if (toWallet != null) {
              toWallet.balance -= amount;
              await isar.wallets.put(toWallet);
            }
          }
          await isar.wallets.put(wallet);
        }
        await isar.transactions.delete(id);
      });

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }

      fetchTransactions();

      Get.snackbar(
        'Terhapus',
        'Transaksi dihapus dan saldo dompet telah dikembalikan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textPrimary,
      );
    }
  }

  Future<void> updateTransaction(
      int id, double newAmount, Category newCategory) async {
    final isar = DatabaseService.isar;
    final txn = await isar.transactions.get(id);

    if (txn != null) {
      await txn.category.load();
      await txn.wallet.load();

      final oldAmount = txn.amount;
      final oldType = txn.category.value?.type;
      final newType = newCategory.type;
      final wallet = txn.wallet.value;

      if (oldType == 'transfer' || newType == 'transfer') {
        Get.snackbar(
          'Ditolak',
          'Edit transaksi transfer belum didukung. Harap hapus dan buat ulang.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      await isar.writeTxn(() async {
        if (wallet != null) {
          if (oldType == 'income') {
            wallet.balance -= oldAmount;
          } else if (oldType == 'expense') {
            wallet.balance += oldAmount;
          }

          if (newType == 'income') {
            wallet.balance += newAmount;
          } else if (newType == 'expense') {
            wallet.balance -= newAmount;
          }
          await isar.wallets.put(wallet);
        }

        txn.amount = newAmount;
        txn.category.value = newCategory;
        await isar.transactions.put(txn);
        await txn.category.save();
      });

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }

      fetchTransactions();
      Get.back();

      Get.snackbar(
        'Diperbarui',
        'Data transaksi dan kalkulasi saldo berhasil diubah.',
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
