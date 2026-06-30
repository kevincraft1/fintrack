import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

class SecurityController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  var isAuthenticated = false.obs;
  var isSupported = false.obs;
  var isAppLockEnabled = false.obs; // Secara default, kunci mati

  @override
  void onInit() {
    super.onInit();
    _loadSettingsAndVerify();
  }

  Future<void> _loadSettingsAndVerify() async {
    final prefs = await SharedPreferences.getInstance();
    // Tarik preferensi terakhir dari memori fisik Android
    isAppLockEnabled.value = prefs.getBool('app_lock_enabled') ?? false;

    try {
      final hasHardware = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      isSupported.value = hasHardware || isDeviceSupported;

      if (isSupported.value && isAppLockEnabled.value) {
        executeAuthentication(); // Jika aktif, tahan di layar kunci
      } else {
        isAuthenticated.value = true; // Jika mati, bypass langsung ke Home
      }
    } catch (_) {
      isAuthenticated.value = true;
    }
  }

  Future<void> executeAuthentication() async {
    try {
      final success = await auth.authenticate(
        localizedReason:
            'Pindai sidik jari atau gunakan PIN keamanan untuk masuk',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      isAuthenticated.value = success;
    } catch (_) {
      isAuthenticated.value = false;
    }
  }

  Future<void> toggleAppLock(bool value) async {
    try {
      // Wajibkan verifikasi biometrik sebelum mengubah pengaturan
      final success = await auth.authenticate(
        localizedReason: value
            ? 'Verifikasi identitas untuk mengaktifkan kunci'
            : 'Verifikasi identitas untuk mematikan kunci',
        options:
            const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );

      if (success) {
        isAppLockEnabled.value = value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('app_lock_enabled', value);
      }
    } catch (_) {
      Get.snackbar(
        'Gagal',
        'Verifikasi dibatalkan.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
