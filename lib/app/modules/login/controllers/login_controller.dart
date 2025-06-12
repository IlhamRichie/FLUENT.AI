import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:fluent_ai/app/data/services/user_service.dart'; // <-- HAPUS INI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <-- Tambahkan google_sign_in
import 'package:http/http.dart' as http_pkg; // Untuk ClientException
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:app_links/app_links.dart'; // Komentari jika tidak dipakai untuk Google OAuth baru
// import 'package:url_launcher/url_launcher.dart'; // Komentari jika tidak dipakai untuk Google OAuth baru

class LoginController extends GetxController {
  static const String _WEB_SERVER_CLIENT_ID =
      '801295038520-90b851hknplg0rpq77n8vr4bs1g5h7mm.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _WEB_SERVER_CLIENT_ID, // <--- DIMASUKKAN DI SINI
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // late final UserService _userService; // <-- HAPUS INI
  // final AppLinks _appLinks = AppLinks(); // <-- Komentari/hapus jika tidak dipakai

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscureText = true.obs;
  final RxInt currentTextIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Color get primaryColor => const Color(0xFFD84040);

  final List<String> footerTexts = [
    "Tingkatkan skill komunikasimu ke level berikutnya! 🚀",
    "Latihan dengan AI, dapatkan feedback instan. 🤖",
    "Analisis ekspresi dan intonasimu secara mendalam. 🎤",
    "Persiapkan diri untuk wawancara kerja impianmu! 💼",
    "Menuju kefasihan berbicara dengan percaya diri. ✨",
  ];
  Timer? _textRotationTimer;
  // StreamSubscription<Uri>? _linkSubscription; // <-- Komentari/hapus

  // final String _flutterAppScheme = 'fluentai'; // <-- Tidak relevan untuk Google Sign-In baru
  // final String _flutterOAuthCallbackHost = 'oauthcallback'; // <-- Tidak relevan

  @override
  void onInit() {
    super.onInit();
    // _userService = Get.isRegistered<UserService>() // <-- HAPUS BLOK INI
    //     ? Get.find<UserService>()
    //     : Get.put(UserService());
    _startTextRotation();
    // _initAppLinks(); // <-- Komentari/hapus jika hanya untuk Google OAuth lama
    _checkAutoLogin();
  }

