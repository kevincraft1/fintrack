import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../input_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';

class CategoryRow extends StatelessWidget {
  final InputController c = Get.find();

  CategoryRow({super.key});

  // Fungsi pelindung (Safe Parser) untuk mencegah crash dari data Isar lama
  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary; // Warna default jika string rusak/kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Sembunyikan kategori sepenuhnya jika mode Transfer
      if (c.selectedType.value == 'transfer') {
        return const SizedBox();
      }

      return GestureDetector(
        onTap: () => _showCategoryPicker(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Obx(() {
                final cat = c.selectedCategory.value;
                // Eksekusi fungsi pelindung
                final color =
                    cat != null ? _parseColor(cat.colorHex) : AppColors.primary;

                return Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat != null
                        ? IconMapper.getIcon(cat.iconName)
                        : Icons.category,
                    color: color,
                    size: 20.sp,
                  ),
                );
              }),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11.sp)),
                    Obx(() => Text(
                          c.selectedCategory.value?.name ?? 'Pilih Kategori',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary, size: 20.sp),
            ],
          ),
        ),
      );
    });
  }

  void _showCategoryPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Obx(() {
              if (c.categories.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const Center(
                      child: Text('Tidak ada kategori',
                          style: TextStyle(color: AppColors.textSecondary))),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                ),
                itemCount: c.categories.length,
                itemBuilder: (context, index) {
                  final cat = c.categories[index];
                  // Gunakan fungsi pelindung pada GridView
                  final catColor = _parseColor(cat.colorHex);

                  return GestureDetector(
                    onTap: () {
                      c.selectedCategory.value = cat;
                      Get.back();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(IconMapper.getIcon(cat.iconName),
                              color: catColor, size: 24.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          cat.name,
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 10.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
