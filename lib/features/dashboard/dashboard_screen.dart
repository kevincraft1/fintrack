import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController c = Get.put(DashboardController());

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: Obx(() {
              if (c.chartData.isEmpty) {
                return _buildEmptyState();
              }
              return _buildDonutChart();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => DropdownButton<int>(
                value: c.selectedMonth.value,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Bulan ${i + 1}'),
                        )),
                onChanged: (val) {
                  if (val != null) c.changePeriod(val, c.selectedYear.value);
                },
              )),
          SizedBox(width: 24.w),
          Obx(() => DropdownButton<int>(
                value: c.selectedYear.value,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: [2025, 2026, 2027]
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) c.changePeriod(c.selectedMonth.value, val);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 80.sp,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Belum ada data transaksi',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Pengeluaran',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                formatCurrency.format(c.totalAmount.value),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 110.r,
              sections: c.chartData.map((data) {
                final index = c.chartData.indexOf(data);
                return PieChartSectionData(
                  value: data['amount'],
                  title: data['category'],
                  radius: 40.r,
                  titleStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: Colors.primaries[index % Colors.primaries.length],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
