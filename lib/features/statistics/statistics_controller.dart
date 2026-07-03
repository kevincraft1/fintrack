import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';

class StatisticsController extends GetxController {
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var expenseByCategory = <String, double>{}.obs;
  var categoryColors = <String, Color>{}.obs;

  final List<Color> _colorPalette = [
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  @override
  void onInit() {
    super.onInit();
    loadStatisticData();
  }

  Future<void> loadStatisticData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final transactions = await DatabaseService.isar.transactions
        .filter()
        .dateGreaterThan(startOfMonth)
        .findAll();

    double income = 0.0;
    double expense = 0.0;
    Map<String, double> expensesMap = {};
    int colorIndex = 0;

    for (var txn in transactions) {
      await txn.category.load();
      final cat = txn.category.value;

      if (cat != null) {
        if (cat.type == 'income') {
          income += txn.amount;
        } else {
          expense += txn.amount;
          expensesMap[cat.name] = (expensesMap[cat.name] ?? 0) + txn.amount;

          if (!categoryColors.containsKey(cat.name)) {
            categoryColors[cat.name] =
                _colorPalette[colorIndex % _colorPalette.length];
            colorIndex++;
          }
        }
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;

    // Sort expenses by amount descending
    final sortedExpenses = Map.fromEntries(expensesMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));
    expenseByCategory.assignAll(sortedExpenses);
  }
}
