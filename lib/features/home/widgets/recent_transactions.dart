import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';

class RecentTransactions extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text('Transaksi Terakhir',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (c.recentTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text('Belum ada transaksi',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14.sp)),
              ),
            );
          }
          final formatCurrency = NumberFormat.currency(
              locale: 'id', symbol: 'Rp ', decimalDigits: 0);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: c.recentTransactions.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final txn = c.recentTransactions[index];
              final cat = txn.category.value;
              final wallet = txn.wallet.value;
              final isIncome = cat?.type == 'income';

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                          color: AppColors.background, shape: BoxShape.circle),
                      child: Icon(
                          IconMapper.getIcon(cat?.iconName ?? 'category'),
                          color: isIncome ? AppColors.primary : AppColors.error,
                          size: 20.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // PERBAIKAN: Safety constraint
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat?.name ?? 'Lainnya',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(wallet?.name ?? '-',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : '-'} ${formatCurrency.format(txn.amount)}',
                      style: TextStyle(
                          color: isIncome ? AppColors.primary : AppColors.error,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
