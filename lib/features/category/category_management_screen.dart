import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'category_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/icon_mapper.dart';

class CategoryManagementScreen extends StatelessWidget {
  final CategoryController c = Get.put(CategoryController());

  CategoryManagementScreen({super.key});

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
        title: Text('Kelola Kategori',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 4,
        onPressed: () => _showAddCategorySheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
      body: Column(
        children: [
          _buildTypeToggle().animate().fadeIn().slideY(begin: -0.1),
          Expanded(
            child: Obx(() {
              if (c.categories.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada kategori.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                ).animate().fadeIn();
              }
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                itemCount: c.categories.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final cat = c.categories[index];
                  final isIncome = cat.type == 'income';

                  return InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {},
                    child: Ink(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        leading: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconMapper.getIcon(cat.iconName),
                            color:
                                isIncome ? AppColors.primary : AppColors.error,
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isIncome ? 'Pemasukan' : 'Pengeluaran',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.sp),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () => _confirmDelete(context, cat.id),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                  child: _buildToggleBtn('Pengeluaran', 'expense',
                      c.selectedType.value == 'expense')),
              Expanded(
                  child: _buildToggleBtn(
                      'Pemasukan', 'income', c.selectedType.value == 'income')),
            ],
          )),
    );
  }

  Widget _buildToggleBtn(String title, String type, bool isSelected) {
    return GestureDetector(
      onTap: () => c.setType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: AppColors.card,
      title: 'Hapus Kategori',
      titleStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus kategori ini?',
      middleTextStyle:
          TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      textCancel: 'Batal',
      cancelTextColor: AppColors.primary,
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        c.deleteCategory(id);
      },
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
          top: 24.h,
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
                      borderRadius: BorderRadius.circular(16.r),
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
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: IconMapper.availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconName = IconMapper.availableIcons[index];
                    return Obx(() => GestureDetector(
                          onTap: () => selectedIcon.value = iconName,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      // SOLUSI: Selaraskan tipe di controller sebelum memanggil addCategory (2 argumen)
                      c.selectedType.value = selectedType.value;
                      c.addCategory(
                          nameController.text.trim(), selectedIcon.value);
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
