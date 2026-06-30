import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';
import 'history_controller.dart';
import 'package:isar/isar.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final HistoryController historyC = Get.find<HistoryController>();

  late TextEditingController amountController;
  late TextEditingController noteController;

  Category? selectedCategory;
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
        text: widget.transaction.amount.toInt().toString());
    noteController = TextEditingController(text: widget.transaction.note ?? '');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final txnType = widget.transaction.category.value?.type ?? 'expense';
    final data = await DatabaseService.isar.categorys
        .filter()
        .typeEqualTo(txnType)
        .findAll();

    setState(() {
      categories = data;
      // SOLUSI MUTLAK: Mencocokkan ID agar memory instance sama persis dengan list Dropdown
      final txnCategoryId = widget.transaction.category.value?.id;
      selectedCategory =
          categories.firstWhereOrNull((c) => c.id == txnCategoryId) ??
              (categories.isNotEmpty ? categories.first : null);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (selectedCategory == null) return;
    final newAmount = double.tryParse(amountController.text) ?? 0;
    if (newAmount <= 0) {
      Get.snackbar('Nominal Invalid', 'Masukkan nominal yang benar.',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    final txn =
        await DatabaseService.isar.transactions.get(widget.transaction.id);
    if (txn != null) {
      txn.amount = newAmount;
      txn.note = noteController.text.trim();
      txn.category.value = selectedCategory;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactions.put(txn);
        await txn.category.save();
      });

      historyC.fetchTransactions(); // Segarkan riwayat
      Get.back(); // Kembali ke layar sebelumnya

      Get.snackbar(
        'Diperbarui',
        'Data transaksi berhasil diubah.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.category.value?.type == 'income';

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
        title: Text('Edit Transaksi',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Nominal'),
                  _buildAmountField(isIncome)
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.1),
                  SizedBox(height: 24.h),
                  _buildInputLabel('Kategori'),
                  _buildCategoryDropdown()
                      .animate()
                      .fadeIn(delay: 150.ms)
                      .slideY(begin: 0.1),
                  SizedBox(height: 24.h),
                  _buildInputLabel('Catatan (Opsional)'),
                  _buildNoteField()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1),
                  SizedBox(height: 48.h),
                  _buildSaveButton()
                      .animate()
                      .fadeIn(delay: 250.ms)
                      .scaleXY(begin: 0.9, end: 1.0),
                ],
              ),
            ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text,
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildAmountField(bool isIncome) {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      style: TextStyle(
          color: isIncome ? AppColors.primary : AppColors.error,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: TextStyle(
            color: isIncome ? AppColors.primary : AppColors.error,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(20.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          value: selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.card,
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary, size: 24.sp),
          items: categories.map((cat) {
            return DropdownMenuItem<Category>(
              value: cat,
              child: Row(
                children: [
                  Icon(IconMapper.getIcon(cat.iconName),
                      color: AppColors.textPrimary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(cat.name,
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 16.sp)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: noteController,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Tulis deskripsi...',
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: Text('Simpan Perubahan',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
