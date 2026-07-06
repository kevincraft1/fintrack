import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/database_service.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';

class BackupController extends GetxController {
  static const String _secretKey = 'F1nTr4ckPr0_3nt3rpr1s3_K3y_2026';

  Future<void> exportDatabase() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/default.isar';
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        final bytes = await dbFile.readAsBytes();
        final encryptedBytes = _processBytes(bytes);

        final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final backupPath = '${dir.path}/FinTrack_$dateStr.fintrack';
        final backupFile = File(backupPath);

        await backupFile.writeAsBytes(encryptedBytes);

        await Share.shareXFiles(
          [XFile(backupPath)],
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

        if (!importPath.endsWith('.fintrack')) {
          _showError('File tidak valid. Harap pilih file .fintrack');
          return;
        }

        final importFile = File(importPath);
        final encryptedBytes = await importFile.readAsBytes();
        final decryptedBytes = _processBytes(encryptedBytes);

        await DatabaseService.isar.close();

        final dir = await getApplicationDocumentsDirectory();
        final dbPath = '${dir.path}/default.isar';
        final dbFile = File(dbPath);

        await dbFile.writeAsBytes(decryptedBytes);
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
      _showError('Gagal memulihkan data. File korup atau tidak valid.');
    }
  }

  Uint8List _processBytes(List<int> bytes) {
    final keyUnits = _secretKey.codeUnits;
    final result = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ keyUnits[i % keyUnits.length];
    }
    return result;
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
