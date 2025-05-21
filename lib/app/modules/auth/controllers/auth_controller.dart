import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/user_service.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final occupationController = TextEditingController();

  final RxBool isLoading = false.obs;

  Future<void> register() async {
    try {
      isLoading.value = true;

      final response = await ApiService.register(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        gender: genderController.text.trim(),
        occupation: occupationController.text.trim(),
      );

      Get.snackbar(
        response['status'].toString().capitalizeFirst ?? 'Success',
        response['message'],
        snackPosition: SnackPosition.BOTTOM,
      );

      if (response['status'] == 'success') {
        UserService.to.setUserData(
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          occupation: occupationController.text.trim(),
          gender: genderController.text.trim(),
        );
        Get.offNamed('/login');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoading.value = true;

      final response = await ApiService.login(
        email: emailController.text.trim(), // ← Disini sudah benar pakai email
        password: passwordController.text.trim(),
      );

      Get.snackbar(
        response['status'].toString().capitalizeFirst ?? 'Success',
        response['message'],
        snackPosition: SnackPosition.BOTTOM,
      );

      if (response['status'] == 'success') {
        final userData =
            response['user']; // Pastikan ini sesuai response backend
        UserService.to.setUserData(
          username: userData['username'] ?? usernameController.text.trim(),
          email: userData['email'] ?? emailController.text.trim(),
          occupation: userData['occupation'] ?? '',
          gender: userData['gender'] ?? '',
        );
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    genderController.dispose();
    occupationController.dispose();
    super.onClose();
  }
}