  @override
  void onClose() {
    _textRotationTimer?.cancel();
    // _linkSubscription?.cancel(); // <-- Komentari/hapus
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _startTextRotation() {
    _textRotationTimer ??=
        Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (footerTexts.isNotEmpty) {
        currentTextIndex.value =
            (currentTextIndex.value + 1) % footerTexts.length;
      }
    });
  }

  Future<void> _checkAutoLogin() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final storedUserData = await _storage.read(key: 'user_data');

      if (token != null && token.isNotEmpty && storedUserData != null) {
        debugPrint(
            "Auto login: Token and user data found. Navigating to HOME.");
        Get.offAllNamed(Routes.HOME);
      } else {
        debugPrint("Auto login: No token or user data found.");
      }
    } catch (e) {
      debugPrint("Auto login check failed: $e");
      await _storage.deleteAll(); // Clear storage on error
    }
  }

  // Hapus _initAppLinks dan _handleDeepLink jika hanya untuk Google OAuth lama
  // Jika app_links dipakai untuk fitur lain, sesuaikan agar tidak menangani callback google
  /*
  Future<void> _initAppLinks() async { ... }
  void _handleDeepLink(Uri uri) { ... }
  */

  Future<void> _processSuccessfulLogin(String accessToken, String? refreshToken,
      Map<String, dynamic> userDataMap, String providerName) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      // Simpan data pengguna yang relevan dari userDataMap ke storage
      // Ini akan dibaca oleh controller lain (Home, Profile) saat onInit
      await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

      // _userService.setUserData(...); // <-- HAPUS INI

      errorMessage.value = '';
      _showSuccessSnackbar("$providerName Berhasil!",
          "Selamat datang, ${userDataMap['username'] ?? userDataMap['email'] ?? ''}!");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint("Error processing successful login (storage): $e");
      final String errorMsg = (providerName == "Login Google")
          ? "Gagal memproses data login Google setelah diterima."
          : "Gagal menyimpan sesi login Anda.";
      _handleApiError(e, errorMsg);
    } finally {
      isLoading.value = false;
      isGoogleLoading.value = false;
    }
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
      // Untuk google_sign_in
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
    debugPrint('API/Login Error: $messageToShow. Original error: $e');
    _showErrorSnackbar(messageToShow);
    // Pastikan loading state direset jika error terjadi di tengah proses
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
      icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Login Gagal',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.alertTriangle, color: Colors.white),
    );
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong.';
    if (!GetUtils.isEmail(value)) return 'Format email tidak valid.';
    errorMessage.value = '';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    if (value.length < 6) return 'Password minimal 6 karakter.';
    errorMessage.value = '';
    return null;
  }

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (response['status'] == 'success' &&
          response.containsKey('access_token') &&
          response.containsKey('user')) {
        final userDataMap = response['user'] as Map<String, dynamic>;
        await _storage.write(key: 'session_id', value: response['session_id']);
        await _processSuccessfulLogin(response['access_token'],
            response['refresh_token'], userDataMap, "Login Email");
      } else {
        _handleApiError(response,
            response['message'] ?? 'Email atau password tidak cocok.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi gangguan koneksi. Silakan coba lagi.');
    } finally {
      // isLoading.value = false; // Sudah dihandle di _processSuccessfulLogin atau _handleApiError
    }
  }

  Future<void> loginWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    errorMessage.value = '';

    try {
      // PENTING: Panggil signOut() dulu untuk memaksa dialog pemilihan akun
      // Ini berguna untuk testing atau jika pengguna ingin switch akun.
      // Untuk alur produksi, Anda mungkin tidak selalu ingin signOut setiap kali.
      await _googleSignIn.signOut();
      print("Google Sign-Out successful (untuk memaksa account chooser).");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Pengguna membatalkan sign-in (dialog pemilihan ditutup)
        _handleApiError(PlatformException(code: 'sign_in_canceled'),
            'Login Google dibatalkan.');
        // isGoogleLoading.value = false; // sudah dihandle di finally atau _handleApiError
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _handleApiError(null, 'Gagal mendapatkan ID Token dari Google.');
        // isGoogleLoading.value = false;
        return;
      }

      debugPrint("Google ID Token obtained. Sending to backend...");
      final response = await ApiService.signInWithGoogleToken(idToken);
      debugPrint(
          "Response from backend /api/auth/google/app-signin: ${jsonEncode(response)}");

      if (response['status'] == 'success' &&
          response.containsKey('access_token') &&
          response.containsKey('user')) {
        final userDataMap = response['user'] as Map<String, dynamic>;
        await _processSuccessfulLogin(response['access_token'],
            response['refresh_token'], userDataMap, "Login Google");
      } else {
        _handleApiError(
            response,
            response['message'] ??
                'Login dengan Google gagal setelah verifikasi server (struktur respons tidak sesuai).');
      }
    } catch (e) {
      // Tangani error dari signOut() atau signIn()
      if (e is PlatformException && e.code == 'sign_in_required') {
        // Ini bisa terjadi jika signOut sebelumnya membuat signInSilently gagal,
        // tapi signIn() biasa seharusnya tetap menampilkan UI.
        // Anda bisa log ini, tapi signIn() setelah signOut seharusnya tetap memunculkan UI.
        _handleApiError(e, 'Sign in required, UI picker should have appeared.');
      } else {
        _handleApiError(e, 'Terjadi kesalahan saat login dengan Google.');
      }
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void navigateToRegister() => Get.toNamed(Routes.REGISTER);
  void navigateToForgotPassword() =>
      Get.toNamed(Routes.LUPA); // Pastikan route LUPA ada
}
