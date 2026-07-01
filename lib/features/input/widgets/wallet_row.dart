import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';

class WalletRow extends StatelessWidget {
  final InputController c = Get.find<InputController>();

  WalletRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.wallets.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text('Sumber Dana',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: c.wallets.length,
              itemBuilder: (context, index) {
                final wallet = c.wallets[index];
                final isSelected = c.selectedWallet.value?.id == wallet.id;

                return GestureDetector(
                  onTap: () => c.selectedWallet.value = wallet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(IconMapper.getIcon(wallet.iconName),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 16.sp),
                        SizedBox(width: 8.w),
                        Text(wallet.name,
                            style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
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
