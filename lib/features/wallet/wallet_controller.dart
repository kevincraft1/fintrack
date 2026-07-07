import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/wallet.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';

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

  Future<Category> _getOrCreateInitialCategory() async {
    final isar = DatabaseService.isar;
    var cat = await isar.categorys
        .filter()
        .nameEqualTo('Penyesuaian Saldo')
        .findFirst();
    if (cat == null) {
      cat = Category()
        ..name = 'Penyesuaian Saldo'
        ..iconName = 'account_balance_wallet'
        ..type = 'income'
        ..colorHex = '#10B981';
      await isar.categorys.put(cat);
    }
    return cat;
  }

  Future<void> addWallet(
      String name, String iconName, double initialBalance) async {
    if (name.trim().isEmpty) return;

    final newWallet = Wallet()
      ..name = name.trim()
      ..iconName = iconName
      ..initialBalance = initialBalance
      ..balance = initialBalance;

    final isar = DatabaseService.isar;

    try {
      await isar.writeTxn(() async {
        await isar.wallets.put(newWallet);

        if (initialBalance > 0) {
          final cat = await _getOrCreateInitialCategory();
          final txn = Transaction()
            ..amount = initialBalance
            ..date = DateTime.now()
            ..note = 'Saldo Awal Dompet: ${name.trim()}';

          txn.wallet.value = newWallet;
          txn.category.value = cat;

          await isar.transactions.put(txn);
          await txn.wallet.save();
          await txn.category.save();
        }
      });

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }

      loadWallets();
      Get.back();

      Get.snackbar(
        'Berhasil',
        'Dompet baru ditambahkan dan saldo diperbarui.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Sistem Error', 'Gagal menyimpan dompet',
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> deleteWallet(int id) async {
    final isar = DatabaseService.isar;

    final linkedAsSource =
        await isar.transactions.filter().wallet((q) => q.idEqualTo(id)).count();

    final linkedAsTarget = await isar.transactions
        .filter()
        .toWallet((q) => q.idEqualTo(id))
        .count();

    final totalLinked = linkedAsSource + linkedAsTarget;

    if (totalLinked > 0) {
      Get.snackbar(
        'Penolakan Sistem',
        'Dompet ini sedang tertaut dengan $totalLinked riwayat transaksi.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final count = await isar.wallets.count();
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

    try {
      await isar.writeTxn(() async {
        await isar.wallets.delete(id);
      });

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }

      loadWallets();
    } catch (e) {
      Get.snackbar('Sistem Error', 'Gagal menghapus dompet',
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }
}
