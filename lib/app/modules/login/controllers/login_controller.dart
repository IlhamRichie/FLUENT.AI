// lib/app/modules/login/controllers/login_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:fluent_ai/app/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Import LucideIcons

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final UserService _userService;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool obscureText = true.obs;
  final RxInt currentTextIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Color get primaryColor => const Color(0xFFD84040); // Definisikan warna utama di sini

  final List<String> footerTexts = [
    "Tingkatkan skill komunikasimu ke level berikutnya! 🚀",
    "Latihan dengan AI, dapatkan feedback instan. 🤖",
    "Analisis ekspresi dan intonasimu secara mendalam. 🎤",
    "Persiapkan diri untuk wawancara kerja impianmu! 💼",
    "Menuju kefasihan berbicara dengan percaya diri. ✨",
  ];
  Timer? _textRotationTimer;

  @override
  void onInit() {
    super.onInit();
    _userService = Get.find<UserService>();
    _startTextRotation();
    _checkAutoLogin();
  }

  @override
  void onClose() {
    _textRotationTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _startTextRotation() {
    if (_textRotationTimer == null || !_textRotationTimer!.isActive) {
      _textRotationTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (footerTexts.isNotEmpty) {
          currentTextIndex.value = (currentTextIndex.value + 1) % footerTexts.length;
        }
      });
    }
  }

  Future<void> _checkAutoLogin() async {
    isLoading.value = true;
    try {
      final token = await _storage.read(key: 'access_token');
      final storedUserData = await _storage.read(key: 'user_data');

      if (token != null && token.isNotEmpty && storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;
        _userService.setUserData(
          username: userDataMap['username'] ?? '', email: userDataMap['email'] ?? '',
          avatar: userDataMap['avatar_url'], occupation: userDataMap['occupation'],
          gender: userDataMap['gender'],
        );
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      debugPrint("Auto login check failed: $e");
      await _storage.deleteAll(); // Hapus semua data jika auto login gagal/korup
    } finally {
      // Beri sedikit jeda agar animasi loading awal terlihat jika auto login cepat
      await Future.delayed(const Duration(milliseconds: 800));
      isLoading.value = false;
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
    debugPrint('API Error: $e');
  }

  void _showSuccessSnackbar(String title, String message) {
     Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade600,
      colorText: Colors.white, borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.checkCircle, color: Colors.white), // Menggunakan LucideIcons
    );
  }
  
  void _showErrorSnackbar(String message) { // Untuk validasi form error
    Get.snackbar(
      'Input Tidak Valid', message,
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange.shade700,
      colorText: Colors.white, borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.alertCircle, color: Colors.white),
    );
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

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

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      // Pesan error validasi sudah dihandle oleh TextFormField, atau bisa tambahkan snackbar umum
      // _showErrorSnackbar("Harap periksa kembali input Anda.");
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = ''; 
    
    try {
      final response = await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response['status'] == 'success' && response.containsKey('access_token') && response.containsKey('user')) {
        await _storage.write(key: 'access_token', value: response['access_token']);
        if (response.containsKey('refresh_token')) {
          await _storage.write(key: 'refresh_token', value: response['refresh_token']);
        }
        
        final userDataMap = response['user'] as Map<String, dynamic>;
        await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

        _userService.setUserData(
          username: userDataMap['username'] ?? emailController.text.split('@').first,
          email: userDataMap['email'] ?? emailController.text.trim(),
          avatar: userDataMap['avatar_url'], occupation: userDataMap['occupation'],
          gender: userDataMap['gender'],
        );
        
        _showSuccessSnackbar("Login Berhasil!", "Selamat datang kembali, ${userDataMap['username'] ?? ''}!");
        Get.offAllNamed(Routes.HOME);
      } else {
        _handleApiError(response, response['message'] ?? 'Email atau password tidak cocok.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi gangguan koneksi. Silakan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    errorMessage.value = '';
    // ... (Logika dialog loading yang lebih baik)
    Get.dialog(
      // ... (Dialog loading seperti di contoh sebelumnya)
      Dialog( /* ... */ ), barrierDismissible: false,
    );
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulasi
      Get.back(); // Tutup dialog
      // Get.offAllNamed(Routes.HOME); // Jika sukses
       _handleApiError({}, "Fitur Login Google belum diimplementasikan sepenuhnya.");
    } catch (e) {
      Get.back();
      _handleApiError(e, 'Gagal login dengan Google.');
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void navigateToRegister() => Get.toNamed(Routes.REGISTER);
  void navigateToForgotPassword() => Get.toNamed(Routes.LUPA);
}