import 'package:fluent_ai/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  "assets/images/logo FLUENT.png",
                  height: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  "Daftar Yuk! 🚀",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD84040),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.usernameController,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          hintText: "Masukkan nama lengkap kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Masukkan email kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedGender.value,
                        decoration:        InputDecoration(
                          labelText: "Jenis Kelamin",
                          hintText: "Pilih jenis kelamin kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: controller.genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            controller.selectedGender.value = value;
                          }
                        },
                      )),
                      const SizedBox(height: 10),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedJob.value,
                        decoration: InputDecoration(
                          labelText: "Pilihan Pekerjaan",
                          hintText: "Pilih pekerjaan kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: controller.jobs.map((String job) {
                          return DropdownMenuItem<String>(
                            value: job,
                            child: Text(job),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            controller.selectedJob.value = value;
                          }
                        },
                      )),
                      const SizedBox(height: 10),
                      Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Masukkan password kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      )),
                      const SizedBox(height: 10),
                      Obx(() => TextField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmText.value,
                        decoration: InputDecoration(
                          labelText: "Konfirmasi Password",
                          hintText: "Masukkan ulang password kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "atau",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google.webp",
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Daftar dengan Google",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: controller.navigateToLogin,
                        child: const Text(
                          "Sudah punya akun? Login dulu!",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class RegisterView extends StatelessWidget {
//   const RegisterView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Langsung navigasi ke home
//             Get.offAllNamed('/home');
//           },
//           child: const Text('Register'),
//         ),
//       ),
//     );
//   }
// }