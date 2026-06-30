import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../security/security_controller.dart';
import '../../backup/backup_controller.dart';

class PreferenceMenu extends StatelessWidget {
  const PreferenceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final SecurityController securityC = Get.find<SecurityController>();
    final BackupController backupC = Get.put(BackupController());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan & Utilitas',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Obx(() => _buildSwitchItem(
                      Icons.lock_outline,
                      'Keamanan Privasi',
                      'Kunci aplikasi biometrik',
                      securityC.isAppLockEnabled.value,
                      securityC.toggleAppLock,
                    )),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                  Icons.cloud_upload_outlined,
                  'Backup Data',
                  'Ekspor database ke penyimpanan',
                  onTap: backupC.exportDatabase,
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                  Icons.cloud_download_outlined,
                  'Restore Data',
                  'Pulihkan database dari file .isar',
                  onTap: backupC.importDatabase,
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi',
                    'FinTrack Pro v1.0.0',
                    onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle,
      {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(title,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: AppColors.textSecondary, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, String subtitle,
      bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(title,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        inactiveTrackColor: AppColors.background,
      ),
    );
  }
}
