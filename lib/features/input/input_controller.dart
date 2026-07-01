import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../data/models/wallet.dart';
import '../home/home_controller.dart';
import '../../core/theme/app_colors.dart';

class InputController extends GetxController {
  var amountStr = '0'.obs;
  var categories = <Category>[].obs;
  var selectedType = 'expense'.obs;
  var totalBalance = 0.0.obs;
  var isNoteExpanded = false.obs;
  late TextEditingController noteController;

  var wallets = <Wallet>[].obs;
  var selectedWallet = Rxn<Wallet>();

  @override
  void onInit() {
    super.onInit();
    noteController = TextEditingController();
    loadCategories();
    loadTotalBalance();
    loadWallets();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    final data = await DatabaseService.isar.categorys
        .filter()
        .typeEqualTo(selectedType.value)
        .findAll();
    categories.assignAll(data);
  }

  Future<void> loadWallets() async {
    final data = await DatabaseService.isar.wallets.where().anyId().findAll();
    wallets.assignAll(data);
    if (data.isNotEmpty) {
      selectedWallet.value = data.first;
    }
  }

  Future<void> loadTotalBalance() async {
    final transactions =
        await DatabaseService.isar.transactions.where().anyId().findAll();
    double balance = 0;
    for (var txn in transactions) {
      await txn.category.load();
      if (txn.category.value?.type == 'income') {
        balance += txn.amount;
      } else {
        balance -= txn.amount;
      }
    }
    totalBalance.value = balance;
  }

  void changeType(String type) {
    selectedType.value = type;
    loadCategories();
  }

  String get formattedAmount {
    if (amountStr.value == '0') return 'Rp 0';
    final number = int.tryParse(amountStr.value) ?? 0;
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  String get formattedBalance {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(totalBalance.value);
  }

  void addDigit(String digit) {
    if (amountStr.value == '0' && digit != '0') {
      amountStr.value = digit;
    } else if (amountStr.value != '0' && amountStr.value.length < 12) {
      amountStr.value += digit;
    }
  }

  void removeDigit() {
    if (amountStr.value.length > 1) {
      amountStr.value =
          amountStr.value.substring(0, amountStr.value.length - 1);
    } else {
      amountStr.value = '0';
    }
  }

  Future<void> saveTransaction(String categoryName) async {
    final rawAmount = double.tryParse(amountStr.value) ?? 0;
    if (rawAmount == 0) return;

    if (selectedWallet.value == null) {
      Get.snackbar(
          'Penolakan Sistem', 'Pilih sumber dana/dompet terlebih dahulu.',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    final category = await DatabaseService.isar.categorys
        .filter()
        .nameEqualTo(categoryName)
        .typeEqualTo(selectedType.value)
        .findFirst();

    if (category != null) {
      final newTxn = Transaction()
        ..amount = rawAmount
        ..date = DateTime.now()
        ..note = noteController.text.trim()
        ..category.value = category
        ..wallet.value = selectedWallet.value;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactions.put(newTxn);
        await newTxn.category.save();
        await newTxn.wallet.save();
      });

      loadTotalBalance();

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadHomeData();
      }

      Get.snackbar(
        'Tersimpan!',
        '${selectedType.value == 'income' ? 'Pemasukan' : 'Pengeluaran'} $categoryName berhasil dicatat.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: selectedType.value == 'income'
            ? AppColors.primary
            : AppColors.error,
        colorText: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      );

      amountStr.value = '0';
      noteController.clear();
      isNoteExpanded.value = false;
    }
  }
}
