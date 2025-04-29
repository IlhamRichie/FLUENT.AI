import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavbarController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  final List<Map<String, dynamic>> bottomNavItems = [
    {
      'label': 'Home',
      'icon': LucideIcons.home,
      'route': '/home',
    },
    {
      'label': 'Latihan',
      'icon': LucideIcons.mic2,
      'route': '/latihan',
    },
    {
      'label': 'Progres',
      'icon': LucideIcons.trendingUp,
      'route': '/progres',
    },
    {
      'label': 'Sertifikat',
      'icon': LucideIcons.award,
      'route': '/sertifikat',
    },
    {
      'label': 'Akun',
      'icon': LucideIcons.user,
      'route': '/profil',
    },
  ];

  void changeTab(int index) {
    currentTabIndex.value = index;
    Get.toNamed(bottomNavItems[index]['route']);
  }
}