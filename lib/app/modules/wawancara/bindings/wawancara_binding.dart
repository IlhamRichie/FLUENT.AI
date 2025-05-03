import 'package:get/get.dart';

import '../controllers/wawancara_controller.dart';

class WawancaraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WawancaraController>(
      () => WawancaraController(),
    );
  }
}
