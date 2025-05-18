// lib/app/modules/lupa/views/lupa_view.dart
import 'package:fluent_ai/app/modules/lupa/controllers/lupa_controller.dart'; // Sesuaikan path
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LupaView extends GetView<LupaPasswordController> { 
  const LupaView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeftCircle, color: Colors.grey[700], size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ),
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              controller.primaryColor.withOpacity(0.05),
              controller.primaryColor.withOpacity(0.15),
            ],
            stops: const [0.3, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Form(
              key: controller.forgotPasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 35),
                  Obx(() => controller.successMessage.isNotEmpty
                      ? _buildSuccessState()
                      : _buildEmailForm(context)),
                  const SizedBox(height: 40),
                ].animate(interval: 60.ms).fadeIn(duration: 350.ms).moveY(begin: 25, end: 0, duration: 300.ms, curve: Curves.easeOutSine),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(LucideIcons.keyRound, size: 64, color: controller.primaryColor)
            .animate()
            .scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut)
            .then(delay: 200.ms)
            // ================== PERBAIKAN DI SINI ==================
            .shake(hz: 4, duration: 300.ms, offset: const Offset(6, 0)), 
            // ================== AKHIR PERBAIKAN ==================
        const SizedBox(height: 20),
        Text(
          "Lupa Kata Sandi?",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey[850],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Jangan khawatir! Masukkan email akun Anda dan kami akan mengirimkan tautan untuk mengatur ulang kata sandi.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    // ... (kode _buildEmailForm tetap sama)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: controller.errorMessage.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withOpacity(0.3))
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.alertTriangle, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500))),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: "Alamat Email Terdaftar",
              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.normal),
              hintText: "contoh@email.com",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                child: Icon(LucideIcons.mail, color: controller.primaryColor.withOpacity(0.7), size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: controller.primaryColor, width: 1.8)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.2)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade600, width: 1.8)),
              errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            validator: controller.validateEmail,
            onChanged: (_) {
              if (controller.errorMessage.isNotEmpty) controller.errorMessage.value = '';
            },
            onTapOutside: (_) { FocusManager.instance.primaryFocus?.unfocus(); },
          ),
          const SizedBox(height: 28),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: controller.isLoading.value
                      ? Container()
                      : const Icon(LucideIcons.send, size: 20, color: Colors.white),
                  label: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text("Kirim Tautan Reset", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: controller.isLoading.value ? null : controller.sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: controller.primaryColor.withOpacity(0.7),
                    elevation: 3,
                    shadowColor: controller.primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ).animate(target: controller.isLoading.value ? 0 : 1)
                  .scaleXY(end: controller.isLoading.value ? 0.95 : 1.02, duration: 150.ms, curve: Curves.easeOut)
                  .then(delay: 0.ms)
                  .scaleXY(end: 1 / (controller.isLoading.value ? 0.95 : 1.02), duration: 150.ms, curve: Curves.easeIn),
              )),
            const SizedBox(height: 16),
             TextButton.icon(
                icon: Icon(LucideIcons.arrowLeft, size: 18, color: Colors.grey[600]),
                label: Text("Kembali ke Halaman Login", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                onPressed: controller.isLoading.value ? null : controller.backToLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    // ... (kode _buildSuccessState tetap sama)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(LucideIcons.mailCheck, size: 64, color: Colors.green.shade600)
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut)
              .then(delay: 200.ms)
              .shake(hz: 2, duration: 300.ms, offset: const Offset(3,0)), // Menggunakan offset
          const SizedBox(height: 24),
          Text(
            "Tautan Terkirim!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.successMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 14.5, height: 1.5),
              )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.home, size: 20, color: Colors.white),
              label: const Text("Kembali ke Login", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: controller.backToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}