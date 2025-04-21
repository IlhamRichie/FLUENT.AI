import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart';
import 'package:fluent_ai/app/data/services/latihan_service.dart';

class LatihanBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LatihanService>(() => LatihanService());
    Get.lazyPut<LatihanController>(() => LatihanController());
  }
}