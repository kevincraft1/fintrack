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
    const Color(0xFF3B82F6), // Biru - default
    const Color(0xFF10B981), // Hijau Emerald
    const Color(0xFFF59E0B), // Kuning Amber
    const Color(0xFFEF4444), // Merah Red
    const Color(0xFF8B5CF6), // Ungu Violet
    const Color(0xFFEC4899), // Pink
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
    const Color(0xFFA855F7), // Purple
    const Color(0xFF14B8A6), // Teal
  ];
  
  // FIX: Dynamic color generation untuk kategori lebih dari 10
  Color getColorForCategory(String categoryName, int index) {
    if (index < _colorPalette.length) {
      return _colorPalette[index];
    }
    // Generate color berdasarkan hash nama kategori untuk konsistensi
    final hash = categoryName.hashCode;
    return Color((hash & 0x00FFFFFF) | 0xFF000000);
  }

  @override
  void onInit() {
    super.onInit();
    loadStatisticData();
  }

  Future<void> loadStatisticData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(microseconds: 1));

    // INJEKSI ZERO ERROR: Penggunaan dateBetween untuk boundary date yang mutlak
    final transactions = await DatabaseService.isar.transactions
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
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
        } else if (cat.type == 'expense') {
          expense += txn.amount;
          expensesMap[cat.name] = (expensesMap[cat.name] ?? 0) + txn.amount;

          if (!categoryColors.containsKey(cat.name)) {
            final colorIndex = categoryColors.length;
            categoryColors[cat.name] = getColorForCategory(cat.name, colorIndex);
          }
        }
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;

    final sortedExpenses = Map.fromEntries(expensesMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));
    expenseByCategory.assignAll(sortedExpenses);
  }
}
