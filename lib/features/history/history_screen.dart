import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'history_controller.dart';
import 'edit_transaction_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/utils/pdf_helper.dart';
import '../../core/utils/csv_helper.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryController c = Get.put(HistoryController());

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Riwayat Transaksi',
            style: TextStyle(fontSize: 20.sp, color: AppColors.textPrimary)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            color: AppColors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            onSelected: (value) {
              if (c.transactions.isEmpty) {
                Get.snackbar(
                  'Data Kosong',
                  'Tidak ada transaksi untuk diekspor.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: AppColors.textPrimary,
                );
                return;
              }
              if (value == 'pdf') {
                PdfHelper.generateAndPrintReport(
                  c.transactions.toList(),
                  c.selectedMonth.value,
                  c.selectedYear.value,
                );
              } else if (value == 'csv') {
                CsvHelper.generateAndShareCsv(
                  c.transactions.toList(),
                  c.selectedMonth.value,
                  c.selectedYear.value,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf,
                        color: AppColors.error, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text('Cetak Laporan PDF',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 14.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart,
                        color: Colors.greenAccent, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text('Ekspor Data CSV',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.2, end: 0),
          _buildSearchBar()
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: -0.2, end: 0),
          Expanded(
            child: Obx(() {
              if (c.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64.sp,
                          color: AppColors.textSecondary.withOpacity(0.5)),
                      SizedBox(height: 16.h),
                      Text(
                        c.searchQuery.value.isEmpty
                            ? 'Belum ada transaksi.'
                            : 'Data tidak ditemukan.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16.sp),
                      ),
                    ],
                  ).animate().fadeIn(),
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
                          borderRadius: BorderRadius.circular(16.r)),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: const BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle),
                            child:
                                Icon(iconData, color: amountColor, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(categoryName,
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
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
                                Text(formatDate,
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.sp)),
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
                  )
                      .animate(key: ValueKey(txn.id))
                      .fadeIn(delay: (30 * (index < 10 ? index : 0)).ms)
                      .slideX(begin: 0.1, end: 0);
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
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 20.sp),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                        value: i + 1, child: Text('Bulan ${i + 1}'))),
                onChanged: (val) {
                  if (val != null) c.changePeriod(val, c.selectedYear.value);
                },
              )),
          SizedBox(width: 24.w),
          Obx(() => DropdownButton<int>(
                value: c.selectedYear.value,
                dropdownColor: AppColors.card,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 20.sp),
                items: [2025, 2026, 2027]
                    .map((y) =>
                        DropdownMenuItem(value: y, child: Text(y.toString())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) c.changePeriod(c.selectedMonth.value, val);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: c.searchController,
        onChanged: c.updateSearch,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Cari kategori, catatan, atau nominal...',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          prefixIcon:
              Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
          suffixIcon: Obx(() => c.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel,
                      color: AppColors.textSecondary, size: 18.sp),
                  onPressed: c.clearSearch)
              : const SizedBox()),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: EdgeInsets.symmetric(vertical: 0.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
