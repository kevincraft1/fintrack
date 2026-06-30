import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class AmountDisplay extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  AmountDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Obx(() => Text(
            c.formattedAmount,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
              .animate(key: ValueKey(c.amountStr.value))
              .shimmer(duration: 150.ms)
              .scaleXY(begin: 0.95, end: 1.0)),
    ).animate().fadeIn(delay: 200.ms);
  }
}
