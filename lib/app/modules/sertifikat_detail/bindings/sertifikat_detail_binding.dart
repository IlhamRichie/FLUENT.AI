import 'package:get/get.dart';

import '../controllers/sertifikat_detail_controller.dart';

class SertifikatDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SertifikatDetailController>(
      () => SertifikatDetailController(),
    );
  }
}
