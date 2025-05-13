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
  final RxBool isLoading = false.obs;

  final List<String> footerTexts = [
    "Tingkatkan skill ngomong lo biar makin pede! 🚀",
    "Latihan pake AI, biar lo makin lancar ngomong. 🤖",
    "Cek ekspresi lo & dapetin feedback real-time! 🎤",
    "Siap-siap buat wawancara kerja yang sukses! 💼",
    "Jadi jago komunikasi dalam waktu singkat! ⏱️",
  ];

  @override
  void onInit() {
    super.onInit();
    startTextRotation();
  }

  void startTextRotation() {
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      currentTextIndex.value = (currentTextIndex.value + 1) % footerTexts.length;
    });
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      
      final response = await ApiService.login(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response['status'] == 'success') {
        // Store tokens securely here
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat login',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithGoogle() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 2));
    Get.back();
    Get.offAllNamed(Routes.HOME);
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