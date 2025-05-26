import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart' show LatihanController; // Hanya untuk parseColor dan getCategoryIcon jika perlu
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/virtual_hrd_intro_controller.dart';

class VirtualhrdIntroView extends GetView<VirtualhrdIntroController> {
  const VirtualhrdIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses controller Latihan untuk helper jika dibutuhkan
    // Ini asumsi LatihanController sudah di-register secara global atau sebagai parent
    final LatihanController latihanController = Get.find<LatihanController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: Colors.white.withOpacity(0.8), size: 26),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
      ),
      body: Obx(() => Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              controller.primaryColor.value.withOpacity(0.85),
              controller.primaryColor.value,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.mediaQuery.padding.top + 20), // Space for status bar + appbar leading
                _buildHeader(latihanController),
                const SizedBox(height: 35),
                _buildFeatureList(),
                const SizedBox(height: 40),
                _buildStartButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildHeader(LatihanController latihanCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            latihanCtrl.getCategoryIcon(controller.iconName.value), // Gunakan helper dari LatihanController
            color: Colors.white,
            size: 48,
          ),
        ).animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          controller.title.value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: 12),
        Text(
          controller.description.value,
          style: TextStyle(
            fontSize: 16.5,
            color: Colors.white.withOpacity(0.85),
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: -0.15),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Yang Akan Anda Latih:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.2,
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 16),
        ...controller.features.map((feature) {
          int index = controller.features.indexOf(feature);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(feature['icon'] as IconData, color: Colors.white.withOpacity(0.8), size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    feature['text'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (600 + index * 100).ms, duration: 500.ms).slideX(begin: 0.2, curve: Curves.easeOutCubic);
        }).toList(),
      ],
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: SizedBox(
        width: Get.width * 0.8,
        child: ElevatedButton.icon(
          icon: const Icon(LucideIcons.play, size: 24, color: Colors.black87), // Ikon warna kontras
          label: const Text(
            "Mulai Sesi Simulasi",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87), // Teks warna kontras
          ),
          onPressed: controller.startVirtualHrdSession,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Tombol putih untuk kontras
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
        ).animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.5))
            .scale(delay: 800.ms, duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }
}