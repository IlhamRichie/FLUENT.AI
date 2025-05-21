// lib/app/modules/profil/controllers/profil_controller.dart
import 'package:fluent_ai/app/modules/profil/models/profil_model.dart';
import 'package:fluent_ai/app/modules/profil/models/setting_model.dart';
import 'package:fluent_ai/app/modules/profil/models/stats_model.dart';
import 'package:fluent_ai/app/modules/profil/views/statistik_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilController extends GetxController {
  final isLoading = true.obs;

  // Data Observables menggunakan Model
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<UserStatsModel?> userStats = Rx<UserStatsModel?>(null);
  final RxList<SettingsSectionModel> settingsOptions =
      <SettingsSectionModel>[].obs;

  final Color primaryColor =
      const Color(0xFFD84040); // Warna utama aplikasi Anda

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    await Future.delayed(
        const Duration(milliseconds: 1200)); // Simulasi loading

    userProfile.value = UserProfileModel(
      name: 'Budi Doremi',
      email: 'budi.doremi@example.com',
      username: 'budidoremi99',
      avatarAsset:
          'assets/images/profil.png', // Ganti dengan path aset avatar Anda
      joinedDate: '15 Januari 2024',
    );

    userStats.value = UserStatsModel(
      totalSessions: 128,
      consecutiveDays: 21,
      averageScore: 88.5,
      highestScore: 97,
    );

    settingsOptions.assignAll([
      SettingsSectionModel(title: 'Akun', items: [
        SettingsItemModel(
            title: 'Edit Profil',
            icon: LucideIcons.userCog,
            action: 'edit_profile'),
        SettingsItemModel(
            title: 'Ubah Password',
            icon: LucideIcons.keyRound,
            action: 'change_password'),
        SettingsItemModel(
            title: 'Preferensi Bahasa',
            icon: LucideIcons.languages,
            action: 'change_language',
            value: 'Indonesia'),
        // --- PERUBAHAN DI SINI ---
        SettingsItemModel(
            title: 'Statistik BPS',
            icon: LucideIcons.lineChart, // Mengganti ikon menjadi lebih relevan
            action: 'show_bps_stats'), // Mengganti action
        // value: 'Indonesia' dihapus karena tidak relevan lagi
        // --- AKHIR PERUBAHAN ---
      ]),
      SettingsSectionModel(title: 'Notifikasi', items: [
        SettingsItemModel(
            title: 'Notifikasi Umum',
            icon: LucideIcons.bellRing,
            action: 'toggle_general_notif',
            value: true,
            isSwitch: true),
        SettingsItemModel(
            title: 'Notifikasi Latihan',
            icon: LucideIcons.dumbbell,
            action: 'toggle_practice_notif',
            value: false,
            isSwitch: true),
      ]),
      SettingsSectionModel(title: 'Bantuan & Info', items: [
        SettingsItemModel(
            title: 'Panduan Pengguna',
            icon: LucideIcons.bookOpen,
            action: 'show_guide'),
        SettingsItemModel(
            title: 'Hubungi Kami',
            icon: LucideIcons.mailQuestion,
            action: 'contact_us'),
        SettingsItemModel(
            title: 'Syarat & Ketentuan',
            icon: LucideIcons.fileText,
            action: 'show_terms'),
        SettingsItemModel(
            title: 'Tentang Aplikasi',
            icon: LucideIcons.info,
            action: 'show_about',
            value: 'Versi 1.0.0'),
      ]),
    ]);

    isLoading.value = false;
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              // Lakukan proses logout (clear session, dll)
              Get.offAllNamed(
                  '/login'); // Navigasi ke halaman login (pastikan route ada)
              Get.snackbar('Logout', 'Anda telah berhasil logout.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showEditDialog() {
    Get.defaultDialog(
        title: "Edit Profil",
        titleStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        content: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Fitur edit profil akan segera hadir untuk Anda!"),
        ),
        confirm: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Oke", style: TextStyle(color: Colors.white))));
  }

  void toggleSetting(String action, bool value) {
    // Cari item setting dan update nilainya
    for (var section in settingsOptions) {
      for (var item in section.items) {
        if (item.action == action && item.isSwitch) {
          item.value = value;
          settingsOptions
              .refresh(); // Penting untuk memberitahu Obx agar rebuild
          Get.snackbar(
            'Pengaturan Disimpan',
            '${item.title} telah diubah menjadi ${value ? "Aktif" : "Nonaktif"}.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    }
  }

  void handleSettingsTap(SettingsItemModel item) {
    switch (item.action) {
      case 'edit_profile':
        showEditDialog();
        break;
      case 'change_password':
        Get.snackbar('Ubah Password', 'Fitur ini akan segera hadir!',
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 'change_language':
        Get.snackbar(
            'Ubah Bahasa', 'Saat ini hanya mendukung Bahasa Indonesia.',
            snackPosition: SnackPosition.BOTTOM);
        break;
      // --- PERUBAHAN DI SINI ---
      case 'show_bps_stats':
        Get.to(() => const StatisticView()); // Navigasi ke StatisticView
        break;
      // --- AKHIR PERUBAHAN ---
      default:
        if (!item.isSwitch) {
          Get.snackbar(
              item.title, 'Anda mengetuk ${item.title}. Fitur akan datang!',
              snackPosition: SnackPosition.BOTTOM);
        }
    }
  }

  Color parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return primaryColor; // Default
    }
  }
}
