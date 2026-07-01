import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class AmountDisplay extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  AmountDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Nominal Transaksi',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          SizedBox(
            height: 64.h,
            width: double.infinity,
            child: Obx(() => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    c.formattedAmount,
                    style: TextStyle(
                      color: c.selectedType.value == 'income'
                          ? AppColors.primary
                          : AppColors.error,
                      fontSize: 56.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
