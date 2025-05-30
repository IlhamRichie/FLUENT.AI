// lib/app/modules/otp/controllers/otp_controller.dart
import 'dart:async';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum OtpSource { registration, passwordReset, unknown }

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final RxString currentOtp = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxString errorMessage = ''.obs;

  late String email; // Akan diisi dari arguments
  late OtpSource source; // Sumber permintaan OTP

  // Timer untuk resend OTP
  final RxInt _start = 60.obs; // Durasi timer dalam detik
  RxBool canResendOtp = false.obs;
  Timer? _timer;

  Color get primaryColor => const Color(0xFFD84040); // Sesuaikan dengan primary color Anda

  @override
  void onInit() {
    super.onInit();
    // Ambil argumen yang dikirim dari halaman sebelumnya
    if (Get.arguments != null && Get.arguments is Map) {
      final Map args = Get.arguments as Map;
      email = args['email'] ?? 'N/A';
      source = args['source'] ?? OtpSource.unknown;

      if (email == 'N/A') {
        Get.snackbar(
          'Error',
          'Email tidak ditemukan. Silakan coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.LOGIN); // Kembali ke login jika email tidak ada
      } else {
        startTimer(); // Mulai timer saat halaman diinisialisasi
      }
    } else {
      // Handle jika tidak ada argumen (seharusnya tidak terjadi jika alur benar)
      Get.snackbar(
        'Error',
        'Informasi OTP tidak lengkap.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }

  void startTimer() {
    canResendOtp.value = false;
    _start.value = 60; // Reset timer
    _timer?.cancel(); // Batalkan timer yang ada jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start.value == 0) {
        timer.cancel();
        canResendOtp.value = true;
      } else {
        _start.value--;
      }
    });
  }

  String get timerText {
    if (canResendOtp.value) return "Kirim Ulang OTP";
    int minutes = _start.value ~/ 60;
    int seconds = _start.value % 60;
    return "Kirim ulang dalam ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _handleApiError(dynamic e, String defaultMessage) {
    isLoading.value = false;
    isResendingOtp.value = false;
    String messageToShow = defaultMessage;

    if (e is Map && e.containsKey('message') && e['message'] != null) {
      messageToShow = e['message'].toString();
    } else if (e is String && e.isNotEmpty) {
      messageToShow = e;
    }
    // Tambahkan penanganan spesifik jika diperlukan

    errorMessage.value = messageToShow;
    Get.snackbar(
      'Error',
      messageToShow,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(LucideIcons.alertTriangle, color: Colors.white),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
    );
  }

  Future<void> verifyOtp() async {
    if (currentOtp.value.length != 6) { // Asumsi OTP 6 digit
      errorMessage.value = 'Kode OTP harus 6 digit.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.verifyOtp(
        email: email,
        otp: currentOtp.value,
        source: source.name, // 'registration' atau 'passwordReset'
      );

      if (response['status'] == 'success') {
        _showSuccessSnackbar(
            "Verifikasi Berhasil",
            response['message'] ?? "Akun Anda telah berhasil diverifikasi.");

        // Navigasi berdasarkan sumber OTP
        if (source == OtpSource.registration) {
          Get.offAllNamed(Routes.LOGIN); // Arahkan ke login setelah verifikasi registrasi
        } else if (source == OtpSource.passwordReset) {
          // Arahkan ke halaman ganti password baru, mungkin dengan membawa token dari response
          // Get.offNamed(Routes.RESET_PASSWORD_FORM, arguments: {'token': response['reset_token']});
          // Untuk saat ini, kita arahkan ke login saja sebagai contoh
          Get.offAllNamed(Routes.LOGIN, arguments: {'successMessage': 'Silakan login dengan password baru Anda jika sudah direset.'});
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        _handleApiError(response, response['message'] ?? 'Verifikasi OTP gagal.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi kesalahan saat verifikasi OTP.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    isResendingOtp.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.requestOtp(
        email: email,
        source: source.name,
      ); // Mengirim ulang OTP

      if (response['status'] == 'success') {
        _showSuccessSnackbar("OTP Terkirim", response['message'] ?? 'OTP baru telah dikirim ke email Anda.');
        startTimer(); // Mulai ulang timer
      } else {
        _handleApiError(response, response['message'] ?? 'Gagal mengirim ulang OTP.');
      }
    } catch (e) {
      _handleApiError(e, 'Terjadi kesalahan saat mengirim ulang OTP.');
    } finally {
      isResendingOtp.value = false;
    }
  }
}