import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import 'history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final HistoryController c = Get.find<HistoryController>();
  late TextEditingController amountController;
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
        text: widget.transaction.amount.toInt().toString());
    selectedCategory = widget.transaction.category.value;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter kategori agar sesuai dengan tipe (income/expense) dari transaksi saat ini
    final filteredCategories = c.categories
        .where((cat) => cat.type == selectedCategory?.type)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaksi', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nominal (Rp)',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Kategori',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: filteredCategories
                          .any((cat) => cat.id == selectedCategory?.id)
                      ? selectedCategory
                      : null,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppColors.textPrimary),
                  items: filteredCategories.map((cat) {
                    return DropdownMenuItem<Category>(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(IconMapper.getIcon(cat.iconName),
                              color: cat.type == 'income'
                                  ? AppColors.primary
                                  : AppColors.error,
                              size: 20.sp),
                          SizedBox(width: 12.w),
                          Text(cat.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Category? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: () {
                  final newAmount = double.tryParse(amountController.text) ?? 0;
                  if (newAmount > 0 && selectedCategory != null) {
                    c.updateTransaction(
                        widget.transaction.id, newAmount, selectedCategory!);
                  }
                },
                child: Text('Simpan Perubahan',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
