import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';

class ProfileController extends GetxController {
  var lifetimeIncome = 0.0.obs;
  var lifetimeExpense = 0.0.obs;
  var totalTransactionsCount = 0.obs;
  var financialHealth = 'Stabil'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileStats();
  }

  Future<void> loadProfileStats() async {
    final allTxns =
        await DatabaseService.isar.transactions.where().anyId().findAll();

    double tIncome = 0;
    double tExpense = 0;

    for (var txn in allTxns) {
      await txn.category.load();
      if (txn.category.value?.type == 'income') {
        tIncome += txn.amount;
      } else {
        tExpense += txn.amount;
      }
    }

    lifetimeIncome.value = tIncome;
    lifetimeExpense.value = tExpense;
    totalTransactionsCount.value = allTxns.length;

    if (tIncome == 0 && tExpense == 0) {
      financialHealth.value = 'Baru Memulai';
    } else if (tIncome == 0 && tExpense > 0) {
      financialHealth.value = 'Kritis';
    } else {
      final ratio = tExpense / tIncome;
      if (ratio <= 0.5) {
        financialHealth.value = 'Sangat Sehat';
      } else if (ratio <= 0.8) {
        financialHealth.value = 'Stabil';
      } else {
        financialHealth.value = 'Boros';
      }
    }
  }

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
}
