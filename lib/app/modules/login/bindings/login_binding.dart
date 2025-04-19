import 'package:fluent_ai/app/modules/login/controllers/login_controller.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<ApiService>(() => ApiService());
  }
}