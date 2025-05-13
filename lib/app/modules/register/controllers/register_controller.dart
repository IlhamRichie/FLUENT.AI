import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  
  final RxBool obscureText = true.obs;
  final RxBool obscureConfirmText = true.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedGender = 'Laki-laki'.obs;
  final RxString selectedJob = 'Mahasiswa'.obs;

  final List<String> genders = ["Laki-laki", "Perempuan"];
  final List<String> jobs = ["Mahasiswa", "Fresh Graduate", "Pelajar", "Freelancer"];

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmText.value = !obscureConfirmText.value;
  }

  Future<void> register() async {
    try {
      isLoading.value = true;
      
      if (passwordController.text != confirmPasswordController.text) {
        throw Exception("Password dan konfirmasi password tidak sama");
      }

      final response = await ApiService.register(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        gender: selectedGender.value,
        occupation: occupationController.text.trim(),
      );

      Get.snackbar(
        response['status'].toString().capitalizeFirst ?? 'Success',
        response['message'],
        snackPosition: SnackPosition.BOTTOM,
      );

      if (response['status'] == 'success') {
        Get.offNamed(Routes.LOGIN);
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

  void navigateToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    occupationController.dispose();
    super.onClose();
  }
}