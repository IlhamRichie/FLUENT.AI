// lib/app/modules/register/views/register_view.dart
import 'package:fluent_ai/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

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
        // leading: IconButton(
        //   icon: Icon(LucideIcons.arrowLeftCircle, color: Colors.grey[700], size: 28),
        //   onPressed: () => Get.back(),
        //   tooltip: 'Kembali',
        // ),
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.white, controller.primaryColor.withOpacity(0.05), controller.primaryColor.withOpacity(0.1)],
            stops: const [0.2, 0.7, 1.0]
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Form(
              key: controller.registerFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  _buildRegisterForm(context),
                  const SizedBox(height: 25),
                  _buildSocialRegister(context),
                  const SizedBox(height: 35),
                  _buildLoginPrompt(context),
                ]
                .animate(interval: 70.ms)
                .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'app-logo-fluent',
          child: Image.asset("assets/images/logo FLUENT.png", height: 65)
              .animate().scale(delay:100.ms, duration: 400.ms, curve: Curves.elasticOut),
        ),
        const SizedBox(height: 10),
        Text("Buat Akun Baru", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: controller.primaryColor))
            .animate().fadeIn(delay: 200.ms).shimmer(delay: 300.ms, duration: 1600.ms, color: controller.primaryColor.withOpacity(0.4)),
        const SizedBox(height: 16),
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, controller.currentTextIndex.value % 2 == 0 ? 0.25 : -0.25), end: Offset.zero).animate(animation),
                child: child,
              )),
              child: Text(
                controller.headerTexts.isNotEmpty ? controller.headerTexts[controller.currentTextIndex.value] : "Gabung dan mulai perjalananmu!",
                key: ValueKey<int>(controller.currentTextIndex.value),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[650], fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
              ),
            )),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 400.ms, delay: 150.ms), SlideEffect(begin: const Offset(0,0.08), curve: Curves.easeOut)],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 30, spreadRadius: 0, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Text("Isi Detail Akun", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 24),
            Obx(() => AnimatedOpacity(
                  opacity: controller.errorMessage.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: controller.errorMessage.isNotEmpty
                      ? Container( 
                        width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.3))),
                        child: Row(children: [
                            Icon(LucideIcons.alertCircle, color: Colors.red.shade600, size: 20), const SizedBox(width: 10),
                            Expanded(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500))),
                        ]),
                      ) : const SizedBox(height: 0),
                )),
            _buildTextFormField(textCtrl: controller.usernameController, labelText: "Nama Lengkap", hintText: "Masukkan nama Anda", prefixIcon: LucideIcons.user, validator: controller.validateUsername),
            const SizedBox(height: 16),
            _buildTextFormField(textCtrl: controller.emailController, labelText: "Alamat Email", hintText: "contoh@email.com", prefixIcon: LucideIcons.atSign, keyboardType: TextInputType.emailAddress, validator: controller.validateEmail),
            const SizedBox(height: 16),
            // ================== PEMANGGILAN DROPDOWN YANG DIPERBAIKI ==================
            Obx(() => _buildDropdownFormField(
                  selectedValue: controller.selectedGender, // Kirim RxString
                  items: controller.genders,
                  onChanged: (value) { if (value != null) controller.selectedGender.value = value; },
                  labelText: "Jenis Kelamin",
                  prefixIcon: LucideIcons.users,
                )),
            const SizedBox(height: 16),
            Obx(() => _buildDropdownFormField(
                  selectedValue: controller.selectedJob, // Kirim RxString
                  items: controller.jobs,
                  onChanged: (value) { if (value != null) controller.selectedJob.value = value; },
                  labelText: "Pekerjaan",
                  prefixIcon: LucideIcons.briefcase,
                )),
            // ================== AKHIR PEMANGGILAN DROPDOWN YANG DIPERBAIKI ==================
            const SizedBox(height: 16),
            Obx(() => _buildTextFormField(textCtrl: controller.passwordController, labelText: "Kata Sandi", hintText: "Minimal 6 karakter", prefixIcon: LucideIcons.lock, obscureText: controller.obscureText.value, validator: controller.validatePassword, suffixIcon: _buildObscureToggle(controller.obscureText, controller.togglePasswordVisibility))),
            const SizedBox(height: 16),
            Obx(() => _buildTextFormField(textCtrl: controller.confirmPasswordController, labelText: "Konfirmasi Kata Sandi", hintText: "Ulangi kata sandi", prefixIcon: LucideIcons.shieldCheck, obscureText: controller.obscureConfirmText.value, validator: controller.validateConfirmPassword, suffixIcon: _buildObscureToggle(controller.obscureConfirmText, controller.toggleConfirmPasswordVisibility))),
            const SizedBox(height: 28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: controller.isLoading.value ? Container() : const Icon(LucideIcons.userPlus, size: 20, color: Colors.white),
                    label: controller.isLoading.value
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text("DAFTAR AKUN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.primaryColor, foregroundColor: Colors.white,
                      disabledBackgroundColor: controller.primaryColor.withOpacity(0.6),
                      elevation: 4, shadowColor: controller.primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ).animate(target: controller.isLoading.value ? 0:1).scaleXY(end: controller.isLoading.value ? 0.98 : 1.0).shake(hz: controller.isLoading.value ? 0:2, duration: 200.ms, delay: 50.ms),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController textCtrl,
    required String hintText,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final RegisterController registerCtrl = this.controller; 

    return Animate(
      effects: [FadeEffect(duration: 200.ms, delay: 100.ms), ScaleEffect(begin: const Offset(0.98,0.98), curve: Curves.easeOut)],
      child: TextFormField(
        controller: textCtrl,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.0, color: Colors.grey[850], fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14.0, fontWeight: FontWeight.normal),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(prefixIcon, color: registerCtrl.primaryColor, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: registerCtrl.primaryColor.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: registerCtrl.primaryColor, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400, width: 1.2)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
          errorStyle: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.redAccent),
        ),
        validator: validator,
        onChanged: (_) => registerCtrl.errorMessage.value = '',
        onTapOutside: (_){ FocusManager.instance.primaryFocus?.unfocus(); },
      ),
    );
  }

  // ================== DEFINISI DROPDOWN YANG DIPERBAIKI ==================
  Widget _buildDropdownFormField({
    required RxString selectedValue, // Menerima RxString
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String labelText,
    required IconData prefixIcon,
  }) {
    final RegisterController registerCtrl = this.controller;

    return Animate(
      effects: [FadeEffect(duration: 200.ms, delay: 100.ms), ScaleEffect(begin: const Offset(0.98,0.98), curve: Curves.easeOut)],
      // Hapus Obx dari sini
      child: DropdownButtonFormField<String>(
          value: selectedValue.value, // Akses .value di sini karena Obx ada di pemanggil
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: TextStyle(fontSize: 15.0, color: Colors.grey[800], fontWeight: FontWeight.w500)))).toList(),
          onChanged: onChanged,
          style: TextStyle(fontSize: 15.0, color: Colors.grey[850], fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14.0, fontWeight: FontWeight.normal),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 12.0),
              child: Icon(prefixIcon, color: registerCtrl.primaryColor, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: registerCtrl.primaryColor.withOpacity(0.03),
            contentPadding: const EdgeInsets.fromLTRB(0, 16, 10, 16), // Disesuaikan
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: registerCtrl.primaryColor, width: 2)),
          ),
          icon: Icon(LucideIcons.chevronDown, color: registerCtrl.primaryColor, size: 20),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
        )
    );
  }
  // ================== AKHIR DEFINISI DROPDOWN YANG DIPERBAIKI ==================

  Widget _buildObscureToggle(RxBool obscureState, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(obscureState.value ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.grey[500], size: 20),
      onPressed: onPressed,
      splashRadius: 20,
    );
  }

  Widget _buildSocialRegister(BuildContext context) {
    // ... (kode _buildSocialRegister tetap sama)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 0.8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("atau daftar dengan", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 0.8)),
          ],
        ),
        const SizedBox(height: 20),
        Obx(()=> SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: Image.asset("assets/images/google.webp", height: 22),
                label: Text("Daftar dengan Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.registerWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[400]?.withOpacity(0.5),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    // ... (kode _buildLoginPrompt tetap sama)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sudah punya akun?", style: TextStyle(color: Colors.grey[600], fontSize: 14.5)),
        TextButton(
          onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.navigateToLogin,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
          child: Text("Masuk di sini", style: TextStyle(color: controller.primaryColor, fontSize: 14.5, fontWeight: FontWeight.bold)),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}