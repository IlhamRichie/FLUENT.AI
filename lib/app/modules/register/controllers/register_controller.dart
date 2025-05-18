// lib/app/modules/register/controllers/register_controller.dart
import 'dart:async';
// import 'dart:convert'; // Tidak digunakan di sini jika tidak ada user_data dari Google
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();

  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final RxString selectedGender = 'Pria'.obs;
  final List<String> genders = ['Pria', 'Wanita', 'Lainnya'];
  
  final RxString selectedJob = 'Pelajar/Mahasiswa'.obs;
  final List<String> jobs = ['Pelajar/Mahasiswa', 'Karyawan Swasta', 'Profesional', 'Wiraswasta', 'Lainnya'];

  final RxBool obscureText = true.obs;
  final RxBool obscureConfirmText = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Color get primaryColor => const Color(0xFFD84040);

  final RxInt currentTextIndex = 0.obs;
   final List<String> headerTexts = [
    "Satu langkah lagi menuju kefasihan! 🌟",
    "Bergabunglah dengan komunitas pembelajar kami. 🤝",
    "Fluent AI siap membantumu setiap saat! 💡",
  ];
  Timer? _textRotationTimer;

  @override
  void onInit() {
    super.onInit();
    _startTextRotation();
  }

  @override
  void onClose() {
    _textRotationTimer?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

   void _startTextRotation() {
    if (_textRotationTimer == null || !_textRotationTimer!.isActive) {
      _textRotationTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (headerTexts.isNotEmpty) {
          currentTextIndex.value = (currentTextIndex.value + 1) % headerTexts.length;
        }
      });
    }
  }

  void _handleApiError(dynamic e, String defaultMessage) {
    String messageToShow = defaultMessage;
    if (e is Map && e.containsKey('message') && e['message'] != null) {
      messageToShow = e['message'].toString();
    } else if (e is String && e.isNotEmpty) {
      messageToShow = e;
    }
    errorMessage.value = messageToShow;
    debugPrint('API Error (Register): $e');
  }

  void _showSuccessSnackbar(String title, String message) {
     Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade600,
      colorText: Colors.white, borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.partyPopper, color: Colors.white),
    );
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;
  void toggleConfirmPasswordVisibility() => obscureConfirmText.value = !obscureConfirmText.value;

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Nama lengkap tidak boleh kosong.';
    if (value.length < 3) return 'Nama minimal 3 karakter.';
    errorMessage.value = ''; return null;
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong.';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid.';
    errorMessage.value = ''; return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    if (value.length < 6) return 'Password minimal 6 karakter.';
    errorMessage.value = ''; return null;
  }
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong.';
    if (value != passwordController.text) return 'Password tidak cocok.';
    errorMessage.value = ''; return null;
  }

  Future<void> register() async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.register(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        gender: selectedGender.value,
        occupation: selectedJob.value,
      );

      if (response['status'] == 'success') {
        _showSuccessSnackbar("Registrasi Berhasil!", response['message'] ?? "Akun Anda telah berhasil dibuat. Silakan login.");
        Get.offNamed(Routes.LOGIN);
      } else {
        _handleApiError(response, response['message'] ?? 'Registrasi gagal. Coba lagi.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi kesalahan. Silakan coba lagi nanti.');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> registerWithGoogle() async {
    isGoogleLoading.value = true;
    errorMessage.value = '';
    // ================== PERBAIKAN DIALOG ==================
    Get.dialog(
      Dialog( // Tambahkan widget Dialog di sini
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                const Text("Menghubungkan dengan Google...", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    // ================== AKHIR PERBAIKAN DIALOG ==================
    try {
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // Tutup dialog
      _handleApiError({}, "Fitur Daftar dengan Google belum diimplementasikan.");
    } catch (e) {
      Get.back(); // Pastikan dialog ditutup jika ada error juga
      _handleApiError(e, 'Gagal daftar dengan Google.');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void navigateToLogin() {
    Get.back(); 
  }
}