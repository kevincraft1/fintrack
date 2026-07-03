import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/debt.dart';

class DebtController extends GetxController {
  var lentList = <Debt>[].obs; // Piutang (Uang kita di orang)
  var borrowedList = <Debt>[].obs; // Hutang (Kita pinjam uang)

  // Controller Form
  var nameController = TextEditingController();
  var amountController = TextEditingController();
  var noteController = TextEditingController();
  var selectedType = 'lend'.obs;
  var selectedDueDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  Future<void> loadDebts() async {
    final debts =
        await DatabaseService.isar.debts.where().sortByDueDate().findAll();
    lentList.assignAll(debts.where((d) => d.type == 'lend').toList());
    borrowedList.assignAll(debts.where((d) => d.type == 'borrow').toList());
  }

  void pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedDueDate.value = picked;
    }
  }

  Future<void> saveDebt() async {
    final parsedAmount = double.tryParse(amountController.text) ?? 0.0;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (parsedAmount <= 0) {
      Get.snackbar('Error', 'Nominal tidak valid',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedDueDate.value == null) {
      Get.snackbar('Error', 'Pilih tanggal jatuh tempo',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newDebt = Debt()
      ..personName = nameController.text.trim()
      ..totalAmount = parsedAmount
      ..remainingAmount = parsedAmount
      ..type = selectedType.value
      ..dueDate = selectedDueDate.value!
      ..createdAt = DateTime.now()
      ..note = noteController.text
      ..isSettled = false;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.debts.put(newDebt);
    });

    _clearForm();
    Get.back();
    loadDebts();
    Get.snackbar('Sukses', 'Catatan berhasil ditambahkan',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> toggleSettle(int id, bool currentStatus) async {
    final debt = await DatabaseService.isar.debts.get(id);
    if (debt != null) {
      await DatabaseService.isar.writeTxn(() async {
        debt.isSettled = !currentStatus;
        await DatabaseService.isar.debts.put(debt);
      });
      loadDebts();
    }
  }

  Future<void> deleteDebt(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.debts.delete(id);
    });
    loadDebts();
  }

  void _clearForm() {
    nameController.clear();
    amountController.clear();
    noteController.clear();
    selectedDueDate.value = null;
    selectedType.value = 'lend';
  }
}
