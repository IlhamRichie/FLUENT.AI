import 'package:get/get.dart';

import '../controllers/device_management_controller.dart';

class DeviceManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceManagementController>(
      () => DeviceManagementController(),
    );
  }
}
