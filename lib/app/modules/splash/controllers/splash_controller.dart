import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxDouble opacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    startAnimation();
  }

  void startAnimation() {
    // Memulai animasi fade-in
    Future.delayed(const Duration(milliseconds: 300), () {
      opacity.value = 1.0;
    });

    // Navigasi ke intro setelah animasi selesai
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed('/intro');
    });
  }
}