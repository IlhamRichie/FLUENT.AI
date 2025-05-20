import 'dart:async';
import 'dart:convert';
import 'package:fluent_ai/app/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final UserService _userService;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool obscureText = true.obs;
  final RxInt currentTextIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs; // Untuk loading spesifik Google
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
  StreamSubscription? _linkSubscription; // Untuk uni_links

  // Sesuaikan dengan konfigurasi di backend Flask
  final String _flutterAppScheme = 'fluentai';
  final String _flutterOAuthCallbackHost = 'oauth-callback';

  @override
  void onInit() {
    super.onInit();
    _userService = Get.find<UserService>();
    _startTextRotation();
    _initUniLinks(); // Panggil inisialisasi uni_links
    _checkAutoLogin(); 
  }

  @override
  void onClose() {
    _textRotationTimer?.cancel();
    _linkSubscription?.cancel();
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
    // isLoading.value = true; // Biarkan ini untuk loading screen awal jika ada
    try {
      final token = await _storage.read(key: 'access_token');
      final storedUserData = await _storage.read(key: 'user_data');

      if (token != null && token.isNotEmpty && storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;
        _userService.setUserData(
          username: userDataMap['username'] ?? '', email: userDataMap['email'] ?? '',
          avatar: userDataMap['profile_picture'],
          occupation: userDataMap['occupation'],
          gender: userDataMap['gender'],
        );
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      debugPrint("Auto login check failed: $e");
      await _storage.deleteAll(); // Hapus data jika korup
    } finally {
      // isLoading.value = false; // Matikan loading screen awal jika ada
    }
  }

  Future<void> _initUniLinks() async {
    try {
      // Dengarkan link yang masuk saat aplikasi sudah berjalan
      _linkSubscription = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          debugPrint('Received URI while app is running: $uri');
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        debugPrint('uni_links stream error: $err');
        _handleGoogleLoginError("Terjadi kesalahan saat memproses callback Google.");
      });

      // Cek apakah aplikasi dibuka melalui deep link saat startup
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        debugPrint('Initial URI on app startup: $initialUri');
        _handleDeepLink(initialUri);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get initial link: '${e.message}'.");
       _handleGoogleLoginError("Gagal memproses callback Google.");
    } catch (e) {
      debugPrint("Error initializing uni_links: $e");
       _handleGoogleLoginError("Terjadi kesalahan internal saat persiapan login Google.");
    }
  }

  void _handleDeepLink(Uri uri) {
    isGoogleLoading.value = true; // Aktifkan loading saat deep link diproses
    errorMessage.value = '';

    debugPrint("Handling deep link: $uri");
    debugPrint("Scheme: ${uri.scheme}, Host: ${uri.host}");
    debugPrint("Expected Scheme: $_flutterAppScheme, Expected Host: $_flutterOAuthCallbackHost");


    if (uri.scheme == _flutterAppScheme && uri.host == _flutterOAuthCallbackHost) {
      final status = uri.queryParameters['status'];
      debugPrint("Status from deep link: $status");

      if (status == 'success') {
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];
        final userJsonString = uri.queryParameters['user'];

        if (accessToken != null && userJsonString != null) {
          try {
            final userDataMap = jsonDecode(Uri.decodeComponent(userJsonString)) as Map<String, dynamic>; // Decode URI component
            debugPrint("User data from deep link: $userDataMap");
            _processSuccessfulLogin(accessToken, refreshToken, userDataMap, "Login Google");
          } catch (e) {
            debugPrint("Error decoding user data from deep link: $e");
            _handleGoogleLoginError("Gagal memproses data login Google dari callback.");
          }
        } else {
          debugPrint("Access token or user data missing in deep link.");
          _handleGoogleLoginError("Data tidak lengkap dari callback login Google.");
        }
      } else {
        final message = uri.queryParameters['message'] != null 
            ? Uri.decodeComponent(uri.queryParameters['message']!) 
            : "Login Google gagal dari server.";
        debugPrint("Error message from deep link: $message");
        _handleGoogleLoginError(message);
      }
    } else {
      debugPrint("Deep link tidak cocok dengan skema aplikasi.");
      // Tidak perlu menampilkan error di sini jika deep link dari sumber lain
      // _handleGoogleLoginError("Callback login Google tidak valid.");
    }
    if (Get.currentRoute == Routes.LOGIN) { // Hanya jika masih di halaman login
        isGoogleLoading.value = false;
    }
  }
  
  void _handleGoogleLoginError(String message) {
    errorMessage.value = message;
    isGoogleLoading.value = false;
    _showErrorSnackbar(message); // Tampilkan snackbar error juga
  }


  Future<void> _processSuccessfulLogin(String accessToken, String? refreshToken, Map<String, dynamic> userDataMap, String providerName) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

    _userService.setUserData(
      username: userDataMap['username'] ?? (userDataMap['email'] ?? '').split('@').first,
      email: userDataMap['email'] ?? '',
      avatar: userDataMap['profile_picture'],
      occupation: userDataMap['occupation'],
      gender: userDataMap['gender'],
    );
    
    isGoogleLoading.value = false; // Matikan loading google
    isLoading.value = false; // Matikan loading umum
    errorMessage.value = ''; // Bersihkan error message

    _showSuccessSnackbar("$providerName Berhasil!", "Selamat datang, ${userDataMap['username'] ?? ''}!");
    Get.offAllNamed(Routes.HOME);
  }


  void _handleApiError(dynamic e, String defaultMessage) {
    String messageToShow = defaultMessage;
    if (e is Map && e.containsKey('message') && e['message'] != null) {
      messageToShow = e['message'].toString();
    } else if (e is String && e.isNotEmpty) {
      messageToShow = e;
    }
    errorMessage.value = messageToShow;
    debugPrint('API Error: $messageToShow. Original error: $e');
    _showErrorSnackbar(messageToShow); // Tampilkan snackbar error juga
  }

  void _showSuccessSnackbar(String title, String message) {
     Get.snackbar(
      title, message,
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade600,
      colorText: Colors.white, borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
    );
  }
  
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Login Gagal', message, // Judul disesuaikan
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade600, // Warna error
      colorText: Colors.white, borderRadius: 10, margin: const EdgeInsets.all(12),
      icon: const Icon(LucideIcons.alertTriangle, color: Colors.white), // Icon error
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
      _showErrorSnackbar("Harap periksa kembali input Anda.");
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
        final userDataMap = response['user'] as Map<String, dynamic>;
        await _processSuccessfulLogin(response['access_token'], response['refresh_token'], userDataMap, "Login");
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
    final String googleLoginUrl = '${ApiService.baseUrl}/auth/google/login'; 
    
    debugPrint("Attempting to launch Google login URL: $googleLoginUrl");

    try {
      final Uri launchUri = Uri.parse(googleLoginUrl);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication, // Penting agar bisa kembali ke app via deep link
        );
      } else {
        debugPrint('Could not launch $googleLoginUrl');
        throw 'Could not launch $googleLoginUrl';
      }
    } catch (e) {
      _handleGoogleLoginError('Gagal memulai login dengan Google. Pastikan browser terinstal atau koneksi internet stabil.');
      debugPrint("Error launching Google login URL: $e");
      // isGoogleLoading.value = false; // sudah dihandle oleh _handleGoogleLoginError
    }
    // Jangan set isGoogleLoading.value = false di sini secara langsung, karena kita menunggu callback.
  }

  void navigateToRegister() => Get.toNamed(Routes.REGISTER);
  void navigateToForgotPassword() => Get.toNamed(Routes.LUPA);
}