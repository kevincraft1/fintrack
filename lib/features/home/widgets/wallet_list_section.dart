import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';

class WalletListSection extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  WalletListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Obx(() {
      if (c.wallets.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text('Dompet Anda',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: c.wallets.length,
              itemBuilder: (context, index) {
                final wallet = c.wallets[index];
                final balance = c.walletBalances[wallet.id] ?? 0.0;

                return Container(
                  width: 150.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconMapper.getIcon(wallet.iconName),
                          color: AppColors.primary, size: 24.sp),
                      const Spacer(),
                      Text(wallet.name,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.h),
                      Text(formatCurrency.format(balance),
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
