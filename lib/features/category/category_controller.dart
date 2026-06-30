import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../data/database_service.dart';
import '../../data/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../input/input_controller.dart';

class CategoryController extends GetxController {
  var categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await DatabaseService.isar.categorys.where().anyId().findAll();
    categories.assignAll(data);
  }

  Future<void> addCategory(String name, String type, String iconName) async {
    final newCategory = Category()
      ..name = name
      ..type = type
      ..iconName = iconName;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.categorys.put(newCategory);
    });

    loadCategories();

    if (Get.isRegistered<InputController>()) {
      Get.find<InputController>().loadCategories();
    }

    Get.back();
    Get.snackbar(
      'Sukses',
      'Kategori baru berhasil ditambahkan.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: AppColors.textPrimary,
    );
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.categorys.delete(id);
    });

    loadCategories();

    if (Get.isRegistered<InputController>()) {
      Get.find<InputController>().loadCategories();
    }

    Get.snackbar(
      'Terhapus',
      'Kategori berhasil dihapus.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.textPrimary,
    );
  }
}
