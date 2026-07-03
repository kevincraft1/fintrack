import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/goal.dart';
import '../../data/models/wallet.dart';

class GoalController extends GetxController {
  var goals = <Goal>[].obs;
  var wallets = <Wallet>[].obs;

  // Form Tambah Target
  var nameController = TextEditingController();
  var targetController = TextEditingController();
  var selectedDeadline = Rxn<DateTime>();

  // Form Top-Up
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

    await DatabaseService.isar.writeTxn(() async {
      // Tambah saldo impian
      goal.savedAmount += amount;
      await DatabaseService.isar.goals.put(goal);

      // Potong saldo dompet
      final wallet = selectedWallet.value!;
      wallet.balance -= amount;
      await DatabaseService.isar.wallets.put(wallet);
    });

    topUpController.clear();
    Get.back();
    loadData();
    Get.snackbar('Sukses', 'Berhasil menabung untuk impianmu!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.goals.delete(id);
    });
    loadData();
  }
}
