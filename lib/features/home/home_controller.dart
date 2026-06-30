import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';

class HomeController extends GetxController {
  var totalBalance = 0.0.obs;
  var monthlyIncome = 0.0.obs;
  var monthlyExpense = 0.0.obs;
  var recentTransactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(microseconds: 1));

    final allTransactions =
        await DatabaseService.isar.transactions.where().anyId().findAll();

    double balance = 0;
    double mIncome = 0;
    double mExpense = 0;

    for (var txn in allTransactions) {
      await txn.category.load();
      final isIncome = txn.category.value?.type == 'income';

      if (isIncome) {
        balance += txn.amount;
      } else {
        balance -= txn.amount;
      }

      if (txn.date.isAfter(startOfMonth) && txn.date.isBefore(endOfMonth)) {
        if (isIncome) {
          mIncome += txn.amount;
        } else {
          mExpense += txn.amount;
        }
      }
    }

    totalBalance.value = balance;
    monthlyIncome.value = mIncome;
    monthlyExpense.value = mExpense;

    final recent = await DatabaseService.isar.transactions
        .where()
        .anyId()
        .sortByDateDesc()
        .limit(5)
        .findAll();

    for (var txn in recent) {
      await txn.category.load();
    }

    recentTransactions.assignAll(recent);
  }

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
}
