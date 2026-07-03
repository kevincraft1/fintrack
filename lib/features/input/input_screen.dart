import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'input_controller.dart';
import 'widgets/amount_display.dart';
import 'widgets/type_toggle.dart';
import 'widgets/category_row.dart';
import 'widgets/wallet_row.dart';
import 'widgets/note_input.dart';
import 'widgets/numpad_grid.dart';
import '../../core/theme/app_colors.dart';

class InputScreen extends StatelessWidget {
  final InputController c = Get.put(InputController());

  InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Transaksi Baru',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // INJEKSI SOLUSI UX: Tombol Simpan Absolut di AppBar
          IconButton(
            icon:
                Icon(Icons.check_circle, color: AppColors.primary, size: 28.sp),
            onPressed: () => c.saveTransaction(),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    TypeToggle(),
                    AmountDisplay(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          WalletRow(),
                          SizedBox(height: 16.h),
                          NoteInput(),
                          SizedBox(height: 16.h),
                          CategoryRow(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isKeyboardOpen
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 320.h,
                      child: NumpadGrid(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
