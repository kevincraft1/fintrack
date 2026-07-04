import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../data/models/wallet.dart';

class InputController extends GetxController {
  var amount = '0'.obs;
  var noteController = TextEditingController();

  var selectedType = 'expense'.obs;

  var selectedCategory = Rxn<Category>();
  var selectedWallet = Rxn<Wallet>();
  var selectedToWallet = Rxn<Wallet>();

  var categories = <Category>[].obs;
  var wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  String get formattedAmount {
    if (amount.value == '0' || amount.value.isEmpty) return '0';
    final number = int.tryParse(amount.value) ?? 0;
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  Future<void> loadInitialData() async {
    wallets.value = await DatabaseService.isar.wallets.where().findAll();
    if (wallets.isNotEmpty) {
      selectedWallet.value = wallets.first;
      if (wallets.length > 1) {
        selectedToWallet.value = wallets[1];
      } else {
        selectedToWallet.value = wallets.first;
      }
    }
    await loadCategories();
  }

  Future<void> loadCategories() async {
    if (selectedType.value == 'transfer') {
      categories.clear();
      selectedCategory.value = null;
      return;
    }

    categories.value = await DatabaseService.isar.categorys
        .filter()
        .typeEqualTo(selectedType.value)
        .findAll();

    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    } else {
      selectedCategory.value = null;
    }
  }

  void changeType(String type) {
    selectedType.value = type;
    loadCategories();
  }

  void addDigit(String num) {
    if (amount.value.length >= 15) return;

    if (amount.value == '0') {
      amount.value = num;
    } else {
      amount.value += num;
    }
  }

  void removeDigit() {
    if (amount.value.length > 1) {
      amount.value = amount.value.substring(0, amount.value.length - 1);
    } else {
      amount.value = '0';
    }
  }

  Future<void> saveTransaction() async {
    final parsedAmount = double.tryParse(amount.value) ?? 0.0;
    if (parsedAmount <= 0) {
      Get.snackbar('Error', 'Nominal tidak boleh 0',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedType.value != 'transfer' && selectedCategory.value == null) {
      Get.snackbar('Error', 'Pilih kategori terlebih dahulu',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedWallet.value == null) {
      Get.snackbar('Error', 'Pilih dompet terlebih dahulu',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedType.value == 'transfer' && selectedToWallet.value == null) {
      Get.snackbar('Error', 'Pilih dompet tujuan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedType.value == 'transfer' &&
        selectedWallet.value?.id == selectedToWallet.value?.id) {
      Get.snackbar('Error', 'Dompet asal dan tujuan tidak boleh sama',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final txn = Transaction()
      ..amount = parsedAmount
      ..date = DateTime.now()
      ..note = noteController.text;

    final isar = DatabaseService.isar;

    try {
      await isar.writeTxn(() async {
        if (selectedType.value == 'transfer') {
          txn.wallet.value = selectedWallet.value;
          txn.toWallet.value = selectedToWallet.value;

          var transferCat = await isar.categorys
              .filter()
              .nameEqualTo('Transfer Internal')
              .findFirst();

          if (transferCat == null) {
            transferCat = Category()
              ..name = 'Transfer Internal'
              ..iconName = 'swap_horiz'
              ..type = 'transfer'
              ..colorHex = '#3B82F6';
            await isar.categorys.put(transferCat);
          }
          txn.category.value = transferCat;

          final fromWallet = selectedWallet.value!;
          fromWallet.balance -= parsedAmount;
          await isar.wallets.put(fromWallet);

          final toWallet = selectedToWallet.value!;
          toWallet.balance += parsedAmount;
          await isar.wallets.put(toWallet);
        } else {
          txn.category.value = selectedCategory.value;
          txn.wallet.value = selectedWallet.value;

          final wallet = selectedWallet.value!;
          if (selectedType.value == 'income') {
            wallet.balance += parsedAmount;
          } else {
            wallet.balance -= parsedAmount;
          }
          await isar.wallets.put(wallet);
        }

        await isar.transactions.put(txn);
        await txn.category.save();
        await txn.wallet.save();
        if (selectedType.value == 'transfer') {
          await txn.toWallet.save();
        }
      });

      Get.back(result: true);
      Get.snackbar('Sukses', 'Transaksi berhasil dicatat',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Sistem Error', 'Terjadi kesalahan saat menyimpan data',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
