// lib/app/modules/otp/views/otp_view.dart
import 'package:fluent_ai/app/modules/otp/controllers/otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';


class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: controller.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: controller.primaryColor, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeftCircle, color: Colors.grey[700], size: 28),
          onPressed: () => Get.back(),
          tooltip: 'Kembali',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(LucideIcons.shieldCheck, size: 80, color: controller.primaryColor)
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Masukkan Kode OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kode OTP telah dikirim ke email:\n${controller.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                controller: controller.otpController,
                onChanged: (value) => controller.currentOtp.value = value,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                autofocus: true,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onCompleted: (pin) => controller.verifyOtp(),
              ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.errorMessage.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13.5),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 28),
              Obx(() => SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: controller.isLoading.value
                          ? Container()
                          : const Icon(LucideIcons.checkCircle, size: 20),
                      label: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('VERIFIKASI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: controller.isLoading.value || controller.isResendingOtp.value
                          ? null
                          : controller.verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: controller.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => TextButton(
                    onPressed: controller.canResendOtp.value && !controller.isLoading.value && !controller.isResendingOtp.value
                        ? controller.resendOtp
                        : null,
                    child: controller.isResendingOtp.value
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: controller.primaryColor))
                        : Text(
                            controller.timerText,
                            style: TextStyle(
                              color: controller.canResendOtp.value ? controller.primaryColor : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  )),
            ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
          ),
        ),
      ),
    );
  }
}