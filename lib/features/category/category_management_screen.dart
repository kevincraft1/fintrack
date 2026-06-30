import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'category_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';

class CategoryManagementScreen extends StatelessWidget {
  final CategoryController c = Get.put(CategoryController());

  CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Kategori', style: TextStyle(fontSize: 20.sp)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        onPressed: () => _showAddCategorySheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (c.categories.isEmpty) return const SizedBox();
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: c.categories.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final cat = c.categories[index];
            final isIncome = cat.type == 'income';

            return Ink(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(IconMapper.getIcon(cat.iconName),
                      color: isIncome ? AppColors.primary : AppColors.error),
                ),
                title: Text(cat.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
                subtitle: Text(isIncome ? 'Pemasukan' : 'Pengeluaran',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.sp)),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => c.deleteCategory(cat.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    final nameController = TextEditingController();
    var selectedType = 'expense'.obs;
    var selectedIcon = 'category'.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.w,
          bottom: 24.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nama Kategori (mis. Belanja)',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => RadioListTile<String>(
                          title: Text('Pengeluaran',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp)),
                          value: 'expense',
                          groupValue: selectedType.value,
                          activeColor: AppColors.error,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => selectedType.value = val!,
                        )),
                  ),
                  Expanded(
                    child: Obx(() => RadioListTile<String>(
                          title: Text('Pemasukan',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp)),
                          value: 'income',
                          groupValue: selectedType.value,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => selectedType.value = val!,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text('Pilih Ikon',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14.sp)),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: IconMapper.availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconName = IconMapper.availableIcons[index];
                    return Obx(() => GestureDetector(
                          onTap: () => selectedIcon.value = iconName,
                          child: Container(
                            margin: EdgeInsets.only(right: 12.w),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: selectedIcon.value == iconName
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selectedIcon.value == iconName
                                      ? AppColors.primary
                                      : Colors.transparent),
                            ),
                            child: Icon(IconMapper.getIcon(iconName),
                                color: selectedIcon.value == iconName
                                    ? AppColors.primary
                                    : AppColors.textPrimary),
                          ),
                        ));
                  },
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      c.addCategory(nameController.text, selectedType.value,
                          selectedIcon.value);
                    }
                  },
                  child: Text('Simpan Kategori',
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
}
