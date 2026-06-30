import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Saldo',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Obx(() => Text(
                    c.formattedBalance,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  )
                      .animate(key: ValueKey(c.totalBalance.value))
                      .shimmer()
                      .scaleXY(begin: 0.9, end: 1.0)),
            ],
          ),
          Icon(Icons.account_balance_wallet,
                  color: AppColors.primary, size: 32.sp)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(begin: -2, end: 2, duration: 1500.ms),
        ],
      ),
    );
  }
}
