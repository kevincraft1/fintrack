import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/database_service.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';

class BackupController extends GetxController {
  Future<void> exportDatabase() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/default.isar';
      final file = File(dbPath);

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(dbPath)],
          text: 'Backup Database FinTrack Pro',
        );
      } else {
        _showError('File database tidak ditemukan.');
      }
    } catch (e) {
      _showError('Gagal melakukan backup: $e');
    }
  }

  Future<void> importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final importPath = result.files.single.path!;

        if (!importPath.endsWith('.isar')) {
          _showError('File tidak valid. Harap pilih file .isar');
          return;
        }

        await DatabaseService.isar.close();

        final dir = await getApplicationDocumentsDirectory();
        final dbPath = '${dir.path}/default.isar';

        final importFile = File(importPath);
        await importFile.copy(dbPath);

        await DatabaseService.init();

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadHomeData();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfileStats();
        }

        Get.snackbar(
          'Restore Berhasil',
          'Data keuangan Anda telah dipulihkan.',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      await DatabaseService.init();
      _showError('Gagal memulihkan data: $e');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Terjadi Kesalahan',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
