import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';

class WalletRow extends StatelessWidget {
  final InputController c = Get.find();

  WalletRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.selectedType.value == 'transfer') {
        return Row(
          children: [
            Expanded(child: _buildWalletSelector(context, true)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textSecondary, size: 20.sp),
            ),
            Expanded(child: _buildWalletSelector(context, false)),
          ],
        );
      }
      return _buildWalletSelector(context, true);
    });
  }

  Widget _buildWalletSelector(BuildContext context, bool isSource) {
    return GestureDetector(
      onTap: () => _showWalletPicker(context, isSource),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
                isSource ? Icons.account_balance_wallet : Icons.account_balance,
                color: c.selectedType.value == 'transfer'
                    ? const Color(0xFF3B82F6)
                    : AppColors.primary,
                size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      isSource
                          ? (c.selectedType.value == 'transfer'
                              ? 'Dari Dompet'
                              : 'Dompet')
                          : 'Ke Dompet',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11.sp)),
                  Obx(() {
                    final wallet = isSource
                        ? c.selectedWallet.value
                        : c.selectedToWallet.value;
                    return Text(
                      wallet?.name ?? 'Pilih Dompet',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(BuildContext context, bool isSource) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isSource ? 'Pilih Dompet Asal' : 'Pilih Dompet Tujuan',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: c.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = c.wallets[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_balance_wallet,
                          color: AppColors.primary),
                      title: Text(wallet.name,
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 16.sp)),
                      subtitle: Text('Saldo: Rp ${wallet.balance}',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.sp)),
                      onTap: () {
                        if (isSource) {
                          c.selectedWallet.value = wallet;
                        } else {
                          c.selectedToWallet.value = wallet;
                        }
                        Get.back();
                      },
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
