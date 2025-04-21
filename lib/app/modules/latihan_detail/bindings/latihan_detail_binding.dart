import 'package:get/get.dart';

import '../controllers/latihan_detail_controller.dart';

class LatihanDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LatihanDetailController>(
      () => LatihanDetailController(),
    );
  }
}
