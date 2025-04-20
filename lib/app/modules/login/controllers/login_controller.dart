import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;
  final RxInt currentTextIndex = 0.obs;
  final List<String> footerTexts = [
    "Tingkatkan skill ngomong lo biar makin pede! 🚀",
    "Latihan pake AI, biar lo makin lancar ngomong. 🤖",
    "Cek ekspresi lo & dapetin feedback real-time! 🎤",
    "Siap-siap buat wawancara kerja yang sukses! 💼",
    "Jadi jago komunikasi dalam waktu singkat! ⏱️",
  ];

  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    startTextRotation();
  }

  void startTextRotation() {
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      currentTextIndex.value =
          (currentTextIndex.value + 1) % footerTexts.length;
    });
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  //Sementara

  // Tambahkan method untuk login Google
  void loginWithGoogle() async {
    // Tampilkan loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Simulasikan delay proses login
    await Future.delayed(const Duration(seconds: 2));

    // Tutup dialog loading
    Get.back();

    // Navigasi ke home
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Username dan Password wajib diisi");
      return;
    }

    try {
      final result = await _apiService.login(username, password);
      if (result['status'] == 'success') {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar("Login Gagal", result['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat login");
    }
  }

  void navigateToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
