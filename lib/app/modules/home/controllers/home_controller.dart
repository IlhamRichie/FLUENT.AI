import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeController extends GetxController {
  final Color primaryColor = const Color(0xFFD84040);

  // User data
  final RxString username = 'fluentcapstone'.obs;
  final RxDouble averageScore = 0.0.obs;

  // Stats
  final RxInt speechCount = 0.obs;
  final RxInt expressionCount = 0.obs;
  final RxInt narrativeCount = 1.obs;
  final RxInt coverLetterCount = 0.obs;

  final RxString countdownText = '23:59'.obs; // Hitung mundur awal
  final RxBool isCountdownActive = false.obs; // Status hitung mundur

  // Token
  final RxInt tokens = 0.obs;
  final RxBool hasTokens = false.obs;

  // Latest interview
  final RxString lastInterviewDate = '19 April 2025 | 14:10'.obs;
  final RxString lastInterviewPosition = 'mobile developer'.obs;
  final RxString lastInterviewScore = 'N/A'.obs;

  // AI Interviews
  final RxList<Map<String, dynamic>> aiInterviews = <Map<String, dynamic>>[
    {
      'title': 'Wawancara AI - Mobile Developer',
      'description':
          'Latihan wawancara untuk posisi Mobile Developer dengan AI',
      'date': 'Hari Ini, 14:30',
      'progress': 0.65,
      'score': 78,
      'status': 'Belum Selesai',
      'category': 'Teknologi',
    },
    {
      'title': 'Wawancara AI - Product Manager',
      'description': 'Simulasi wawancara produk dengan skenario nyata',
      'date': 'Besok, 10:00',
      'progress': 0.0,
      'score': null,
      'status': 'Terjadwal',
      'category': 'Bisnis',
    },
    {
      'title': 'Wawancara AI - UX Designer',
      'description': 'Latihan presentasi portfolio dan case study',
      'date': 'Kemarin, 09:15',
      'progress': 1.0,
      'score': 85,
      'status': 'Selesai',
      'category': 'Desain',
    },
  ].obs;

  // Interview Levels
  final RxList<Map<String, dynamic>> interviewLevels = [
    {
      'level': 'Mudah',
      'color': Colors.green,
      'icon': LucideIcons.smile,
      'questions': 5,
      'time': '10-15 menit',
      'description': 'Pertanyaan dasar untuk pemula',
      'completed': 3,
    },
    {
      'level': 'Medium',
      'color': Colors.orange,
      'icon': LucideIcons.meh,
      'questions': 8,
      'time': '20-25 menit',
      'description': 'Pertanyaan menengah dengan skenario',
      'completed': 1,
    },
    {
      'level': 'Sulit',
      'color': Colors.red,
      'icon': LucideIcons.frown,
      'questions': 12,
      'time': '30-40 menit',
      'description': 'Pertanyaan teknis mendalam',
      'completed': 0,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // Simulasikan loading data
    Future.delayed(const Duration(seconds: 1), () {
      hasTokens.value = false;
      averageScore.value = 76.5;
    });
  }

  void refreshData() {
    loadUserData();
  }

  void navigateToNotification() {
    Get.snackbar('Notifikasi', 'Fitur notifikasi akan datang segera!');
  }

  void navigateToSettings() {
    Get.snackbar('Pengaturan', 'Fitur pengaturan akan datang segera!');
  }

  void startCountdown() {
    isCountdownActive.value = true;
    int remainingSeconds = 24 * 60 * 60 - 1; // 23:59:59 detik

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        int hours = remainingSeconds ~/ 3600;
        int minutes = (remainingSeconds % 3600) ~/ 60;
        int seconds = remainingSeconds % 60;

        countdownText.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } else {
        timer.cancel();
        isCountdownActive.value = false;
        hasTokens.value = false; // Reset token setelah hitung mundur selesai
      }
    });
  }

  void getFreeTokens() {
    tokens.value += 5;
    hasTokens.value = true;
    Get.snackbar(
      'Token Gratis!',
      'Kamu dapat 5 token gratis',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void startInterview(String level) {
    Get.snackbar(
      'Mulai Latihan',
      'Memulai wawancara level $level',
      backgroundColor:
          interviewLevels.firstWhere((l) => l['level'] == level)['color'],
      colorText: Colors.white,
    );
  }
}
