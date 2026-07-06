import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../input/input_screen.dart';
import '../../history/history_screen.dart';
import '../../budget/budget_screen.dart';
import '../../statistics/statistics_screen.dart';
import '../../debt/debt_screen.dart';
import '../../goal/goal_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Row(
            children: [
              _buildActionBtn(Icons.add_circle_outline, 'Catat', () async {
                final result = await Get.to(() => InputScreen());
                if (result == true) {
                  Get.find<HomeController>().loadHomeData();
                }
              }),
              _buildActionBtn(Icons.history, 'Riwayat', () async {
                final result = await Get.to(() => HistoryScreen());
                if (result == true) {
                  Get.find<HomeController>().loadHomeData();
                }
              }),
              _buildActionBtn(Icons.track_changes, 'Anggaran',
                  () => Get.to(() => BudgetScreen())),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildActionBtn(Icons.star_outline, 'Impian',
                  () => Get.to(() => GoalScreen())),
              _buildActionBtn(Icons.handshake_outlined, 'Hutang',
                  () => Get.to(() => DebtScreen())),
              _buildActionBtn(Icons.bar_chart, 'Statistik',
                  () => Get.to(() => StatisticsScreen())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
