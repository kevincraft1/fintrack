import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/debt.dart';

class DebtController extends GetxController {
  var debts = <Debt>[].obs;
  var nameController = TextEditingController();
  var amountController = TextEditingController();
  var selectedType = 'debt'.obs;
  var selectedDueDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  Future<void> loadDebts() async {
    final data = await DatabaseService.isar.debts.where().findAll();
    debts.assignAll(data);
  }

  void pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) selectedDueDate.value = picked;
  }

  Future<void> saveDebt() async {
    final amountValue = double.tryParse(amountController.text) ?? 0.0;
    if (nameController.text.trim().isEmpty ||
        amountValue <= 0 ||
        selectedDueDate.value == null) {
      Get.snackbar('Error', 'Lengkapi semua data dengan benar',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newDebt = Debt()
      ..personName = nameController.text.trim()
      ..totalAmount = amountValue
      ..remainingAmount = amountValue
      ..type = selectedType.value
      ..dueDate = selectedDueDate.value!
      ..isSettled = false
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.debts.put(newDebt);
    });

    nameController.clear();
    amountController.clear();
    selectedDueDate.value = null;
    selectedType.value = 'debt';

    Get.back();
    loadDebts();
    Get.snackbar('Sukses', 'Catatan berhasil ditambahkan',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> toggleDebtStatus(Debt debt) async {
    await DatabaseService.isar.writeTxn(() async {
      debt.isSettled = !debt.isSettled;
      await DatabaseService.isar.debts.put(debt);
    });
    loadDebts();
  }

  Future<void> deleteDebt(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.debts.delete(id);
    });
    loadDebts();
  }
}
