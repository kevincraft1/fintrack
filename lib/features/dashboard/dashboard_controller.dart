import 'package:get/get.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import 'package:isar/isar.dart';

class DashboardController extends GetxController {
  var chartData = <Map<String, dynamic>>[].obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final start = DateTime(selectedYear.value, selectedMonth.value, 1);
    final end = DateTime(selectedYear.value, selectedMonth.value + 1, 1)
        .subtract(const Duration(microseconds: 1));

    final data = await DatabaseService.isar.transactions
        .filter()
        .dateBetween(start, end)
        .findAll();

    Map<String, double> tempMap = {};
    double tempTotal = 0;

    for (var txn in data) {
      await txn.category.load();
      final name = txn.category.value?.name ?? 'Lainnya';
      tempMap[name] = (tempMap[name] ?? 0) + txn.amount;
      tempTotal += txn.amount;
    }

    chartData.value = tempMap.entries
        .map((e) => {'category': e.key, 'amount': e.value})
        .toList();

    totalAmount.value = tempTotal;
  }

  void changePeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadDashboardData();
  }
}
