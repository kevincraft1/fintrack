import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/debt.dart';
import '../../data/models/wallet.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../home/home_controller.dart';

class DebtController extends GetxController {
  var debts = <Debt>[].obs;
  var nameController = TextEditingController();
  var amountController = TextEditingController();
  var payAmountController = TextEditingController();

  var selectedType = 'debt'.obs;
  var selectedDueDate = Rxn<DateTime>();
  var selectedWallet = Rxn<Wallet>();
  var wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    amountController.dispose();
    payAmountController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    final data = await DatabaseService.isar.wallets.where().findAll();
    wallets.assignAll(data);
    if (wallets.isNotEmpty) {
      selectedWallet.value = wallets.first;
    }
    await loadDebts();
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
    if (picked != null) {
      selectedDueDate.value = picked;
    }
  }

  Future<Category> _getOrCreateSystemCategory(
      String typeName, String type) async {
    final isar = DatabaseService.isar;
    var cat = await isar.categorys.filter().nameEqualTo(typeName).findFirst();
    if (cat == null) {
      cat = Category()
        ..name = typeName
        ..iconName = 'account_balance'
        ..type = type
        ..colorHex = '#6B7280';
      await isar.categorys.put(cat);
    }
    return cat;
  }

  Future<void> saveDebt() async {
    final amountValue = double.tryParse(amountController.text) ?? 0.0;
    if (nameController.text.trim().isEmpty ||
        amountValue <= 0 ||
        selectedDueDate.value == null ||
        selectedWallet.value == null) {
      Get.snackbar('Error', 'Lengkapi seluruh data input',
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

    final isar = DatabaseService.isar;

    await isar.writeTxn(() async {
      newDebt.wallet.value = selectedWallet.value;
      await isar.debts.put(newDebt);
      await newDebt.wallet.save();

      final wallet = selectedWallet.value!;
      final txn = Transaction()
        ..amount = amountValue
        ..date = DateTime.now()
        ..note = 'Pencatatan awal: ${newDebt.personName}';

      txn.wallet.value = wallet;
      txn.debt.value = newDebt;

      if (selectedType.value == 'debt') {
        wallet.balance += amountValue;
        txn.category.value =
            await _getOrCreateSystemCategory('Pinjaman Diterima', 'debt_in');
      } else {
        wallet.balance -= amountValue;
        txn.category.value =
            await _getOrCreateSystemCategory('Memberi Pinjaman', 'debt_out');
      }

      await isar.wallets.put(wallet);
      await isar.transactions.put(txn);
      await txn.category.save();
      await txn.wallet.save();
      await txn.debt.save();
    });

    nameController.clear();
    amountController.clear();
    selectedDueDate.value = null;
    selectedType.value = 'debt';

    Get.back();
    loadDebts();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadHomeData();
    }

    Get.snackbar('Sukses', 'Data dicatat & arus kas disesuaikan',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> payDebt(Debt debt) async {
    final payValue = double.tryParse(payAmountController.text) ?? 0.0;
    if (payValue <= 0 ||
        payValue > debt.remainingAmount ||
        selectedWallet.value == null) {
      Get.snackbar('Error', 'Nominal tidak valid',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final isar = DatabaseService.isar;

    await isar.writeTxn(() async {
      debt.remainingAmount -= payValue;
      if (debt.remainingAmount <= 0) {
        debt.isSettled = true;
      }
      await isar.debts.put(debt);

      final wallet = selectedWallet.value!;
      final txn = Transaction()
        ..amount = payValue
        ..date = DateTime.now()
        ..note = 'Cicilan/Pelunasan: ${debt.personName}';

      txn.wallet.value = wallet;
      txn.debt.value = debt;

      if (debt.type == 'debt') {
        wallet.balance -= payValue;
        txn.category.value =
            await _getOrCreateSystemCategory('Bayar Hutang', 'debt_pay');
      } else {
        wallet.balance += payValue;
        txn.category.value =
            await _getOrCreateSystemCategory('Terima Piutang', 'debt_collect');
      }

      await isar.wallets.put(wallet);
      await isar.transactions.put(txn);
      await txn.category.save();
      await txn.wallet.save();
      await txn.debt.save();
    });

    payAmountController.clear();
    Get.back();
    loadDebts();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadHomeData();
    }

    Get.snackbar('Sukses', 'Pembayaran berhasil dicatat',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> deleteDebt(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.debts.delete(id);
    });
    loadDebts();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadHomeData();
    }
  }
}
