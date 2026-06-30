import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../profile_controller.dart';
import '../../../core/theme/app_colors.dart';

class IdentityCard extends StatelessWidget {
  final ProfileController c = Get.find<ProfileController>();

  IdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child:
                    Icon(Icons.person, color: AppColors.primary, size: 36.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengguna Pro',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getHealthColor(c.financialHealth.value)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            c.financialHealth.value,
                            style: TextStyle(
                              color: _getHealthColor(c.financialHealth.value),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(color: AppColors.textSecondary.withOpacity(0.2)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn(
                  'Total Trx', c.totalTransactionsCount.value.toString()),
              _buildStatColumn(
                  'Pemasukan', c.formatCurrency(c.lifetimeIncome.value),
                  isCurrency: true),
              _buildStatColumn(
                  'Pengeluaran', c.formatCurrency(c.lifetimeExpense.value),
                  isCurrency: true, isExpense: true),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(String status) {
    if (status == 'Sangat Sehat') return Colors.greenAccent;
    if (status == 'Stabil') return AppColors.primary;
    if (status == 'Boros' || status == 'Kritis') return AppColors.error;
    return AppColors.textSecondary;
  }

  Widget _buildStatColumn(String label, String value,
      {bool isCurrency = false, bool isExpense = false}) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
        SizedBox(height: 4.h),
        Obx(() {
          final displayValue = isCurrency
              ? c.formatCurrency(
                  isExpense ? c.lifetimeExpense.value : c.lifetimeIncome.value)
              : c.totalTransactionsCount.value.toString();

          return Text(
            displayValue,
            style: TextStyle(
              color: isCurrency
                  ? (isExpense ? AppColors.error : AppColors.primary)
                  : AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }
}
