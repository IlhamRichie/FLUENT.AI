import 'package:get/get.dart';

import '../controllers/progres_controller.dart';

class ProgresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgresController>(
      () => ProgresController(),
    );
  }
}
