import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../security/security_controller.dart';
import '../../backup/backup_controller.dart';
import '../../category/category_management_screen.dart';
import '../../wallet/wallet_management_screen.dart';

class PreferenceMenu extends StatelessWidget {
  const PreferenceMenu({super.key});

  Future<void> _showPrivacyPolicy(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Kebijakan Privasi (100% Offline)',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            'FinTrack Pro Enterprise Edition dirancang dengan arsitektur "Zero Data Collection".\n\n'
            'Seluruh data finansial, catatan, dan metrik Anda disimpan HANYA secara lokal di dalam perangkat Anda. '
            'Kami tidak memiliki akses, tidak mengumpulkan, dan tidak mentransmisikan data privasi Anda ke server eksternal mana pun.\n\n'
            'Anda bertanggung jawab penuh atas keamanan perangkat Anda sendiri (termasuk fitur pencadangan lokal dan keamanan biometrik).',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13.sp, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            // INJEKSI CONST MUTLAK UNTUK OPTIMASI MEMORI
            child: const Text(
              'SAYA MENGERTI',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutApp(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;

    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: 'FinTrack Pro',
        applicationVersion: 'v$version (Enterprise Edition)',
        applicationIcon: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset('assets/images/fintrack-pro.png',
              width: 48.w, height: 48.w, fit: BoxFit.contain),
        ),
        applicationLegalese:
            '© 2026 Hak Cipta Dilindungi Undang-Undang.\nPerangkat Lunak Proprietary tertutup.\nDikembangkan eksklusif untuk keamanan finansial mutlak.',
      );
    }
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
                _buildMenuItem(
                  Icons.account_balance_wallet_outlined,
                  'Kelola Dompet',
                  'Atur saldo & multi-akun',
                  onTap: () => Get.to(() => WalletManagementScreen()),
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                  Icons.category_outlined,
                  'Kelola Kategori',
                  'Atur jenis pemasukan & pengeluaran',
                  onTap: () => Get.to(() => CategoryManagementScreen()),
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
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
                  onTap: () => _showPrivacyPolicy(context),
                ),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                  Icons.info_outline,
                  'Tentang Aplikasi',
                  'Informasi lisensi & versi',
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
