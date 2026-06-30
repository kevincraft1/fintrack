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
    final keyRows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: keyRows.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final rowKeys = entry.value;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: rowIndex == 3 ? 0 : 12.h),
              child: Row(
                children: rowKeys.asMap().entries.map((keyEntry) {
                  final colIndex = keyEntry.key;
                  final keyStr = keyEntry.value;
                  final isAction = keyStr == 'C' || keyStr == '⌫';
                  final index = (rowIndex * 3) + colIndex;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: colIndex == 2 ? 0 : 16.w),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (keyStr == 'C') {
                              c.amountStr.value = '0';
                            } else if (keyStr == '⌫') {
                              c.removeDigit();
                            } else {
                              c.addDigit(keyStr);
                            }
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: isAction
                                  ? const Color(0xFF334155)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Obx(() {
                                final currentType = c.selectedType.value;
                                return Text(
                                  keyStr,
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
                      ),
                    ).animate().scale(
                        delay: (20 * index).ms,
                        duration: 300.ms,
                        curve: Curves.easeOutBack),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
