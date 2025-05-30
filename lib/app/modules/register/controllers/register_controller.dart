// lib/app/modules/register/controllers/register_controller.dart
import 'dart:async';
import 'package:fluent_ai/app/modules/otp/controllers/otp_controller.dart'; // Import OtpSource
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // Untuk jsonEncode
import 'package:http/http.dart' as http_pkg; // Untuk ClientException (jika diperlukan untuk error handling spesifik)
import 'dart:io'; // Untuk SocketException (jika diperlukan untuk error handling spesifik)
import 'package:flutter/services.dart'; // Untuk PlatformException (Google Sign In)


class RegisterController extends GetxController {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxString selectedGender = 'Pria'.obs;
  final List<String> genders = ['Pria', 'Wanita', 'Lainnya'];
  final RxString selectedJob = 'Pelajar/Mahasiswa'.obs;
  final List<String> jobs = [
    'Pelajar/Mahasiswa', 'Karyawan Swasta', 'Profesional',
    'Wiraswasta', 'Lainnya'
  ];

  final RxBool obscureText = true.obs;
  final RxBool obscureConfirmText = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Color get primaryColor => const Color(0xFFD84040); // Sesuaikan

  final RxInt currentTextIndex = 0.obs;
  final List<String> headerTexts = [
    "Satu langkah lagi menuju kefasihan! 🌟",
    "Bergabunglah dengan komunitas pembelajar kami. 🤝",
    "Fluent AI siap membantumu setiap saat! 💡",
  ];
  Timer? _textRotationTimer;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // serverClientId: 'YOUR_SERVER_CLIENT_ID', // Opsional jika backend memverifikasi ID Token
  );
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
    _textRotationTimer ??= Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (headerTexts.isNotEmpty) {
        currentTextIndex.value = (currentTextIndex.value + 1) % headerTexts.length;
      }
    });
  }

  void _handleApiError(dynamic e, String defaultMessage) {
    String messageToShow = defaultMessage;
    if (e is Map && e.containsKey('message') && e['message'] != null) {
      messageToShow = e['message'].toString();
    } else if (e is String && e.isNotEmpty) {
      messageToShow = e;
    } else if (e is http_pkg.ClientException || e is SocketException) {
      messageToShow = "Gangguan koneksi. Periksa internet Anda.";
    } else if (e is PlatformException) {
      messageToShow = 'Gagal login dengan Google: ${e.message ?? e.code}';
      if (e.code == 'sign_in_canceled') messageToShow = 'Login Google dibatalkan.';
      if (e.code == 'network_error') messageToShow = 'Kesalahan jaringan saat login Google.';
    } else if (e is TimeoutException) {
      messageToShow = "Waktu koneksi habis. Silakan coba lagi.";
    }

    errorMessage.value = messageToShow;
    debugPrint('API Error (Register): $messageToShow. Original error: $e');
    Get.snackbar(
      'Registrasi Gagal', messageToShow,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600, colorText: Colors.white,
      borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.alertTriangle, color: Colors.white),
    );
    isLoading.value = false; // Pastikan direset
    isGoogleLoading.value = false; // Pastikan direset
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600, colorText: Colors.white,
      borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.partyPopper, color: Colors.white),
    );
  }

  Future<void> _processSuccessfulLogin(String accessToken, String? refreshToken,
      Map<String, dynamic> userDataMap, String providerName) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

      _showSuccessSnackbar("$providerName Berhasil!",
          "Selamat datang, ${userDataMap['username'] ?? userDataMap['email'] ?? ''}!");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _handleApiError(e, "Gagal menyimpan sesi login Anda.");
    } finally {
      isLoading.value = false;
      isGoogleLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;
  void toggleConfirmPasswordVisibility() => obscureConfirmText.value = !obscureConfirmText.value;

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Nama pengguna tidak boleh kosong.';
    if (value.length < 3) return 'Nama pengguna minimal 3 karakter.';
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
      isLoading.value = false; // Set loading false setelah API call selesai

      if (response['status'] == 'success') {
        _showSuccessSnackbar(
          "Registrasi Berhasil!",
          response['message'] ?? "Kode OTP telah dikirim ke email Anda. Silakan verifikasi."
        );
        // Arahkan ke halaman OTP setelah registrasi sukses
        Get.offNamed(Routes.OTP, arguments: {
          'email': emailController.text.trim(),
          'source': OtpSource.registration, // Menggunakan enum
        });
      } else {
        _handleApiError(response, response['message'] ?? 'Registrasi gagal. Coba lagi.');
      }
    } catch (e) {
       // isLoading sudah dihandle di _handleApiError
      _handleApiError(e, 'Terjadi kesalahan koneksi. Silakan coba lagi nanti.');
    }
    // Tidak perlu finally isLoading.value = false; jika sudah dihandle di atas dan di _handleApiError
  }

  Future<void> loginWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    errorMessage.value = '';

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _handleApiError(PlatformException(code: 'sign_in_canceled'), 'Login Google dibatalkan.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _handleApiError(null, 'Gagal mendapatkan ID Token dari Google.');
        return;
      }

      final response = await ApiService.signInWithGoogleToken(idToken);
      // isGoogleLoading.value = false; // Pindahkan ke _processSuccessfulLogin atau _handleApiError

      if (response['status'] == 'success' &&
          response.containsKey('access_token') &&
          response.containsKey('user')) {
        final userDataMap = response['user'] as Map<String, dynamic>;
        await _processSuccessfulLogin(response['access_token'],
            response['refresh_token'], userDataMap, "Login Google");
      } else {
        _handleApiError(response, response['message'] ?? 'Login Google gagal setelah verifikasi server.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi kesalahan saat login dengan Google.');
    }
    // Tidak perlu finally isGoogleLoading.value = false; jika sudah dihandle
  }

  void navigateToLogin() => Get.offNamed(Routes.LOGIN);
}