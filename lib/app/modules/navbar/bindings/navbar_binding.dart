import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';

class NavbarBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NavbarController>(NavbarController(), permanent: true);
  }
}
