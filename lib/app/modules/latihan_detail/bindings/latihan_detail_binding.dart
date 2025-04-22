import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/latihan_detail/controllers/latihan_detail_controller.dart';
import 'package:fluent_ai/app/data/services/latihan_service.dart';

class LatihanDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LatihanService>(() => LatihanService());
    Get.lazyPut<LatihanDetailController>(() => LatihanDetailController());
  }
}