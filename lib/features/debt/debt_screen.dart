import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'debt_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/debt.dart';

class DebtScreen extends StatelessWidget {
  final DebtController c = Get.put(DebtController());
  static final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Manajemen Hutang Piutang',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (c.debts.isEmpty) return _buildEmptyState();
        return _buildDebtList();
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDebtDialog(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('Belum ada data kewajiban atau aset tertunda.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
    );
  }

  Widget _buildDebtList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      itemCount: c.debts.length,
      itemBuilder: (context, index) {
        final debt = c.debts[index];
        final isDebt = debt.type == 'debt';
        final color = isDebt ? AppColors.error : const Color(0xFF10B981);
        final typeLabel = isDebt ? 'Kewajiban (Hutang)' : 'Aset (Piutang)';
        final progress = debt.totalAmount > 0
            ? (1 - (debt.remainingAmount / debt.totalAmount))
            : 1.0;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: debt.isSettled
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(debt.personName,
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 2.h),
                        Text(
                            '$typeLabel • Tenggat: ${DateFormat('dd MMM yyyy').format(debt.dueDate)}',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.textSecondary),
                    onPressed: () => c.deleteDebt(debt.id),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_currencyFormat.format(debt.remainingAmount),
                      style: TextStyle(
                          color: color,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold)),
                  if (!debt.isSettled)
                    GestureDetector(
                      onTap: () => _showPayDebtDialog(context, debt),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Text('Bayar/Cicil',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (debt.isSettled)
                    Text('LUNAS',
                        style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900)),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6.h,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    c.nameController.clear();
    c.amountController.clear();
    c.selectedDueDate.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Catatan Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => GestureDetector(
                          onTap: () => c.selectedType.value = 'debt',
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: c.selectedType.value == 'debt'
                                  ? AppColors.error.withOpacity(0.2)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: c.selectedType.value == 'debt'
                                      ? AppColors.error
                                      : Colors.transparent),
                            ),
                            alignment: Alignment.center,
                            child: Text('Saya Berhutang',
                                style: TextStyle(
                                    color: c.selectedType.value == 'debt'
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => GestureDetector(
                          onTap: () => c.selectedType.value = 'receivable',
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: c.selectedType.value == 'receivable'
                                  ? const Color(0xFF10B981).withOpacity(0.2)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: c.selectedType.value == 'receivable'
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent),
                            ),
                            alignment: Alignment.center,
                            child: Text('Memberi Pinjaman',
                                style: TextStyle(
                                    color: c.selectedType.value == 'receivable'
                                        ? const Color(0xFF10B981)
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: c.nameController,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Nama Pihak Terkait',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: c.amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12.r)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        isExpanded: true,
                        dropdownColor: AppColors.card,
                        hint: Text('Pilih Sumber Dompet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp)),
                        value: c.selectedWallet.value,
                        items: c.wallets
                            .map((w) => DropdownMenuItem(
                                value: w,
                                child: Text(
                                    '${w.name} (${_currencyFormat.format(w.balance)})',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp))))
                            .toList(),
                        onChanged: (val) => c.selectedWallet.value = val,
                      ),
                    ),
                  )),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => c.pickDueDate(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() => Text(
                              c.selectedDueDate.value == null
                                  ? 'Pilih Tenggat Waktu'
                                  : DateFormat('dd MMM yyyy')
                                      .format(c.selectedDueDate.value!),
                              style: TextStyle(
                                  color: c.selectedDueDate.value == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                  fontSize: 14.sp),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: c.saveDebt,
                  child: Text('Simpan Data',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showPayDebtDialog(BuildContext context, Debt debt) {
    c.payAmountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proses Transaksi Parsial',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            TextField(
              controller: c.payAmountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              decoration: InputDecoration(
                labelText: 'Nominal Cicilan / Pelunasan (Rp)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12.r)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                      isExpanded: true,
                      dropdownColor: AppColors.card,
                      hint: Text('Pilih Dompet Eksekutor',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14.sp)),
                      value: c.selectedWallet.value,
                      items: c.wallets
                          .map((w) => DropdownMenuItem(
                              value: w,
                              child: Text(
                                  '${w.name} (${_currencyFormat.format(w.balance)})',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.sp))))
                          .toList(),
                      onChanged: (val) => c.selectedWallet.value = val,
                    ),
                  ),
                )),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => c.payDebt(debt),
                child: Text('Konfirmasi Pembayaran',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
