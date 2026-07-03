import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'statistics_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/version_footer.dart';

class StatisticsScreen extends StatelessWidget {
  final StatisticsController c = Get.put(StatisticsController());

  StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final months = [
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
    final currentMonth = months[DateTime.now().month - 1];

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
        title: Text('Analisis Bulan $currentMonth',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (c.totalExpense.value == 0) {
          return Center(
            child: Text('Belum ada data pengeluaran bulan ini.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              Text('Struktur Pengeluaran',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 32.h),
              SizedBox(
                height: 250.h,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60.r,
                    sections: c.expenseByCategory.entries.map((entry) {
                      final percentage =
                          (entry.value / c.totalExpense.value) * 100;
                      return PieChartSectionData(
                        color: c.categoryColors[entry.key],
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 50.r,
                        titleStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rincian Kategori',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 20.h),
                    ...c.expenseByCategory.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Row(
                          children: [
                            Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                    color: c.categoryColors[entry.key],
                                    shape: BoxShape.circle)),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: Text(entry.key,
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14.sp))),
                            Text(formatCurrency.format(entry.value),
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                    Divider(
                        color: AppColors.textSecondary.withOpacity(0.15),
                        height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pengeluaran',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold)),
                        Text(
                          formatCurrency.format(c.totalExpense.value),
                          style: TextStyle(
                              color: const Color(0xFFEF4444),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              VersionFooter(),
            ],
          ),
        );
      }),
    );
  }
}
