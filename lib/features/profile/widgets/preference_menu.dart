import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../security/security_controller.dart';
import '../../backup/backup_controller.dart';

class PreferenceMenu extends StatelessWidget {
  const PreferenceMenu({super.key});

  Future<void> _launchPrivacyPolicy() async {
    // Ganti URL ini dengan URL Google Sites / Web Kebijakan Privasi asli Anda nanti
    final Uri url = Uri.parse('https://policies.google.com/privacy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Tidak dapat membuka browser.',
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FinTrack Pro',
      applicationVersion: 'v1.0.0 (Production Release)',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset('assets/images/fintrack-pro.png',
            width: 48.w, height: 48.w),
      ),
      applicationLegalese:
          '© 2026 FinTrack Pro.\nDikembangkan secara eksklusif untuk efisiensi finansial mutlak.',
    );
  }

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
                _buildMenuItem(
                  Icons.shield_outlined,
                  'Kebijakan Privasi',
                  'Syarat & ketentuan data',
                  onTap: _launchPrivacyPolicy,
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                  Icons.info_outline,
                  'Tentang Aplikasi',
                  'FinTrack Pro v1.0.0',
                  onTap: () => _showAboutApp(context),
                ),
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
