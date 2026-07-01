import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../core/theme/app_colors.dart';

class BudgetData {
  final Budget budget;
  final double spentAmount;

  BudgetData(this.budget, this.spentAmount);
}

class BudgetController extends GetxController {
  var budgets = <BudgetData>[].obs;
  var expenseCategories = <Category>[].obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  late TextEditingController limitController;

  @override
  void onInit() {
    super.onInit();
    limitController = TextEditingController();
    loadExpenseCategories();
    loadBudgets();
  }

  @override
  void onClose() {
    limitController.dispose();
    super.onClose();
  }

  Future<void> loadExpenseCategories() async {
    final data = await DatabaseService.isar.categorys
        .filter()
        .typeEqualTo('expense')
        .findAll();
    expenseCategories.assignAll(data);
  }

  Future<void> loadBudgets() async {
    final budgetDataList = <BudgetData>[];
    final rawBudgets = await DatabaseService.isar.budgets
        .filter()
        .monthEqualTo(selectedMonth.value)
        .yearEqualTo(selectedYear.value)
        .findAll();

    final start = DateTime(selectedYear.value, selectedMonth.value, 1);
    final end = DateTime(selectedYear.value, selectedMonth.value + 1, 1)
        .subtract(const Duration(microseconds: 1));

    for (var b in rawBudgets) {
      await b.category.load();
      final catId = b.category.value?.id;

      double spent = 0.0;
      if (catId != null) {
        final txns = await DatabaseService.isar.transactions
            .filter()
            .dateBetween(start, end)
            .category((q) => q.idEqualTo(catId))
            .findAll();
        for (var txn in txns) {
          spent += txn.amount;
        }
      }
      budgetDataList.add(BudgetData(b, spent));
    }
    budgets.assignAll(budgetDataList);
  }

  void changePeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadBudgets();
  }

  Future<void> saveBudget(Category category, double limit) async {
    final existing = await DatabaseService.isar.budgets
        .filter()
        .monthEqualTo(selectedMonth.value)
        .yearEqualTo(selectedYear.value)
        .category((q) => q.idEqualTo(category.id))
        .findFirst();

    if (existing != null) {
      existing.limitAmount = limit;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.budgets.put(existing);
        await existing.category.save();
      });
    } else {
      final newBudget = Budget()
        ..limitAmount = limit
        ..month = selectedMonth.value
        ..year = selectedYear.value
        ..category.value = category;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.budgets.put(newBudget);
        await newBudget.category.save();
      });
    }

    loadBudgets();
    limitController.clear();
    Get.back();
    Get.snackbar('Berhasil', 'Target anggaran disimpan.',
        backgroundColor: AppColors.primary, colorText: Colors.white);
  }

  Future<void> deleteBudget(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.budgets.delete(id);
    });
    loadBudgets();
  }
}
