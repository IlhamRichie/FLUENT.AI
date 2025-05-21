// lib/app/modules/home/controllers/home_controller.dart
import 'package:fluent_ai/app/modules/home/models/aktifitas_model.dart';
import 'package:fluent_ai/app/modules/home/models/tipe_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:fluent_ai/app/data/services/user_service.dart'; // <-- HAPUS INI
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Secure Storage
import 'dart:convert'; // Import dart:convert
// import 'package:fluent_ai/app/data/services/api_service.dart'; // Jika perlu panggil API

class HomeController extends GetxController {
  final isLoading = true.obs;
  // final UserService userService = Get.find<UserService>(); // <-- HAPUS INI
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage(); // Tambahkan storage

  // Data Observables untuk info pengguna dari storage
  final RxString userName = ''.obs;
  final RxString userAvatar = ''.obs; // Jika Anda menyimpan URL avatar

  // Data Observables (tetap sama)
  final averageScore = 0.0.obs;
  final consecutiveDays = 0.obs;
  final tokens = 0.obs;
  final overallProgress = 0.0.obs;

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<PracticeTypeModel> practiceTypes = <PracticeTypeModel>[].obs;
  final recommendationText = ''.obs;

  final List<Map<String, dynamic>> quickActionItems = [
    {
      'title': 'Wawancara',
      'icon': LucideIcons.briefcase,
      'colorHex': '#3498DB',
      'practiceType': 'Wawancara'
    },
    {
      'title': 'Public Speaking',
      'icon': LucideIcons.megaphone,
      'colorHex': '#2ECC71',
      'practiceType': 'Public Speaking'
    },
    {
      'title': 'Ekspresi Wajah',
      'icon': LucideIcons.smile,
      'colorHex': '#E67E22',
      'practiceType': 'Ekspresi'
    },
    {
      'title': 'Semua Latihan',
      'icon': LucideIcons.layoutGrid,
      'colorHex': '#9B59B6',
      'navigateTo': '/latihan'
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserData(); // Panggil method untuk load user data
    fetchHomeData();
  }

  Future<void> _loadUserData() async {
    try {
      final storedUserData = await _storage.read(key: 'user_data');
      if (storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;
        userName.value = userDataMap['username'] ?? 'Pengguna';
        userAvatar.value = userDataMap['profile_picture'] ??
            ''; // Path ke default avatar jika null
        // Anda bisa load data lain seperti email, dll jika diperlukan di Home
        debugPrint("Home: User data loaded - ${userName.value}");
      } else {
        userName.value = 'Pengguna'; // Default jika tidak ada data
        debugPrint("Home: No user data found in storage.");
      }
    } catch (e) {
      debugPrint("Home: Error loading user data from storage: $e");
      userName.value = 'Pengguna';
    }
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    // Panggil _loadUserData di sini juga untuk memastikan data user ada sebelum load data home lain
    // atau pastikan _loadUserData selesai sebelum fetchHomeData dijalankan jika ada dependensi.
    // Untuk contoh ini, kita anggap _loadUserData di onInit cukup.

    await Future.delayed(const Duration(milliseconds: 1800));

    averageScore.value = 82.5;
    consecutiveDays.value = 12;
    tokens.value = 1500;
    overallProgress.value = 0.78;

    activities.assignAll([
      ActivityModel(
          id: 'act1',
          title: 'Simulasi Wawancara Teknis',
          date: 'Kemarin, 10:30',
          score: 88,
          icon: LucideIcons.briefcase,
          colorHex: '#3498DB'),
      ActivityModel(
          id: 'act2',
          title: 'Presentasi Proyek Tim',
          date: '2 hari lalu, 15:00',
          score: 92,
          icon: LucideIcons.megaphone,
          colorHex: '#2ECC71'),
      ActivityModel(
          id: 'act3',
          title: 'Latihan Intonasi Cerita',
          date: '3 hari lalu, 09:00',
          score: 78,
          icon: LucideIcons.smile,
          colorHex: '#E67E22'),
    ]);
    practiceTypes.assignAll([
      PracticeTypeModel(id: 'pt1', title: 'Kecepatan Bicara'),
      PracticeTypeModel(id: 'pt2', title: 'Pengurangan Filler Words'),
      PracticeTypeModel(id: 'pt3', title: 'Kontak Mata'),
    ]);
    recommendationText.value =
        'Kamu tampil hebat! Fokus selanjutnya bisa pada variasi intonasi untuk membuat penyampaian lebih menarik.';

    isLoading.value = false;
  }

  void navigateToPractice(String practiceType) {
    /* ... (tetap sama) ... */
    Get.snackbar(
      'Mulai Latihan Cepat',
      'Navigasi ke latihan: $practiceType',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: parseColor(quickActionItems
              .firstWhere((item) => item['title'] == practiceType)['colorHex'])
          .withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void navigateToLatihanPage() => Get.toNamed('/latihan');
  void viewAllActivities() {
    /* ... (tetap sama) ... */
    Get.snackbar('Aktivitas', 'Menampilkan semua aktivitas...',
        snackPosition: SnackPosition.BOTTOM);
  }

  Color parseColor(String hexColor) {
    /* ... (tetap sama) ... */
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}
