import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';

class CategoryRow extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: c.categories.length,
            itemBuilder: (context, index) {
              final cat = c.categories[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  c.saveTransaction(cat.name);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: (c.selectedType.value == 'income'
                                ? AppColors.primary
                                : AppColors.error)
                            .withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconMapper.getIcon(cat.iconName),
                        color: c.selectedType.value == 'income'
                            ? AppColors.primary
                            : AppColors.error,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(key: ValueKey(cat.id))
                  .fadeIn(delay: (50 * index).ms)
                  .slideX(begin: 0.2, end: 0);
            },
          )),
    );
  }
}
