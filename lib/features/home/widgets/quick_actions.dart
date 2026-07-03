import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../input/input_screen.dart';
import '../../history/history_screen.dart';
import '../../budget/budget_screen.dart';
import '../../statistics/statistics_screen.dart';
import '../../debt/debt_screen.dart';
import '../../goal/goal_screen.dart'; // Import layar baru
import '../../../core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildActionBtn(Icons.add_circle_outline, 'Catat',
              () => Get.to(() => InputScreen())),
          SizedBox(width: 20.w),
          _buildActionBtn(
              Icons.history, 'Riwayat', () => Get.to(() => HistoryScreen())),
          SizedBox(width: 20.w),
          _buildActionBtn(Icons.track_changes, 'Anggaran',
              () => Get.to(() => BudgetScreen())),
          SizedBox(width: 20.w),
          _buildActionBtn(Icons.star_outline, 'Impian',
              () => Get.to(() => GoalScreen())), // Tombol Impian
          SizedBox(width: 20.w),
          _buildActionBtn(Icons.handshake_outlined, 'Hutang',
              () => Get.to(() => DebtScreen())),
          SizedBox(width: 20.w),
          _buildActionBtn(Icons.bar_chart, 'Statistik',
              () => Get.to(() => StatisticsScreen())),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
          Text(label,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
