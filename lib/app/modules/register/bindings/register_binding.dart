// import 'package:fluent_ai/app/modules/register/controllers/register_controller.dart';
// import 'package:get/get.dart';
// // import 'package:fluent_ai/app/data/services/api_service.dart';

// class RegisterBinding implements Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<RegisterController>(() => RegisterController());
//     // Get.lazyPut<ApiService>(() => ApiService());
//   }
// }

import 'package:fluent_ai/app/modules/register/controllers/register_controller.dart';
import 'package:get/get.dart';

class RegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}