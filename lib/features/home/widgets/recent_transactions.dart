import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import '../../input/input_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../data/models/transaction.dart';

class RecentTransactions extends StatelessWidget {
  final HomeController c = Get.find<HomeController>();

  static final _formatCurrency =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

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
            return _buildInteractiveEmptyState();
          }
          return _buildTransactionList();
        }),
      ],
    );
  }

  Widget _buildInteractiveEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 32.sp),
          ),
          SizedBox(height: 16.h),
          Text('Belum Ada Transaksi',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Mulai catat pengeluaran atau pemasukan pertamamu hari ini.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => InputScreen());
              if (result == true) {
                c.loadHomeData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            icon: Icon(Icons.add_circle_outline, size: 18.sp),
            label: Text('Catat Sekarang',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: c.recentTransactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) =>
          _buildTransactionItem(c.recentTransactions[index]),
    );
  }

  Widget _buildTransactionItem(Transaction txn) {
    final cat = txn.category.value;
    final wallet = txn.wallet.value;
    final type = cat?.type ?? '';

    final isAddition =
        type == 'income' || type == 'debt_in' || type == 'debt_collect';
    final isTransfer = type == 'transfer';

    final operator = isTransfer ? '' : (isAddition ? '+' : '-');
    final amountColor = isTransfer
        ? const Color(0xFF3B82F6)
        : (isAddition ? AppColors.primary : AppColors.error);

    String subtitleText = wallet?.name ?? '-';
    if (isTransfer) {
      final toWallet = txn.toWallet.value;
      subtitleText += ' ➔ ${toWallet?.name ?? '-'}';
    }

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
            child: Icon(IconMapper.getIcon(cat?.iconName ?? 'category'),
                color: amountColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat?.name ?? 'Lainnya',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text(subtitleText,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.sp)),
              ],
            ),
          ),
          Text(
            '$operator ${_formatCurrency.format(txn.amount)}',
            style: TextStyle(
                color: amountColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
