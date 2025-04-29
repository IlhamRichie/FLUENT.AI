import 'package:fluent_ai/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        "assets/images/logo FLUENT.png",
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        "Masuk Yuk! 🚀",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD84040),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Login Form Container
                      Container(
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
                            // Email Field
                            TextField(
                              controller: controller.usernameController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "Masukkan email kamu",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Password Field
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
                            const SizedBox(height: 20),
                            
                            // Login Button
                            ElevatedButton(
                              onPressed: controller.login,
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
                                "Masuk Sekarang",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Divider
                            const Text(
                              "atau",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Google Login Button
                            OutlinedButton(
                              onPressed: controller.loginWithGoogle,
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
                                    "Login dengan Google",
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
                            
                            // Register Link
                            TextButton(
                              onPressed: controller.navigateToRegister,
                              child: const Text(
                                "Belum punya akun? Daftar dulu!",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Footer Text
                      Obx(() => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          controller.footerTexts[controller.currentTextIndex.value],
                          key: ValueKey<int>(controller.currentTextIndex.value),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}