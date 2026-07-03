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
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: c.noteController,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Tambah catatan (opsional)',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          prefixIcon:
              Icon(Icons.edit_note, color: AppColors.primary, size: 20.sp),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        ),
      ),
    );
  }
}
