import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class TypeToggle extends StatelessWidget {
  final InputController c = Get.find();

  TypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
        child: Obx(() => Row(
              children: [
                _buildOption('Pengeluaran', 'expense', AppColors.error),
                _buildOption('Pemasukan', 'income', AppColors.primary),
                _buildOption('Transfer', 'transfer', const Color(0xFF3B82F6)),
              ],
            )),
      ),
    );
  }

  Widget _buildOption(String title, String type, Color activeColor) {
    final isActive = c.selectedType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.changeType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.sp,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
