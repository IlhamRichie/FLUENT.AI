import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
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
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/progres/bindings/progres_binding.dart';
import '../modules/progres/views/progres_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/sertifikat/bindings/sertifikat_binding.dart';
import '../modules/sertifikat/views/sertifikat_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

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
  ];
}
