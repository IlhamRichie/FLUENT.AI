import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluent_ai/app/data/services/user_service.dart'; // Sesuaikan path jika perlu
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk PlatformException
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart'; // Sesuaikan path jika perlu
import 'package:fluent_ai/app/routes/app_pages.dart'; // Sesuaikan path jika perlu
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_links/app_links.dart'; // Impor app_links
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final UserService _userService;
  final AppLinks _appLinks = AppLinks();

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
  StreamSubscription<Uri>? _linkSubscription;

  final String _flutterAppScheme = 'fluentai';
  final String _flutterOAuthCallbackHost = 'oauthcallback';

  @override
  void onInit() {
    super.onInit();
    _userService = Get.isRegistered<UserService>()
        ? Get.find<UserService>()
        : Get.put(UserService());
    _startTextRotation();
    _initAppLinks();
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
      _textRotationTimer =
          Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (footerTexts.isNotEmpty) {
          currentTextIndex.value =
              (currentTextIndex.value + 1) % footerTexts.length;
        }
      });
    }
  }

  Future<void> _checkAutoLogin() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final storedUserData = await _storage.read(key: 'user_data');

      if (token != null && token.isNotEmpty && storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;
        _userService.setUserData(
          username: userDataMap['username'] ?? '',
          email: userDataMap['email'] ?? '',
          avatar: userDataMap['profile_picture'],
          occupation: userDataMap['occupation'],
          gender: userDataMap['gender'],
        );
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      debugPrint("Auto login check failed: $e");
      await _storage.deleteAll();
    }
  }

  Future<void> _initAppLinks() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial URI on app startup (app_links): $initialUri');
        _handleDeepLink(initialUri);
      } else {
        debugPrint('No initial URI detected on app startup (app_links).');
      }

      _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        debugPrint('Received URI while app is running (app_links): $uri');
        _handleDeepLink(uri);
      }, onError: (Object err) {
        debugPrint('app_links stream error: $err');
        String userMessage =
            "Terjadi kesalahan saat memproses callback Google.";
        if (err is PlatformException) {
          userMessage =
              "Kesalahan platform saat memproses callback: ${err.message ?? 'Tidak ada detail'}";
        } else if (err is FormatException) {
          userMessage =
              "Format callback tidak valid: ${err.message ?? 'Tidak ada detail'}";
        }
        // Ensure isGoogleLoading is reset if an error occurs at this stage
        _handleGoogleLoginError(userMessage);
      });
    } on PlatformException catch (e) {
      debugPrint(
          "Failed to get initial link (app_links) - PlatformException: '${e.message}'.");
      _handleGoogleLoginError(
          "Gagal memproses callback Google saat startup: ${e.message ?? 'Kesalahan platform'}");
    } catch (e) {
      debugPrint("Error initializing app_links: $e");
      _handleGoogleLoginError(
          "Terjadi kesalahan internal saat persiapan login Google.");
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("Handling deep link (app_links): $uri");
    debugPrint(
        "Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}, Query: ${uri.queryParameters}");
    debugPrint(
        "Expected Scheme: $_flutterAppScheme, Expected Host: $_flutterOAuthCallbackHost");

    // Check if this is the OAuth callback we are expecting
    if (uri.scheme == _flutterAppScheme &&
        uri.host == _flutterOAuthCallbackHost) {
      // If loginWithGoogle() was called, isGoogleLoading is already true.
      // If the app was opened directly via deep link (e.g., from killed state),
      // set isGoogleLoading to true now to provide UI feedback.
      if (!isGoogleLoading.value) {
        isGoogleLoading.value = true;
      }
      errorMessage.value = ''; // Clear previous errors for this flow

      final status = uri.queryParameters['status'];
      debugPrint("Status from deep link: $status");

      if (status == 'success') {
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];
        final userJsonString = uri.queryParameters['user'];

        if (accessToken != null && userJsonString != null) {
          try {
            final decodedUserJson = Uri.decodeComponent(userJsonString);
            final userDataMap =
                jsonDecode(decodedUserJson) as Map<String, dynamic>;
            debugPrint("User data from deep link: $userDataMap");
            _processSuccessfulLogin(
                accessToken, refreshToken, userDataMap, "Login Google");
          } catch (e) {
            debugPrint("Error decoding user data from deep link: $e");
            _handleGoogleLoginError(
                "Gagal memproses data login Google dari callback.");
          }
        } else {
          debugPrint("Access token or user data missing in deep link.");
          _handleGoogleLoginError(
              "Data tidak lengkap dari callback login Google.");
        }
      } else {
        final message = uri.queryParameters['message'] != null
            ? Uri.decodeComponent(uri.queryParameters['message']!)
            : "Login Google gagal. Tidak ada pesan error spesifik dari server.";
        debugPrint("Error message from deep link: $message");
        _handleGoogleLoginError(message);
      }
    } else {
      // This is an unrelated deep link.
      debugPrint(
          "Deep link tidak cocok dengan skema callback OAuth yang diharapkan.");
      // If Google login was in progress (isGoogleLoading == true),
      // an unrelated deep link means the expected OAuth callback didn't arrive (or was superseded).
      // Reset the Google loading state.
      if (isGoogleLoading.value) {
        isGoogleLoading.value = false;
        // Optionally, inform the user that the Google login was interrupted if that makes sense for your UX.
        // errorMessage.value = "Login Google terinterupsi oleh navigasi tak terduga.";
        // _showErrorSnackbar(errorMessage.value);
        debugPrint(
            "Google login was in progress, but an unrelated deep link was received. Resetting Google loading state.");
      }
    }
  }

  void _handleGoogleLoginError(String message) {
    errorMessage.value = message;
    isGoogleLoading.value =
        false; // Crucial: Always turn off Google loading on error
    _showErrorSnackbar(message);
  }

  Future<void> _processSuccessfulLogin(String accessToken, String? refreshToken,
      Map<String, dynamic> userDataMap, String providerName) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      await _storage.write(key: 'user_data', value: jsonEncode(userDataMap));

      _userService.setUserData(
        username: userDataMap['username'] ??
            (userDataMap['email'] ?? '').split('@').first,
        email: userDataMap['email'] ?? '',
        avatar: userDataMap['profile_picture'],
        occupation: userDataMap['occupation'],
        gender: userDataMap['gender'],
      );

      errorMessage.value = '';
      _showSuccessSnackbar("$providerName Berhasil!",
          "Selamat datang, ${userDataMap['username'] ?? ''}!");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint(
          "Error processing successful login (storage/user service): $e");
      // If error occurs here, it's after getting tokens, so it's an internal app error.
      _handleGoogleLoginError(
          "Gagal menyimpan sesi login Anda. Silakan coba lagi nanti.");
    } finally {
      // Ensure all loading states are reset on successful processing completion
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
    } else if (e is ClientException) {
      // Specifically handle http ClientException
      messageToShow = "Terjadi gangguan koneksi. Periksa internet Anda.";
    } else if (e is SocketException) {
      // Specifically handle SocketException
      messageToShow = "Tidak dapat terhubung ke server. Periksa koneksi Anda.";
    }

    errorMessage.value = messageToShow;
    debugPrint('API Error: $messageToShow. Original error: $e');
    _showErrorSnackbar(messageToShow);
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
      duration: const Duration(seconds: 3),
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
      duration: const Duration(seconds: 4),
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
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      // _showErrorSnackbar("Harap periksa kembali input Anda."); // Validation messages are shown by form fields
      return;
    }
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
        await _processSuccessfulLogin(response['access_token'],
            response['refresh_token'], userDataMap, "Login Email");
      } else {
        _handleApiError(response,
            response['message'] ?? 'Email atau password tidak cocok.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi gangguan koneksi. Silakan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    // Prevent multiple invocations if already loading
    if (isGoogleLoading.value) {
      debugPrint("Google login is already in progress. Ignoring new request.");
      return;
    }

    isGoogleLoading.value = true;
    errorMessage.value = '';

    final String googleLoginUrl =
        '${ApiService.baseUrl}/auth/google/login?next=${Uri.encodeComponent("$_flutterAppScheme://$_flutterOAuthCallbackHost")}';

    debugPrint("Attempting to launch Google login URL: $googleLoginUrl");

    try {
      final Uri launchUri = Uri.parse(googleLoginUrl);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
        // At this point, isGoogleLoading remains true.
        // It will be set to false by _handleDeepLink (via _processSuccessfulLogin or _handleGoogleLoginError)
        // or if an unrelated deep link resets it.
      } else {
        debugPrint('Could not launch $googleLoginUrl');
        _handleGoogleLoginError(
            'Tidak dapat membuka halaman login Google. Pastikan browser terinstal dan berfungsi.');
      }
    } catch (e) {
      _handleGoogleLoginError(
          'Gagal memulai login dengan Google: ${e.toString()}');
      debugPrint("Error launching Google login URL: $e");
    }
    // DO NOT set isGoogleLoading.value = false here; wait for deep link callback.
  }

  void navigateToRegister() => Get.toNamed(Routes.REGISTER);
  void navigateToForgotPassword() => Get.toNamed(Routes.LUPA);
}
