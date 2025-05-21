import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Gantilah dengan Rute Login Sebenarnya jika ada
// Misal: import 'package:fluent_ai/app/routes/app_pages.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, dynamic>> introData = [
    {
      "image": "assets/images/intro1.png", // Ganti dengan path gambar relevan
      "title": "Selamat Datang di FLUENT! 🚀",
      "description":
          "Partner AI pribadimu untuk menguasai seni berbicara dan berekspresi dengan fasih. Tingkatkan kepercayaan dirimu sekarang!",
      "accentAlignment": Alignment.bottomLeft,
    },
    {
      "image": "assets/images/intro2.png", // Ganti dengan path gambar relevan
      "title": "Latih Ucapan & Ekspresimu! 🗣️✨",
      "description":
          "Asah intonasi, kejelasan vokal, dan ekspresi wajahmu. Dapatkan feedback instan untuk tampil memukau di setiap kesempatan penting.",
      "accentAlignment": Alignment.topRight,
    },
    {
      "image": "assets/images/intro3.png", // Ganti dengan path gambar relevan
      "title": "Simulasi Wawancara AI HRD! 💼🤖",
      "description":
          "Hadapi wawancara kerja tanpa gugup! Berlatih langsung dengan Virtual HRD kami dan dapatkan analisis mendalam untuk persiapan maksimal.",
      "accentAlignment": Alignment.topLeft,
    },
    {
      "image": "assets/images/logo FLUENT.png", // Ganti dengan path gambar relevan
      "title": "Siap Jadi Pribadi Terampil? 💪🎯",
      "description":
          "Mulai perjalananmu bersama FLUENT sekarang! Buka pintu menuju peluang tak terbatas dan raih kesuksesan yang kamu impikan.",
      "accentAlignment": Alignment.bottomRight,
    },
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void navigateToLogin() {
    // Ganti dengan navigasi ke halaman login/home yang sesungguhnya
    // Contoh: Get.offAllNamed(Routes.LOGIN);
    Get.offAllNamed('/login'); // Placeholder, ganti dengan rute yang benar
    print("Navigating to Login/Home page...");
  }
}

// Placeholder untuk Routes, jika belum ada
// class Routes {
//   static const LOGIN = '/login';
// }
