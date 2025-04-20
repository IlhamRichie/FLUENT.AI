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
  final RxString selectedGender = 'Laki-laki'.obs;
  final RxString selectedJob = 'Mahasiswa'.obs;

  final List<String> genders = ["Laki-laki", "Perempuan"];
  final List<String> jobs = ["Mahasiswa", "Fresh Graduate", "Pelajar", "Freelancer"];

  final ApiService _apiService = Get.find<ApiService>();

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmText.value = !obscureConfirmText.value;
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final gender = selectedGender.value;
    final occupation = occupationController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        gender.isEmpty ||
        occupation.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Password dan konfirmasi password tidak sama");
      return;
    }

    try {
      final result = await _apiService.register(
        email,
        username,
        password,
        gender,
        occupation,
      );

      Get.snackbar(result['status'], result['message']);
      if (result['status'] == 'success') {
        Get.offNamed(Routes.LOGIN);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat registrasi");
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fluent_ai/app/routes/app_pages.dart';

// class RegisterController extends GetxController {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController occupationController = TextEditingController();
  
//   final RxBool obscureText = true.obs;
//   final RxBool obscureConfirmText = true.obs;
//   final RxString selectedGender = 'Laki-laki'.obs;
//   final RxString selectedJob = 'Mahasiswa'.obs;

//   final List<String> genders = ["Laki-laki", "Perempuan"];
//   final List<String> jobs = ["Mahasiswa", "Fresh Graduate", "Pelajar", "Freelancer"];

//   void togglePasswordVisibility() {
//     obscureText.value = !obscureText.value;
//   }

//   void toggleConfirmPasswordVisibility() {
//     obscureConfirmText.value = !obscureConfirmText.value;
//   }

//   void register() {
//     // Validasi form
//     if (emailController.text.isEmpty ||
//         usernameController.text.isEmpty ||
//         passwordController.text.isEmpty ||
//         confirmPasswordController.text.isEmpty ||
//         occupationController.text.isEmpty) {
//       Get.snackbar("Error", "Semua field wajib diisi");
//       return;
//     }

//     if (passwordController.text != confirmPasswordController.text) {
//       Get.snackbar("Error", "Password dan konfirmasi password tidak sama");
//       return;
//     }

//     // Langsung navigasi ke home
//     Get.offAllNamed(Routes.HOME);
    
//     // Tampilkan pesan sukses
//     Get.snackbar(
//       "Registrasi Berhasil", 
//       "Akun Anda berhasil dibuat",
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void navigateToLogin() {
//     Get.back();
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     usernameController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     occupationController.dispose();
//     super.onClose();
//   }
// }