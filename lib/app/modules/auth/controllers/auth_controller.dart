import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../home/views/home_view.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController(); // Tambahkan email controller
  final genderController =
      TextEditingController(); // Tambahkan gender controller
  final occupationController =
      TextEditingController(); // Tambahkan occupation controller

  final api = ApiService();

  Future<void> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final gender = genderController.text.trim(); // Ambil nilai gender
    final occupation =
        occupationController.text.trim(); // Ambil nilai occupation

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        gender.isEmpty ||
        occupation.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi");
      return;
    }

    final res = await api.register(
      email,
      username,
      password,
      gender,
      occupation,
    );
    Get.snackbar(res['status'], res['message']);
    if (res['status'] == 'success') {
      Get.toNamed('/login');
    }
  }

  Future<void> login() async {
    final res = await api.login(
      usernameController.text,
      passwordController.text,
    );
    Get.snackbar(res['status'], res['message']);
    if (res['status'] == 'success') {
      Get.offAllNamed('/home');
    }
  }
}