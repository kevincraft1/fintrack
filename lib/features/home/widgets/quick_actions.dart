import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../input/input_screen.dart';
import '../../history/history_screen.dart';
import '../../category/category_management_screen.dart';
import '../home_controller.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(Icons.add_card, 'Catat', AppColors.primary,
              () => Get.to(() => InputScreen())?.then((_) => c.loadHomeData())),
          _buildActionItem(
              Icons.history,
              'Riwayat',
              const Color(0xFFF59E0B),
              () =>
                  Get.to(() => HistoryScreen())?.then((_) => c.loadHomeData())),
          _buildActionItem(Icons.category, 'Kategori', const Color(0xFF8B5CF6),
              () => Get.to(() => CategoryManagementScreen())),
          _buildActionItem(
              Icons.more_horiz, 'Lainnya', AppColors.textSecondary, () {}),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60.w,
            width: 60.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
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
