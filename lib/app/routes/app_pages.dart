import 'package:get/get.dart';

import '../modules/activity_log/bindings/activity_log_binding.dart';
import '../modules/activity_log/views/activity_log_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/chatbot/bindings/chatbot_binding.dart';
import '../modules/chatbot/views/chatbot_view.dart';
import '../modules/device_management/bindings/device_management_binding.dart';
import '../modules/device_management/views/device_management_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/intro/bindings/intro_binding.dart';
import '../modules/intro/views/intro_view.dart';
import '../modules/latihan/bindings/latihan_binding.dart';
import '../modules/latihan/views/latihan_view.dart';
import '../modules/latihan_detail/bindings/latihan_detail_binding.dart';
import '../modules/latihan_detail/views/latihan_detail_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/lupa/bindings/lupa_binding.dart';
import '../modules/lupa/views/lupa_view.dart';
import '../modules/navbar/bindings/navbar_binding.dart';
import '../modules/navbar/views/navbar_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/progres/bindings/progres_binding.dart';
import '../modules/progres/views/progres_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/sertifikat/bindings/sertifikat_binding.dart';
import '../modules/sertifikat/views/sertifikat_view.dart';
import '../modules/sertifikat_detail/bindings/sertifikat_detail_binding.dart';
import '../modules/sertifikat_detail/views/sertifikat_detail_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/virtualhrd/bindings/virtualhrd_binding.dart';
import '../modules/virtualhrd/views/virtualhrd_view.dart';
import '../modules/wawancara/bindings/wawancara_binding.dart';
import '../modules/wawancara/views/wawancara_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.INTRO,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.LATIHAN,
      page: () => const LatihanView(),
      binding: LatihanBinding(),
    ),
    GetPage(
      name: _Paths.LATIHAN_DETAIL,
      page: () => const LatihanDetailView(),
      binding: LatihanDetailBinding(),
    ),
    GetPage(
      name: _Paths.PROGRES,
      page: () => const ProgresView(),
      binding: ProgresBinding(),
    ),
    GetPage(
      name: _Paths.SERTIFIKAT,
      page: () => const SertifikatView(),
      binding: SertifikatBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.NAVBAR,
      page: () => const NavbarView(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: _Paths.SERTIFIKAT_DETAIL,
      page: () => const SertifikatDetailView(),
      binding: SertifikatDetailBinding(),
    ),
    GetPage(
      name: _Paths.WAWANCARA,
      page: () => const WawancaraView(),
      binding: WawancaraBinding(),
    ),
    GetPage(
      name: _Paths.LUPA,
      page: () => const LupaView(),
      binding: LupaBinding(),
    ),
    GetPage(
      name: _Paths.VIRTUALHRD,
      page: () => const VirtualhrdView(),
      binding: VirtualhrdBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.CHATBOT,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_LOG,
      page: () => const ActivityLogView(),
      binding: ActivityLogBinding(),
    ),
    GetPage(
      name: _Paths.DEVICE_MANAGEMENT,
      page: () => const DeviceManagementView(),
      binding: DeviceManagementBinding(),
    ),
  ];
}
