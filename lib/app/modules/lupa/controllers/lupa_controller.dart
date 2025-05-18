// lib/app/modules/lupa/controllers/lupa_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:fluent_ai/app/data/services/api_service.dart'; // Jika ada API call

class LupaPasswordController extends GetxController { // Ganti nama class jika perlu
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  // Ambil primaryColor dari tema GetX atau definisikan manual
  Color get primaryColor => Get.theme.colorScheme.primary;
  // final Color primaryColor = const Color(0xFFD84040); // Atau definisikan manual

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  Future<void> sendResetLink() async {
    if (!(forgotPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    successMessage.value = '';
    errorMessage.value = '';

    try {
      // --- Simulasi API Call ---
      await Future.delayed(const Duration(seconds: 2));
      // Ganti dengan pemanggilan ApiService.forgotPassword(email: emailController.text.trim());
      
      // Contoh response sukses
      final String userEmail = emailController.text.trim();
      successMessage.value = "Link reset password telah dikirim ke $userEmail. Silakan periksa kotak masuk dan folder spam Anda.";
      
      // Contoh response error dari backend (jika email tidak terdaftar)
      // errorMessage.value = "Email tidak terdaftar di sistem kami.";
      // _showErrorSnackbar(errorMessage.value);

    } catch (e) {
      errorMessage.value = "Terjadi kesalahan. Silakan coba lagi nanti.";
      debugPrint("Forgot Password Error: $e");
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
     Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void backToLogin() {
    Get.back(); // Kembali ke halaman sebelumnya (login)
  }
}