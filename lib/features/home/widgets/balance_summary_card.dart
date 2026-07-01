import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import '../../../core/theme/app_colors.dart';

class BalanceSummaryCard extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  BalanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Saldo (Semua Dompet)',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Obx(() => Text(
                formatCurrency.format(c.totalBalance.value),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1),
              )),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_downward,
                            color: Colors.white70, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text('Pemasukan Bulan Ini',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          formatCurrency.format(c.totalIncome.value),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
              Container(
                  width: 1, height: 40.h, color: Colors.white.withOpacity(0.2)),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_upward,
                            color: Colors.white70, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text('Pengeluaran Bulan Ini',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Obx(() => Text(
                          formatCurrency.format(c.totalExpense.value),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
