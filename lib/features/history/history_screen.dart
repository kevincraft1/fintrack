import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'history_controller.dart';
import 'edit_transaction_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/utils/pdf_helper.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController c = Get.put(HistoryController());

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () {
              if (c.transactions.isNotEmpty) {
                PdfHelper.generateAndPrintReport(
                  c.transactions.toList(),
                  c.selectedMonth.value,
                  c.selectedYear.value,
                );
              } else {
                Get.snackbar(
                  'Data Kosong',
                  'Tidak ada transaksi pada periode ini untuk diekspor.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: AppColors.textPrimary,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: Obx(() {
              if (c.transactions.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada transaksi.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16.sp),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: c.transactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final txn = c.transactions[index];
                  final category = txn.category.value;
                  final categoryName = category?.name ?? 'Lainnya';
                  final iconData = category != null
                      ? IconMapper.getIcon(category.iconName)
                      : Icons.category;
                  final formatCurrency = NumberFormat.currency(
                      locale: 'id', symbol: 'Rp ', decimalDigits: 0);
                  final formatDate =
                      DateFormat('dd MMM yyyy • HH:mm').format(txn.date);

                  final isIncome = category?.type == 'income';
                  final operator = isIncome ? '+' : '-';
                  final amountColor =
                      isIncome ? AppColors.primary : AppColors.error;
                  final hasNote = txn.note != null && txn.note!.isNotEmpty;

                  return InkWell(
                    onTap: () => Get.to(
                      () => EditTransactionScreen(transaction: txn),
                      transition: Transition.rightToLeftWithFade,
                    ),
                    onLongPress: () => c.deleteTransaction(txn.id),
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
                            child:
                                Icon(iconData, color: amountColor, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryName,
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (hasNote) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    txn.note!,
                                    style: TextStyle(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                        fontSize: 13.sp,
                                        fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
                            '$operator ${formatCurrency.format(txn.amount)}',
                            style: TextStyle(
                                color: amountColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => DropdownButton<int>(
                value: c.selectedMonth.value,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Bulan ${i + 1}'),
                        )),
                onChanged: (val) {
                  if (val != null) c.changePeriod(val, c.selectedYear.value);
                },
              )),
          SizedBox(width: 24.w),
          Obx(() => DropdownButton<int>(
                value: c.selectedYear.value,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: [2025, 2026, 2027]
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) c.changePeriod(c.selectedMonth.value, val);
                },
              )),
        ],
      ),
    );
  }
}
