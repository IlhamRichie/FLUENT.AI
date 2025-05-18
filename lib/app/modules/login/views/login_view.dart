// lib/app/modules/login/views/login_view.dart
import 'package:fluent_ai/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, 
    ));

    return Scaffold(
      body: Obx(() => 
         controller.isLoading.value && controller.emailController.text.isEmpty && controller.passwordController.text.isEmpty
            ? _buildInitialLoadingScreen(context) 
            : _buildLoginContent(context),
      ),
    );
  }

  Widget _buildInitialLoadingScreen(BuildContext context) {
    // ... (kode _buildInitialLoadingScreen tetap sama)
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [controller.primaryColor.withOpacity(0.05), Colors.white, controller.primaryColor.withOpacity(0.15)],
          stops: const [0.0, 0.5, 1.0]
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app-logo-fluent',
              child: Image.asset("assets/images/logo FLUENT.png", height: 90)
                  .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                  .scaleXY(end: 1.1, duration: 1200.ms, curve: Curves.easeInOutSine)
                  .then(delay: 0.ms)
                  .tint(color: controller.primaryColor.withOpacity(0.3), duration: 1200.ms, curve: Curves.easeInOutSine),
            ),
            const SizedBox(height: 24),
            Text("FLUENT", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: controller.primaryColor, letterSpacing: 2)),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(controller.primaryColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text("Memeriksa sesi Anda...", style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }


  Widget _buildLoginContent(BuildContext context) {
    // ... (kode _buildLoginContent tetap sama)
     return Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade100, controller.primaryColor.withOpacity(0.08)],
            stops: const [0.0, 0.7, 1.0]
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  _buildLoginForm(context),
                  const SizedBox(height: 25),
                  _buildSocialLogin(context),
                  const SizedBox(height: 35),
                  _buildRegisterPrompt(context),
                ] 
                .animate(interval: 80.ms)
                .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ),
      );
  }


  Widget _buildHeader(BuildContext context) {
    // ... (kode _buildHeader tetap sama)
    return Column(
      children: [
        Hero(
          tag: 'app-logo-fluent', 
          child: Image.asset("assets/images/logo FLUENT.png", height: 75)
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut),
        ),
        const SizedBox(height: 10),
        Text("FLUENT", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: controller.primaryColor, letterSpacing: 1.5))
            .animate()
            .fadeIn(delay: 200.ms)
            .shimmer(delay: 400.ms, duration: 1800.ms, color: controller.primaryColor.withOpacity(0.5), angle: 45),
        const SizedBox(height: 20),
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, controller.currentTextIndex.value % 2 == 0 ? 0.3 : -0.3), end: Offset.zero).animate(animation),
                child: child,
              )),
              child: Text(
                controller.footerTexts.isNotEmpty ? controller.footerTexts[controller.currentTextIndex.value] : "Selamat Datang!",
                key: ValueKey<int>(controller.currentTextIndex.value),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[650], fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.4),
              ),
            )),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Animate( 
      effects: [FadeEffect(duration: 400.ms, delay: 200.ms), SlideEffect(begin: const Offset(0,0.1), curve: Curves.easeOut)],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 35, spreadRadius: 0, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Text("Masuk ke Akun Anda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 28),
            Obx(() => AnimatedOpacity( 
                  opacity: controller.errorMessage.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: controller.errorMessage.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.4))
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.alertCircle, color: Colors.red.shade600, size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500))),
                            ],
                          ),
                        )
                      : const SizedBox(height: 0), 
                )),
            // ================== PERBAIKAN PEMANGGILAN DI SINI ==================
            _buildTextFormField(
              textCtrl: controller.emailController, // Menggunakan 'textCtrl'
              hintText: "contoh@email.com",
              labelText: "Alamat Email",
              prefixIcon: LucideIcons.atSign,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 20),
            Obx(() => _buildTextFormField(
                  textCtrl: controller.passwordController, // Menggunakan 'textCtrl'
                  hintText: "••••••••",
                  labelText: "Kata Sandi",
                  prefixIcon: LucideIcons.lock,
                  obscureText: controller.obscureText.value,
                  validator: controller.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureText.value ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.grey[500], size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                    splashRadius: 20,
                  ),
                )),
            // ================== AKHIR PERBAIKAN PEMANGGILAN ==================
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.isLoading.value ? null : controller.navigateToForgotPassword,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
                child: Text("Lupa kata sandi?", style: TextStyle(color: controller.primaryColor, fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: controller.isLoading.value 
                        ? Container()
                        : const Icon(LucideIcons.logIn, size: 20, color: Colors.white),
                    label: controller.isLoading.value
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text("MASUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.primaryColor, foregroundColor: Colors.white,
                      disabledBackgroundColor: controller.primaryColor.withOpacity(0.6),
                      elevation: 4, shadowColor: controller.primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ).animate(target: controller.isLoading.value ? 0 : 1) 
                    .scaleXY(end: controller.isLoading.value ? 0.98 : 1.0, duration: 100.ms)
                    .shake(hz: controller.isLoading.value ? 0 : 2, duration: 300.ms, delay: 100.ms, offset: const Offset(1,0)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController textCtrl, // Nama parameter sudah benar di definisi
    required String hintText,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final LoginController loginCtrl = this.controller; 

    return Animate(
      effects: [FadeEffect(duration: 200.ms, delay: 100.ms), ScaleEffect(begin: const Offset(0.98,0.98), curve: Curves.easeOut)],
      child: TextFormField(
        controller: textCtrl, 
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.5, color: Colors.grey[850], fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14.5, fontWeight: FontWeight.normal),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.5),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(prefixIcon, color: loginCtrl.primaryColor, size: 20), 
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: loginCtrl.primaryColor.withOpacity(0.03), 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: loginCtrl.primaryColor, width: 2)), 
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400, width: 1.2)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
          errorStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.redAccent),
        ),
        validator: validator,
        onChanged: (_) => loginCtrl.errorMessage.value = '', 
        onTapOutside: (_){ FocusManager.instance.primaryFocus?.unfocus(); },
      ),
    );
  }


  Widget _buildSocialLogin(BuildContext context) {
    // ... (kode _buildSocialLogin tetap sama)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 0.8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("atau lanjutkan dengan", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 0.8)),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() => SizedBox( 
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: Image.asset("assets/images/google.webp", height: 22),
                label: Text("Masuk dengan Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.loginWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[400]?.withOpacity(0.5),
                  disabledBackgroundColor: Colors.grey.shade100,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildRegisterPrompt(BuildContext context) {
    // ... (kode _buildRegisterPrompt tetap sama)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun?", style: TextStyle(color: Colors.grey[600], fontSize: 14.5)),
        TextButton(
          onPressed: controller.isLoading.value || controller.isGoogleLoading.value ? null : controller.navigateToRegister,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
          child: Text("Daftar di sini", style: TextStyle(color: controller.primaryColor, fontSize: 14.5, fontWeight: FontWeight.bold)),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}