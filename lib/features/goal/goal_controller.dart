import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/goal.dart';
import '../../data/models/wallet.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../home/home_controller.dart';
import '../history/history_controller.dart';

class GoalController extends GetxController {
  var goals = <Goal>[].obs;
  var wallets = <Wallet>[].obs;

  var nameController = TextEditingController();
  var targetController = TextEditingController();
  var selectedDeadline = Rxn<DateTime>();

  var topUpController = TextEditingController();
  var selectedWallet = Rxn<Wallet>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final g =
        await DatabaseService.isar.goals.where().sortByDeadline().findAll();
    goals.assignAll(g);

    final w = await DatabaseService.isar.wallets.where().findAll();
    wallets.assignAll(w);
    if (w.isNotEmpty) selectedWallet.value = w.first;
  }

  void pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) selectedDeadline.value = picked;
  }

  Future<void> saveGoal() async {
    final target = double.tryParse(targetController.text) ?? 0.0;
    if (nameController.text.trim().isEmpty ||
        target <= 0 ||
        selectedDeadline.value == null) {
      Get.snackbar('Error', 'Lengkapi semua data dengan benar',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newGoal = Goal()
      ..name = nameController.text.trim()
      ..targetAmount = target
      ..savedAmount = 0.0
      ..deadline = selectedDeadline.value!
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.goals.put(newGoal);
    });

    nameController.clear();
    targetController.clear();
    selectedDeadline.value = null;
    Get.back();
    loadData();
    Get.snackbar('Sukses', 'Target impian berhasil dibuat!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> topUpGoal(Goal goal) async {
    final amount = double.tryParse(topUpController.text) ?? 0.0;
    if (amount <= 0 || selectedWallet.value == null) {
      Get.snackbar('Error', 'Nominal atau dompet tidak valid',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedWallet.value!.balance < amount) {
      Get.snackbar('Gagal', 'Saldo dompet tidak mencukupi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final isar = DatabaseService.isar;

    try {
      await isar.writeTxn(() async {
        // 1. Tambah saldo impian
        goal.savedAmount += amount;
        await isar.goals.put(goal);

        // 2. Potong saldo dompet
        final wallet = selectedWallet.value!;
        wallet.balance -= amount;
        await isar.wallets.put(wallet);

        // 3. INJEKSI AKUNTANSI ZERO ERROR: Catat sebagai transaksi pengeluaran
        var goalCat = await isar.categorys
            .filter()
            .nameEqualTo('Tabungan Impian')
            .findFirst();

        if (goalCat == null) {
          goalCat = Category()
            ..name = 'Tabungan Impian'
            ..iconName = 'star'
            ..type = 'expense'
            ..colorHex = '#F59E0B';
          await isar.categorys.put(goalCat);
        }

        final txn = Transaction()
          ..amount = amount
          ..date = DateTime.now()
          ..note = 'Top Up: ${goal.name}'
          ..category.value = goalCat
          ..wallet.value = wallet;

        await isar.transactions.put(txn);
        await txn.category.save();
        await txn.wallet.save();
      });

      // Pemicu penyegaran data mutlak di layer lain
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().fetchTransactions();
      }

      topUpController.clear();
      Get.back();
      loadData();
      Get.snackbar('Sukses', 'Tabungan tercatat di riwayat pengeluaran!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Sistem Error', 'Gagal memproses transaksi tabungan',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> deleteGoal(int id) async {
    // Catatan: Jika impian dihapus, apakah uangnya kembali ke dompet?
    // Untuk efisiensi versi 1.0.0, kita biarkan hanya hapus goal-nya saja
    // karena riwayat pengeluarannya sudah sah tercatat.
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.goals.delete(id);
    });
    loadData();
  }
}
