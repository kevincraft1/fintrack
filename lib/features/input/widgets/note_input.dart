import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class NoteInput extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  NoteInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() => AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: c.isNoteExpanded.value
                ? TextField(
                    controller: c.noteController,
                    autofocus: true,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Tulis deskripsi (opsional)...',
                      hintStyle: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14.sp),
                      prefixIcon: Icon(Icons.edit_note,
                          color: AppColors.primary, size: 22.sp),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close,
                            color: AppColors.textSecondary, size: 20.sp),
                        onPressed: () {
                          c.noteController.clear();
                          c.isNoteExpanded.value = false;
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => c.isNoteExpanded.value = true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: AppColors.textSecondary, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Catatan',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          )),
    );
  }
}
