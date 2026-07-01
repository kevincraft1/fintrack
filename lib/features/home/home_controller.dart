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

    final allTxn = await DatabaseService.isar.transactions
        .where()
        .sortByDateDesc()
        .findAll();
    final allWallets = await DatabaseService.isar.wallets.where().findAll();

    double balance = 0.0;
    double income = 0.0;
    double expense = 0.0;
    Map<int, double> wBalances = {};

    for (var w in allWallets) {
      wBalances[w.id] = w.initialBalance;
      balance += w.initialBalance;
    }

    for (var txn in allTxn) {
      await txn.category.load();
      await txn.wallet.load();

      final isIncome = txn.category.value?.type == 'income';
      final amount = txn.amount;
      final walletId = txn.wallet.value?.id;

      if (isIncome) {
        balance += amount;
        if (walletId != null && wBalances.containsKey(walletId)) {
          wBalances[walletId] = wBalances[walletId]! + amount;
        }
      } else {
        balance -= amount;
        if (walletId != null && wBalances.containsKey(walletId)) {
          wBalances[walletId] = wBalances[walletId]! - amount;
        }
      }

      if (txn.date.isAfter(startOfMonth) ||
          txn.date.isAtSameMomentAs(startOfMonth)) {
        if (isIncome) {
          income += amount;
        } else {
          expense += amount;
        }
      }
    }

    wallets.assignAll(allWallets);
    walletBalances.assignAll(wBalances);
    totalBalance.value = balance;
    totalIncome.value = income;
    totalExpense.value = expense;
    recentTransactions.assignAll(allTxn.take(5).toList());
  }
}
