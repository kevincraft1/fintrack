import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'goal_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/goal.dart';
import '../../core/widgets/version_footer.dart';

class GoalScreen extends StatelessWidget {
  final GoalController c = Get.put(GoalController());
  static final _formatCurrency =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  GoalScreen({super.key});

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
        title: Text('Tabungan Impian',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF59E0B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
      body: Obx(() {
        if (c.goals.isEmpty) return _buildEmptyState(context);
        return _buildGoalList();
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded,
                size: 48.sp, color: const Color(0xFFF59E0B)),
          ),
          SizedBox(height: 24.h),
          Text(
            'Belum Ada Impian',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Ayo buat target tabungan impianmu dan mulai menabung sedikit demi sedikit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            icon: Icon(Icons.add_circle_outline, size: 18.sp),
            label: Text('Buat Impian',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildGoalList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      itemCount: c.goals.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        if (index == c.goals.length) return VersionFooter();

        final goal = c.goals[index];
        final progress = goal.targetAmount > 0
            ? (goal.savedAmount / goal.targetAmount)
            : 0.0;
        final isCompleted = progress >= 1.0;
        final deadlineStr = DateFormat('dd MMM yyyy').format(goal.deadline);

        return InkWell(
          onTap: () => isCompleted ? null : _showTopUpSheet(context, goal),
          onLongPress: () => _confirmDelete(context, goal.id),
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981).withOpacity(0.5)
                      : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFFF59E0B).withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(isCompleted ? Icons.check_circle : Icons.star,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.name,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 2.h),
                          Text('Target: $deadlineStr',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp)),
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r)),
                        child: Text('Nabung',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatCurrency.format(goal.savedAmount),
                        style: TextStyle(
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold)),
                    Text(_formatCurrency.format(goal.targetAmount),
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.sp)),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    minHeight: 8.h,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B)),
                  ),
                ),
                SizedBox(height: 8.h),
                Text('${(progress * 100).toStringAsFixed(1)}% Terkumpul',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
      },
    );
  }

  void _showAddGoalSheet(BuildContext context) {
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
              Text('Target Impian Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                  controller: c.nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      hintText: 'Nama Impian (Cth: Beli Motor)',
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none))),
              SizedBox(height: 12.h),
              TextField(
                  controller: c.targetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      hintText: 'Target Nominal (Rp)',
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none))),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => c.pickDeadline(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16.r)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary),
                    SizedBox(width: 12.w),
                    Obx(() => Text(
                        c.selectedDeadline.value == null
                            ? 'Target Tanggal'
                            : DateFormat('dd MMM yyyy')
                                .format(c.selectedDeadline.value!),
                        style: TextStyle(
                            color: c.selectedDeadline.value == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontSize: 14.sp))),
                  ]),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r))),
                      onPressed: c.saveGoal,
                      child: Text('Simpan Impian',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTopUpSheet(BuildContext context, Goal goal) {
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
              Text('Nabung untuk ${goal.name}',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                  controller: c.topUpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      hintText: 'Nominal Nabung (Rp)',
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none))),
              SizedBox(height: 12.h),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16.r)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        isExpanded: true,
                        dropdownColor: AppColors.card,
                        hint: Text('Pilih Dompet Sumber',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp)),
                        value: c.selectedWallet.value,
                        items: c.wallets
                            .map((w) => DropdownMenuItem(
                                value: w,
                                child: Text('${w.name} (Rp ${w.balance})',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp))))
                            .toList(),
                        onChanged: (val) => c.selectedWallet.value = val,
                      ),
                    ),
                  )),
              SizedBox(height: 32.h),
              SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r))),
                      onPressed: () => c.topUpGoal(goal),
                      child: Text('Tambahkan Saldo',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
        backgroundColor: AppColors.card,
        title: 'Hapus Impian',
        titleStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold),
        middleText: 'Yakin ingin menghapus target ini?',
        middleTextStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        textCancel: 'Batal',
        cancelTextColor: AppColors.primary,
        textConfirm: 'Hapus',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.error,
        onConfirm: () {
          Get.back();
          c.deleteGoal(id);
        });
  }
}
