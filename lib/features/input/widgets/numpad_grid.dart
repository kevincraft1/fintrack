import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class NumpadGrid extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  NumpadGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRow(['1', '2', '3']),
          SizedBox(height: 12.h),
          _buildRow(['4', '5', '6']),
          SizedBox(height: 12.h),
          _buildRow(['7', '8', '9']),
          SizedBox(height: 12.h),
          _buildRow(['000', '0', 'backspace']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key) {
    if (key == 'backspace') {
      return _buildButton(
        onTap: c.removeDigit,
        child:
            Icon(Icons.backspace_outlined, color: AppColors.error, size: 28.sp),
      );
    }
    return _buildButton(
      onTap: () => c.addDigit(key),
      child: Text(
        key,
        style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildButton({required VoidCallback onTap, required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 80.w,
          height: 56.h,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
