import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/navbar/controllers/navbar_controller.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(() => NavbarController());
  }
}