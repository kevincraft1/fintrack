import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/wallet.dart';

class HomeController extends GetxController {
  var totalBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var recentTransactions = <Transaction>[].obs;
  var wallets = <Wallet>[].obs;
  var walletBalances = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final allTxn =
        await DatabaseService.isar.transactions.where().anyId().findAll();
    allTxn.sort((a, b) => b.date.compareTo(a.date));

    final allWallets =
        await DatabaseService.isar.wallets.where().anyId().findAll();

    double balance = 0.0;
    double income = 0.0;
    double expense = 0.0;
    Map<int, double> wBalances = {};

    for (var w in allWallets) {
      wBalances[w.id] = w.balance;
      balance += w.balance;
    }

    final monthlyTxn = allTxn.where((t) =>
        t.date.isAfter(startOfMonth) || t.date.isAtSameMomentAs(startOfMonth));

    for (var txn in monthlyTxn) {
      await txn.category.load();
      final type = txn.category.value?.type;

      if (type == 'income') {
        income += txn.amount;
      } else if (type == 'expense') {
        expense += txn.amount;
      }
    }

    // Melakukan load IsarLink mutlak khusus untuk UI Recent Transactions
    final recent = allTxn.take(5).toList();
    for (var txn in recent) {
      await txn.category.load();
      await txn.wallet.load();
      await txn.toWallet.load();
    }

    wallets.assignAll(allWallets);
    walletBalances.assignAll(wBalances);
    totalBalance.value = balance;
    totalIncome.value = income;
    totalExpense.value = expense;
    recentTransactions.assignAll(recent);
  }
}
