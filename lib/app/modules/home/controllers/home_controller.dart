import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;

  final Color primaryColor = const Color(0xFFD84040);
  final RxInt currentTabIndex = 0.obs;

  // User data
  final RxString username = 'Ilham Rigan'.obs;
  final RxString userAvatar = 'assets/images/default_avatar.png'.obs;
  final RxDouble averageScore = 76.5.obs;

  // Stats
  final RxInt speechCount = 12.obs;
  final RxInt expressionCount = 8.obs;
  final RxInt narrativeCount = 5.obs;
  final RxInt consecutiveDays = 3.obs;

  // Token
  final RxInt tokens = 15.obs;
  final RxBool hasTokens = true.obs;

  // Latest activity
  final RxList<Map<String, dynamic>> activities = <Map<String, dynamic>>[
    {
      'type': 'Latihan',
      'title': 'Public Speaking - TED Style',
      'date': 'Hari Ini, 10:30',
      'score': 82,
      'icon': LucideIcons.mic2,
      'color': Colors.blue,
    },
    {
      'type': 'Latihan',
      'title': 'Wawancara Kerja - Tech',
      'date': 'Kemarin, 14:15',
      'score': 75,
      'icon': LucideIcons.briefcase,
      'color': Colors.green,
    },
    {
      'type': 'Latihan',
      'title': 'Ekspresi Wajah',
      'date': '2 Hari Lalu, 09:45',
      'score': 88,
      'icon': LucideIcons.smile,
      'color': Colors.orange,
    },
  ].obs;

  // Practice types
  final RxList<Map<String, dynamic>> practiceTypes = <Map<String, dynamic>>[
    {
      'title': 'Simulasi Wawancara AI',
      'description': 'Latihan wawancara dengan berbagai skenario',
      'icon': LucideIcons.briefcase,
      'level': 'Medium',
      'time': '15-20 menit',
    },
    {
      'title': 'Public Speaking',
      'description': 'Latihan presentasi ala TED Talk',
      'icon': LucideIcons.mic2,
      'level': 'Sulit',
      'time': '20-30 menit',
    },
    {
      'title': 'Latihan Ekspresi',
      'description': 'Perbaikan ekspresi wajah dan gestur',
      'icon': LucideIcons.smile,
      'level': 'Mudah',
      'time': '10-15 menit',
    },
    {
      'title': 'Latihan Narasi',
      'description': 'Meningkatkan alur cerita dan struktur bicara',
      'icon': LucideIcons.text,
      'level': 'Medium',
      'time': '15-20 menit',
    },
  ].obs;

  // Badges
  final RxList<Map<String, dynamic>> badges = <Map<String, dynamic>>[
    {
      'title': 'Pembicara Pemula',
      'description': 'Menyelesaikan 5 sesi latihan',
      'icon': LucideIcons.award,
      'unlocked': true,
    },
    {
      'title': 'Konsisten 3 Hari',
      'description': 'Latihan 3 hari berturut-turut',
      'icon': LucideIcons.flame,
      'unlocked': true,
    },
    {
      'title': 'Ekspresi Master',
      'description': 'Skor ekspresi di atas 85',
      'icon': LucideIcons.smile,
      'unlocked': false,
    },
  ].obs;

  // Bottom navigation
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

  void navigateToPractice(String type) {
    Get.toNamed('/latihan-detail', arguments: {'type': type});
  }

  void showPracticeDialog() {
    Get.defaultDialog(
      title: 'Mulai Latihan',
      content: Column(
        children: [
          const Text('Pilih jenis latihan:'),
          const SizedBox(height: 16),
          ...practiceTypes.map((type) => ListTile(
                leading: Icon(type['icon']),
                title: Text(type['title']),
                subtitle: Text(type['description']),
                onTap: () => navigateToPractice(type['title']),
              )),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Simulate loading data when controller initializes
    loadData();
  }

  // Simulate loading data
  Future<void> loadData() async {
    isLoading.value = true;
    await Future.delayed(
        const Duration(seconds: 1)); // Simulate network request
    isLoading.value = false;
  }

  // Refresh data
  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate refresh
    isLoading.value = false;
  }
}
