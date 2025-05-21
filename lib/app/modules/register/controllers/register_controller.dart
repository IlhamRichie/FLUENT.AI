// lib/app/modules/register/controllers/register_controller.dart
import 'dart:async';
// import 'dart:convert'; // Tidak digunakan
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Tambahkan ini
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk menyimpan data setelah login Google
import 'dart:convert'; // Untuk encode/decode JSON
import 'package:flutter/services.dart'; // Untuk PlatformException
import 'package:http/http.dart' as http_pkg; // Untuk ClientException
import 'dart:io'; // Untuk SocketException

class RegisterController extends GetxController {
  // final ApiService _apiService = ApiService(); // ApiService static, tidak perlu instance

  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString selectedGender = 'Pria'.obs;
  final List<String> genders = ['Pria', 'Wanita', 'Lainnya'];
  final RxString selectedJob = 'Pelajar/Mahasiswa'.obs;
  final List<String> jobs = [
    'Pelajar/Mahasiswa',
    'Karyawan Swasta',
    'Profesional',
    'Wiraswasta',
    'Lainnya'
  ];

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

  // Untuk Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    _textRotationTimer ??=
        Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (headerTexts.isNotEmpty) {
        currentTextIndex.value =
            (currentTextIndex.value + 1) % headerTexts.length;
      }
    });
  }

  void _handleApiError(dynamic e, String defaultMessage) {
    String messageToShow = defaultMessage;
    if (e is Map && e.containsKey('message') && e['message'] != null) {
      messageToShow = e['message'].toString();
    } else if (e is String && e.isNotEmpty) {
      messageToShow = e;
    } else if (e is http_pkg.ClientException) {
      messageToShow = "Terjadi gangguan koneksi. Periksa internet Anda.";
    } else if (e is SocketException) {
      messageToShow = "Tidak dapat terhubung ke server. Periksa koneksi Anda.";
    } else if (e is PlatformException) {
      if (e.code == 'sign_in_canceled') {
        messageToShow = 'Login Google dibatalkan.';
      } else if (e.code == 'network_error') {
        messageToShow =
            'Kesalahan jaringan saat login Google. Periksa koneksi Anda.';
      } else {
        messageToShow = 'Gagal login dengan Google: ${e.message ?? e.code}';
      }
    } else if (e is TimeoutException) {
      messageToShow = "Waktu koneksi habis. Silakan coba lagi.";
    }

    errorMessage.value = messageToShow;
    debugPrint('API Error (Register): $messageToShow. Original error: $e');
    Get.snackbar(
      'Registrasi Gagal',
      messageToShow,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.alertTriangle, color: Colors.white),
    );
    if (isLoading.value) isLoading.value = false;
    if (isGoogleLoading.value) isGoogleLoading.value = false;
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.partyPopper, color: Colors.white),
    );
  }

  Future<void> _processSuccessfulGoogleLogin(String accessToken,
      String? refreshToken, Map<String, dynamic> userDataMap) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

      errorMessage.value = '';
      _showSuccessSnackbar("Login Google Berhasil!",
          "Selamat datang, ${userDataMap['username'] ?? userDataMap['email'] ?? ''}!");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _handleApiError(e, "Gagal menyimpan sesi login Google Anda.");
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmText.value = !obscureConfirmText.value;
  String? validateUsername(String? value) {
    /* ... (tetap sama) ... */
    if (value == null || value.isEmpty)
      return 'Nama pengguna tidak boleh kosong.';
    if (value.length < 3) return 'Nama pengguna minimal 3 karakter.';
    errorMessage.value = '';
    return null;
  }

  String? validateEmail(String? value) {
    /* ... (tetap sama) ... */
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong.';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid.';
    errorMessage.value = '';
    return null;
  }

  String? validatePassword(String? value) {
    /* ... (tetap sama) ... */
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    if (value.length < 6) return 'Password minimal 6 karakter.';
    errorMessage.value = '';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    /* ... (tetap sama) ... */
    if (value == null || value.isEmpty)
      return 'Konfirmasi password tidak boleh kosong.';
    if (value != passwordController.text) return 'Password tidak cocok.';
    errorMessage.value = '';
    return null;
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
        _showSuccessSnackbar(
            "Registrasi Berhasil!",
            response['message'] ??
                "Akun Anda telah berhasil dibuat. Silakan login.");
        Get.offNamed(Routes.LOGIN);
      } else {
        _handleApiError(
            response, response['message'] ?? 'Registrasi gagal. Coba lagi.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi kesalahan koneksi. Silakan coba lagi nanti.');
    } finally {
      // isLoading.value = false; // Sudah dihandle di _handleApiError
    }
  }

  Future<void> registerWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    errorMessage.value = '';
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _handleApiError(PlatformException(code: 'sign_in_canceled'),
            'Login Google dibatalkan.');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        _handleApiError(null, 'Gagal mendapatkan ID Token dari Google.');
        return;
      }

      debugPrint(
          "Google ID Token obtained for registration. Sending to backend...");
      // Panggil endpoint yang sama dengan login, backend akan menghandle jika user belum ada
      final response = await ApiService.signInWithGoogleToken(idToken);

      if (response['status'] == 'success' &&
          response.containsKey('access_token') &&
          response.containsKey('user')) {
        final userDataMap = response['user'] as Map<String, dynamic>;
        // Backend Anda seharusnya membuat user jika belum ada, dan mengembalikan datanya
        await _processSuccessfulGoogleLogin(
            response['access_token'], response['refresh_token'], userDataMap);
      } else {
        _handleApiError(
            response,
            response['message'] ??
                'Registrasi/Login dengan Google gagal setelah verifikasi server.');
      }
    } catch (e) {
      _handleApiError(
          e, 'Terjadi kesalahan saat registrasi/login dengan Google.');
    } finally {
      // isGoogleLoading.value = false; // Sudah dihandle
    }
  }

  void navigateToLogin() => Get.offNamed(Routes.LOGIN);
}
