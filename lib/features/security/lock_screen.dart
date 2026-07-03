import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'security_controller.dart';
import '../home/home_screen.dart';
import '../../core/theme/app_colors.dart';

class LockScreen extends StatelessWidget {
  final SecurityController c = Get.put(SecurityController());

  LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (c.isAuthenticated.value) {
          return HomeScreen();
        }
        return SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // INTEGRASI LOGO DENGAN SAFETY CONSTRAINT
                Image.asset(
                  'assets/images/fintrack-pro.png',
                  width: 100.w, // Batasan Lebar Maksimal
                  height: 100.w, // Batasan Tinggi Maksimal
                  fit: BoxFit.contain,
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scaleXY(
                        begin: 0.9,
                        end: 1.1,
                        duration: 1500.ms,
                        curve: Curves.easeInOut),
                SizedBox(height: 24.h),
                Text(
                  'Aplikasi Terkunci',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Verifikasi keamanan untuk mengakses data keuangan',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 48.h),
                ElevatedButton.icon(
                  onPressed: c.executeAuthentication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: Text(
                    'Buka Kunci',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).scaleXY(begin: 0.9, end: 1.0),
              ],
            ),
          ),
        );
      }),
    );
  }
}
