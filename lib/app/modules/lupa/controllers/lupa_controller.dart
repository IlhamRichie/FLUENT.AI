// lib/app/modules/lupa/controllers/lupa_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart'; // Impor ApiService

class LupaPasswordController extends GetxController {
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  final Color primaryColor = const Color(0xFFD84040); // Warna utama dari FluentAI

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
    errorMessage.value = ''; // Bersihkan error jika validasi lolos
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
      final response = await ApiService.requestPasswordReset(emailController.text.trim());

      if (response['status'] == 'success') {
        successMessage.value = response['message'] ?? // Ambil pesan dari backend
            "Tautan reset password telah dikirim ke ${emailController.text.trim()}. Silakan periksa kotak masuk dan folder spam Anda.";
      } else {
        // Jika status bukan 'success', anggap sebagai error
        errorMessage.value = response['message'] ?? "Gagal mengirim link reset. Email mungkin tidak terdaftar.";
        // _showErrorSnackbar(errorMessage.value); // Snackbar sudah ditangani oleh _handleApiError jika throw
      }
    } catch (e) {
      // Tangani error yang di-throw oleh _handleRequest (misal SocketException, TimeoutException, atau Map error)
      String errorMsgToShow = "Terjadi kesalahan. Silakan coba lagi nanti.";
      if (e is Map && e.containsKey('message')) {
        errorMsgToShow = e['message'];
      } else if (e is String) {
        errorMsgToShow = e;
      }
      errorMessage.value = errorMsgToShow;
      debugPrint("Forgot Password Error: $e");
      // Tidak perlu _showErrorSnackbar lagi jika errorMessage.value sudah di-set dan UI akan rebuild
    } finally {
      isLoading.value = false;
    }
  }

  // Snackbar bisa dihilangkan jika errorMessage sudah ditampilkan di UI
  // void _showErrorSnackbar(String message) {
  //   Get.snackbar(
  //     'Gagal',
  //     message,
  //     snackPosition: SnackPosition.TOP,
  //     backgroundColor: Colors.red.shade600,
  //     colorText: Colors.white,
  //     borderRadius: 10,
  //     margin: const EdgeInsets.all(12),
  //     icon: const Icon(LucideIcons.alertTriangle, color: Colors.white), // Menggunakan LucideIcons
  //   );
  // }

  void backToLogin() {
    // Sebelum kembali, reset state agar form bersih jika user kembali ke halaman ini
    emailController.clear();
    successMessage.value = '';
    errorMessage.value = '';
    isLoading.value = false;
    if (forgotPasswordFormKey.currentState != null) {
        forgotPasswordFormKey.currentState!.reset();
    }
    Get.back();
  }
}