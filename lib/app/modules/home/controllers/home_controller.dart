// lib/app/modules/home/controllers/home_controller.dart
import 'package:fluent_ai/app/modules/home/models/aktifitas_model.dart';
import 'package:fluent_ai/app/modules/home/models/tipe_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluent_ai/app/data/services/user_service.dart';
// import 'package:fluent_ai/app/routes/app_pages.dart'; // Jika ingin navigasi ke /latihan

class HomeController extends GetxController {
  final isLoading = true.obs;
  final UserService userService =
      Get.find<UserService>(); // Dapatkan instance UserService

  // Data Observables
  final averageScore = 0.0.obs;
  final consecutiveDays = 0.obs;
  final tokens = 0.obs;
  final overallProgress = 0.0.obs; // Untuk progress bar utama

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<PracticeTypeModel> practiceTypes = <PracticeTypeModel>[].obs;
  final recommendationText = ''.obs;

  // Quick Actions Data (bisa statis atau dari remote)
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
    }, // Rute ke halaman Latihan
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    await Future.delayed(
        const Duration(milliseconds: 1800)); // Simulasi loading

    // Isi data dummy
    averageScore.value = 82.5;
    consecutiveDays.value = 12;
    tokens.value = 1500;
    overallProgress.value = 0.78; // 78%

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
    Get.snackbar(
      'Mulai Latihan Cepat',
      'Navigasi ke latihan: $practiceType',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: parseColor(quickActionItems
              .firstWhere((item) => item['title'] == practiceType)['colorHex'])
          .withOpacity(0.9),
      colorText: Colors.white,
    );
    // Implementasi navigasi ke halaman latihan spesifik
    // Contoh: Get.toNamed('/latihan/detail', arguments: {'type': practiceType});
  }

  void navigateToLatihanPage() {
    // Pastikan Anda punya route '/latihan' yang terdefinisi
    Get.toNamed(
        '/latihan'); // Menggunakan Get.toNamed jika ini halaman baru, atau Get.offNamed jika bagian dari bottom nav
  }

  void viewAllActivities() {
    Get.snackbar('Aktivitas', 'Menampilkan semua aktivitas...',
        snackPosition: SnackPosition.BOTTOM);
    // Navigasi ke halaman daftar semua aktivitas
  }

  Color parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}
