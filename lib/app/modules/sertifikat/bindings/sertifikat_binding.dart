// lib/app/modules/sertifikat/bindings/sertifikat_binding.dart
import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/sertifikat/controllers/sertifikat_controller.dart';

class SertifikatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SertifikatController>(
      () => SertifikatController(),
    );
  }
}