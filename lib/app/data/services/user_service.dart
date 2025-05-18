import 'package:get/get.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  // User data
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString avatar = 'assets/images/default_avatar.png'.obs;
  final RxString occupation = ''.obs;
  final RxString gender = ''.obs;

  Future<UserService> init() async {
    // You can add initialization logic here if needed
    return this;
  }

  // Update user data
  void setUserData({
    required String username,
    required String email,
    String? avatar,
    String? occupation,
    String? gender,
  }) {
    this.username.value = username;
    this.email.value = email;
    if (avatar != null) this.avatar.value = avatar;
    if (occupation != null) this.occupation.value = occupation;
    if (gender != null) this.gender.value = gender;
  }

  // Clear user data on logout
  void clearUserData() {
    username.value = '';
    email.value = '';
    avatar.value = 'assets/images/default_avatar.png';
    occupation.value = '';
    gender.value = '';
  }
}