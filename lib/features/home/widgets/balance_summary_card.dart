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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF111827).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60.w,
            top: -60.h,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Saldo (Bulan $currentMonth)',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5),
                    ),
                    Icon(Icons.account_balance_wallet,
                        color: AppColors.primary, size: 18.sp),
                  ],
                ),
                SizedBox(height: 12.h),
                Obx(() => Text(
                      formatCurrency.format(c.totalBalance.value),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                SizedBox(height: 28.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.arrow_downward_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 16.sp),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Obx(() => Text(
                                  formatCurrency.format(c.totalIncome.value),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36.h,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        color: Colors.white.withOpacity(0.15),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.arrow_upward_rounded,
                                    color: const Color(0xFFEF4444),
                                    size: 16.sp),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Obx(() => Text(
                                  formatCurrency.format(c.totalExpense.value),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
