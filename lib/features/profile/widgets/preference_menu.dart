import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class PreferenceMenu extends StatelessWidget {
  const PreferenceMenu({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildMenuItem(Icons.lock_outline, 'Keamanan Privasi',
                    'Kunci aplikasi biometrik',
                    isPending: true),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(Icons.cloud_download_outlined,
                    'Backup & Restore', 'Amankan data lokal',
                    isPending: true),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(
                    Icons.help_outline, 'Pusat Bantuan', 'Panduan penggunaan'),
                Divider(
                    color: AppColors.textSecondary.withOpacity(0.1), height: 1),
                _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi',
                    'FinTrack Pro v1.0.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle,
      {bool isPending = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600)),
          if (isPending) ...[
            SizedBox(width: 8.w),
            Icon(Icons.construction,
                color: const Color(0xFFF59E0B), size: 14.sp),
          ]
        ],
      ),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: AppColors.textSecondary, size: 14),
      onTap: () {},
    );
  }
}
