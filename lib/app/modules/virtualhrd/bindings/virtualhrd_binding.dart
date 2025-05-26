import 'package:fluent_ai/app/modules/virtualhrd/controllers/virtual_hrd_intro_controller.dart';
import 'package:fluent_ai/app/modules/virtualhrd/controllers/virtualhrd_controller.dart';
import 'package:get/get.dart';

class VirtualhrdBinding extends Bindings {
  @override
  void dependencies() {
    // Controller untuk halaman Intro
    Get.lazyPut<VirtualhrdIntroController>(
      () => VirtualhrdIntroController(),
    );

    // Controller untuk halaman Sesi Utama Virtual HRD
    // Tidak perlu fenix: true di sini jika setiap sesi adalah instance baru
    // atau jika state di-reset dengan benar saat sesi baru dimulai.
    Get.lazyPut<VirtualhrdController>(
      () => VirtualhrdController(),
    );
  }
}