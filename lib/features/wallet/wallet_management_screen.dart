import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'wallet_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';

class WalletManagementScreen extends StatelessWidget {
  final WalletController c = Get.put(WalletController());

  WalletManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Kelola Dompet',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 4,
        onPressed: () => _showAddWalletSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
      body: Obx(() {
        if (c.wallets.isEmpty) return const SizedBox();
        final formatCurrency = NumberFormat.currency(
            locale: 'id', symbol: 'Rp ', decimalDigits: 0);

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          itemCount: c.wallets.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final wallet = c.wallets[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {},
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  leading: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconMapper.getIcon(wallet.iconName),
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    wallet.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Saldo Awal: ${formatCurrency.format(wallet.initialBalance)}',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.sp),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: () => _confirmDelete(context, wallet.id),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: AppColors.card,
      title: 'Hapus Dompet',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus dompet ini?',
      middleTextStyle:
          TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      textCancel: 'Batal',
      cancelTextColor: AppColors.primary,
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        c.deleteWallet(id);
      },
    );
  }

  void _showAddWalletSheet(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    var selectedIcon = 'account_balance_wallet'.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dompet Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nama Dompet (mis. BCA, GoPay)',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Saldo Awal (Opsional)',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Pilih Ikon',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: IconMapper.availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconName = IconMapper.availableIcons[index];
                    return Obx(() => GestureDetector(
                          onTap: () => selectedIcon.value = iconName,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 12.w),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: selectedIcon.value == iconName
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selectedIcon.value == iconName
                                      ? AppColors.primary
                                      : Colors.transparent),
                            ),
                            child: Icon(IconMapper.getIcon(iconName),
                                color: selectedIcon.value == iconName
                                    ? AppColors.primary
                                    : AppColors.textPrimary),
                          ),
                        ));
                  },
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      double initBalance = 0.0;
                      if (balanceController.text.isNotEmpty) {
                        initBalance =
                            double.tryParse(balanceController.text) ?? 0.0;
                      }
                      c.addWallet(nameController.text.trim(),
                          selectedIcon.value, initBalance);
                    }
                  },
                  child: Text('Simpan Dompet',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
