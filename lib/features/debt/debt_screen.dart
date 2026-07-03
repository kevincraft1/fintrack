import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'debt_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/version_footer.dart';

class DebtScreen extends StatelessWidget {
  final DebtController c = Get.put(DebtController());

  DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: Text('Hutang & Piutang',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Piutang (Uang di luar)'),
              Tab(text: 'Hutang (Pinjaman)'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          onPressed: () => _showAddDebtSheet(context),
          child: const Icon(Icons.add, color: Colors.white),
        ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildDebtList(true), // Piutang
            _buildDebtList(false), // Hutang
          ],
        ),
      ),
    );
  }

  Widget _buildDebtList(bool isLend) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Obx(() {
      final list = isLend ? c.lentList : c.borrowedList;

      if (list.isEmpty) {
        return Center(
          child: Text(
              isLend ? 'Belum ada piutang.' : 'Tidak ada hutang. Bagus!',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        ).animate().fadeIn();
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        itemCount: list.length + 1, // +1 untuk footer
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == list.length) {
            return Padding(
                padding: EdgeInsets.only(top: 24.h), child: VersionFooter());
          }

          final debt = list[index];
          final color = debt.isSettled
              ? AppColors.textSecondary
              : (isLend ? const Color(0xFF10B981) : AppColors.error);

          final dueDateStr = DateFormat('dd MMM yyyy').format(debt.dueDate);
          final isOverdue =
              !debt.isSettled && debt.dueDate.isBefore(DateTime.now());

          return InkWell(
            onLongPress: () => _confirmDelete(context, debt.id),
            borderRadius: BorderRadius.circular(16.r),
            child: Opacity(
              opacity: debt.isSettled ? 0.6 : 1.0,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: isOverdue
                          ? AppColors.error.withOpacity(0.3)
                          : Colors.transparent),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => c.toggleSettle(debt.id, debt.isSettled),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          color: debt.isSettled ? color : Colors.transparent,
                        ),
                        child: Icon(Icons.check,
                            size: 16.sp,
                            color: debt.isSettled
                                ? Colors.white
                                : Colors.transparent),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(debt.personName,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  decoration: debt.isSettled
                                      ? TextDecoration.lineThrough
                                      : null)),
                          SizedBox(height: 4.h),
                          Text('Jatuh tempo: $dueDateStr',
                              style: TextStyle(
                                  color: isOverdue
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatCurrency.format(debt.totalAmount),
                            style: TextStyle(
                                color: color,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold)),
                        if (debt.isSettled)
                          Text('Lunas',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
        },
      );
    });
  }

  void _showAddDebtSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: 24.h + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catat Hutang/Piutang',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),

              // Toggle Type
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16.r)),
                child: Obx(() => Row(
                      children: [
                        _buildTypeOption('Piutang (Dihutangi)', 'lend',
                            const Color(0xFF10B981)),
                        _buildTypeOption(
                            'Hutang (Meminjam)', 'borrow', AppColors.error),
                      ],
                    )),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: c.nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                    hintText: 'Nama Orang / Instansi',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none)),
              ),
              SizedBox(height: 12.h),

              TextField(
                controller: c.amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                    hintText: 'Total Nominal (Rp)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none)),
              ),
              SizedBox(height: 12.h),

              GestureDetector(
                onTap: () => c.pickDueDate(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16.r)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.textSecondary),
                      SizedBox(width: 12.w),
                      Obx(() => Text(
                            c.selectedDueDate.value == null
                                ? 'Pilih Jatuh Tempo'
                                : DateFormat('dd MMM yyyy')
                                    .format(c.selectedDueDate.value!),
                            style: TextStyle(
                                color: c.selectedDueDate.value == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontSize: 14.sp),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                      elevation: 0),
                  onPressed: c.saveDebt,
                  child: Text('Simpan Catatan',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeOption(String title, String type, Color activeColor) {
    final isActive = c.selectedType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
              color:
                  isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r)),
          child: Center(
            child: Text(title,
                style: TextStyle(
                    color: isActive ? activeColor : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.sp)),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: AppColors.card,
      title: 'Hapus Catatan',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus catatan hutang ini?',
      middleTextStyle:
          TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      textCancel: 'Batal',
      cancelTextColor: AppColors.primary,
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        c.deleteDebt(id);
      },
    );
  }
}
