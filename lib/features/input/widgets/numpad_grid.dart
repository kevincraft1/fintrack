import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class NumpadGrid extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  NumpadGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫'];
    return Container(
      padding: EdgeInsets.all(24.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isAction = key == 'C' || key == '⌫';
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (key == 'C') {
                  c.amountStr.value = '0';
                } else if (key == '⌫') {
                  c.removeDigit();
                } else {
                  c.addDigit(key);
                }
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Ink(
                decoration: BoxDecoration(
                  color: isAction ? const Color(0xFF334155) : AppColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Obx(() {
                    final currentType = c.selectedType.value;
                    return Text(
                      key,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: isAction
                            ? (currentType == 'income'
                                ? AppColors.primary
                                : AppColors.error)
                            : AppColors.textPrimary,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ).animate().scale(
              delay: (20 * index).ms,
              duration: 300.ms,
              curve: Curves.easeOutBack);
        },
      ),
    );
  }
}
