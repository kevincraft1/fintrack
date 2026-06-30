import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import '../../history/history_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../history/edit_transaction_screen.dart';

class RecentTransactions extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaksi Terbaru',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (c.recentTransactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Text(
                    'Belum ada transaksi.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms);
            }

            return Column(
              children: List.generate(c.recentTransactions.length, (index) {
                final txn = c.recentTransactions[index];
                final cat = txn.category.value;
                final isIncome = cat?.type == 'income';
                final formatCurrency = NumberFormat.currency(
                    locale: 'id', symbol: 'Rp ', decimalDigits: 0);
                final formatDate =
                    DateFormat('dd MMM • HH:mm').format(txn.date);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == c.recentTransactions.length - 1 ? 0 : 12.h,
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.put(HistoryController());
                      Get.to(() => EditTransactionScreen(transaction: txn))
                          ?.then((_) => c.loadHomeData());
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Ink(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat != null
                                  ? IconMapper.getIcon(cat.iconName)
                                  : Icons.category,
                              color: isIncome
                                  ? AppColors.primary
                                  : AppColors.error,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat?.name ?? 'Lainnya',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formatDate,
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIncome ? '+' : '-'} ${formatCurrency.format(txn.amount)}',
                            style: TextStyle(
                              color: isIncome
                                  ? AppColors.primary
                                  : AppColors.error,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate(key: ValueKey(txn.id))
                    .fadeIn(delay: (50 * index).ms, duration: 250.ms)
                    .slideX(begin: 0.05, end: 0);
              }),
            );
          }),
        ],
      ),
    );
  }
}
