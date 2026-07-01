import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'budget_controller.dart';
import '../../data/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';

class BudgetScreen extends StatelessWidget {
  final BudgetController c = Get.put(BudgetController());

  BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Target Anggaran',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 4,
        onPressed: () => _showAddBudgetSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
      body: Column(
        children: [
          _buildFilterRow()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.2, end: 0),
          Expanded(
            child: Obx(() {
              if (c.budgets.isEmpty) {
                return Center(
                  child: Text('Belum ada anggaran bulan ini.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14.sp)),
                ).animate().fadeIn();
              }

              final formatCurrency = NumberFormat.currency(
                  locale: 'id', symbol: 'Rp ', decimalDigits: 0);

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                itemCount: c.budgets.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final data = c.budgets[index];
                  final cat = data.budget.category.value;
                  final limit = data.budget.limitAmount;
                  final spent = data.spentAmount;
                  final double progress = limit > 0 ? (spent / limit) : 0.0;

                  Color progressColor = AppColors.primary;
                  if (progress >= 1.0) {
                    progressColor = AppColors.error;
                  } else if (progress >= 0.8) {
                    progressColor = const Color(0xFFF59E0B);
                  }

                  return InkWell(
                    onLongPress: () => _confirmDelete(context, data.budget.id),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Ink(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                            color: progress >= 1.0
                                ? AppColors.error.withOpacity(0.3)
                                : Colors.transparent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle),
                                child: Icon(
                                    IconMapper.getIcon(
                                        cat?.iconName ?? 'category'),
                                    color: AppColors.primary,
                                    size: 20.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(cat?.name ?? 'Lainnya',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                formatCurrency.format(spent),
                                style: TextStyle(
                                    color: progressColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: LinearProgressIndicator(
                              value: progress > 1.0 ? 1.0 : progress,
                              minHeight: 8.h,
                              backgroundColor: AppColors.background,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${(progress * 100).toStringAsFixed(1)}% Terpakai',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.sp)),
                              Text('Batas: ${formatCurrency.format(limit)}',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.sp)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => DropdownButton<int>(
                value: c.selectedMonth.value,
                dropdownColor: AppColors.card,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 20.sp),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                        value: i + 1, child: Text(monthNames[i]))),
                onChanged: (val) {
                  if (val != null) c.changePeriod(val, c.selectedYear.value);
                },
              )),
          SizedBox(width: 24.w),
          Obx(() => DropdownButton<int>(
                value: c.selectedYear.value,
                dropdownColor: AppColors.card,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 20.sp),
                items: [2025, 2026, 2027]
                    .map((y) =>
                        DropdownMenuItem(value: y, child: Text(y.toString())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) c.changePeriod(c.selectedMonth.value, val);
                },
              )),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: AppColors.card,
      title: 'Hapus Anggaran',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus target ini?',
      middleTextStyle:
          TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      textCancel: 'Batal',
      cancelTextColor: AppColors.primary,
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        c.deleteBudget(id);
      },
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    var selectedCat = Rxn<Category>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: 24.h + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Anggaran Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16.r)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Category>(
                        isExpanded: true,
                        dropdownColor: AppColors.card,
                        hint: Text('Pilih Kategori Pengeluaran',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp)),
                        value: selectedCat.value,
                        items: c.expenseCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name,
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (val) => selectedCat.value = val,
                      ),
                    ),
                  )),
              SizedBox(height: 16.h),
              TextField(
                controller: c.limitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Batas Maksimal (Rp)',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                      elevation: 0),
                  onPressed: () {
                    if (selectedCat.value != null &&
                        c.limitController.text.isNotEmpty) {
                      final limit =
                          double.tryParse(c.limitController.text) ?? 0.0;
                      if (limit > 0) {
                        c.saveBudget(selectedCat.value!, limit);
                      }
                    }
                  },
                  child: Text('Simpan Anggaran',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
