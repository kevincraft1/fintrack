import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_colors.dart';

// Mesin Controller Global untuk membaca versi native
class AppVersionController extends GetxController {
  var version = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    // Format output: v1.0.0
    version.value = 'v${info.version}';
  }
}

// Komponen UI Watermark
class VersionFooter extends StatelessWidget {
  // permanent: true memastikan controller ini terus hidup di memori global
  final AppVersionController c =
      Get.put(AppVersionController(), permanent: true);

  VersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 40.h),
      child: Center(
        child: Obx(() {
          if (c.version.value.isEmpty) return const SizedBox();
          return Text(
            'FinTrack Pro ${c.version.value}',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.4),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          );
        }),
      ),
    );
  }
}
