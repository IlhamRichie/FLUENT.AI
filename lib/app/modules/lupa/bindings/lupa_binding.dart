// lib/app/modules/lupa/bindings/lupa_binding.dart
import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/lupa/controllers/lupa_controller.dart'; // Sesuaikan path

class LupaBinding extends Bindings { // Ganti nama class jika perlu
  @override
  void dependencies() {
    Get.lazyPut<LupaPasswordController>( // Sesuaikan dengan nama controller Anda
      () => LupaPasswordController(),    // Sesuaikan dengan nama controller Anda
    );
  }
}