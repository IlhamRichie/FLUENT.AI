import 'package:get/get.dart';

import '../controllers/virtualhrd_controller.dart';

class VirtualhrdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VirtualhrdController>(
      () => VirtualhrdController(),
    );
  }
}
