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
import '../../core/widgets/version_footer.dart';
import '../../data/models/transaction.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Riwayat Transaksi',
            style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [_buildExportMenu()],
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
                return _buildDynamicEmptyState();
              }
              return _buildTransactionList();
            }),
          ),
          VersionFooter(),
        ],
      ),
    );
  }

  Widget _buildExportMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download_rounded, color: AppColors.primary),
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      onSelected: (value) {
        if (c.transactions.isEmpty) {
          Get.snackbar('Data Kosong', 'Tidak ada transaksi untuk diekspor.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white);
          return;
        }
        if (value == 'pdf') {
          PdfHelper.generateAndPrintReport(c.transactions.toList(),
              c.selectedMonth.value, c.selectedYear.value);
        } else if (value == 'csv') {
          CsvHelper.generateAndShareCsv(c.transactions.toList(),
              c.selectedMonth.value, c.selectedYear.value);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 'pdf',
            child: Row(children: [
              Icon(Icons.picture_as_pdf, color: AppColors.error, size: 20.sp),
              SizedBox(width: 12.w),
              Text('Cetak Laporan PDF',
                  style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 14.sp))
            ])),
        PopupMenuItem(
            value: 'csv',
            child: Row(children: [
              Icon(Icons.table_chart, color: Colors.greenAccent, size: 20.sp),
              SizedBox(width: 12.w),
              Text('Ekspor Data CSV',
                  style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 14.sp))
            ])),
      ],
    );
  }

  Widget _buildDynamicEmptyState() {
    final isSearch = c.searchQuery.value.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isSearch
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : Icons.history_toggle_off_rounded,
              size: 48.sp,
              color: isSearch ? AppColors.error : AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            isSearch ? 'Data Tidak Ditemukan' : 'Riwayat Masih Kosong',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              isSearch
                  ? 'Coba gunakan kata kunci lain untuk mencari transaksi.'
                  : 'Belum ada catatan keuangan pada bulan dan tahun ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      itemCount: c.transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) =>
          _buildTransactionItem(context, c.transactions[index], index),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Transaction txn, int index) {
    final category = txn.category.value;
    final wallet = txn.wallet.value;
    final categoryName = category?.name ?? 'Lainnya';
    final iconData = category != null
        ? IconMapper.getIcon(category.iconName)
        : Icons.category;

    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final formatDate = DateFormat('dd MMM yyyy • HH:mm').format(txn.date);

    final type = category?.type ?? '';
    final isAddition =
        type == 'income' || type == 'debt_in' || type == 'debt_collect';
    final isTransfer = type == 'transfer';

    final operator = isTransfer ? '' : (isAddition ? '+' : '-');
    final amountColor = isTransfer
        ? const Color(0xFF3B82F6)
        : (isAddition ? AppColors.primary : AppColors.error);
    final hasNote = txn.note != null && txn.note!.isNotEmpty;

    String subtitleText = formatDate;
    if (isTransfer) {
      final toWallet = txn.toWallet.value;
      subtitleText += ' • ${wallet?.name ?? '-'} ➔ ${toWallet?.name ?? '-'}';
    } else {
      subtitleText += ' • ${wallet?.name ?? '-'}';
    }

    return InkWell(
      onTap: () => Get.to(() => EditTransactionScreen(transaction: txn),
          transition: Transition.rightToLeftWithFade),
      onLongPress: () => _confirmDelete(context, txn.id),
      borderRadius: BorderRadius.circular(16.r),
      child: Ink(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                  color: AppColors.background, shape: BoxShape.circle),
              child: Icon(iconData, color: amountColor, size: 24.sp),
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
                    Text(txn.note!,
                        style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  SizedBox(height: 4.h),
                  Text(subtitleText,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11.sp)),
                ],
              ),
            ),
            Text(
              '$operator ${formatCurrency.format(txn.amount)}',
              style: TextStyle(
                  color: amountColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    )
        .animate(key: ValueKey(txn.id))
        .fadeIn(delay: (30 * (index < 10 ? index : 0)).ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildFilterRow() {
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
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
                        value: i + 1, child: Text(monthNames[i]))),
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
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: TextField(
        controller: c.searchController,
        onChanged: c.updateSearch,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Cari transaksi...',
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

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: AppColors.card,
      title: 'Hapus Transaksi',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus data ini?',
      middleTextStyle:
          TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      textCancel: 'Batal',
      cancelTextColor: AppColors.primary,
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        c.deleteTransaction(id);
      },
    );
  }
}
