import 'package:fluent_ai/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Obx(() => AnimatedOpacity(
          opacity: controller.opacity.value,
          duration: const Duration(seconds: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar konten tidak memenuhi layar
            children: [
              Image.asset(
                'assets/images/logo FLUENT.png',
                width: 200,
              ),
              const SizedBox(height: 16), // Jarak antara gambar dan teks
              Text(
                'FLUENT',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD84040), // Warna teks
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}