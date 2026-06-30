import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../home_controller.dart';
import '../../../core/theme/app_colors.dart';

class BalanceSummaryCard extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  BalanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Saldo',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Obx(() => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  c.formatCurrency(c.totalBalance.value),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1),
                ),
              )),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Pemasukan', c.monthlyIncome,
                    Icons.arrow_downward, Colors.greenAccent),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMiniStat('Pengeluaran', c.monthlyExpense,
                    Icons.arrow_upward, Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String title, RxDouble amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
              color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
              SizedBox(height: 2.h),
              Obx(() => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      c.formatCurrency(amount.value),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
