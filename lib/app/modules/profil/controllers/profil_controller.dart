// lib/app/modules/profil/controllers/profil_controller.dart
import 'package:fluent_ai/app/modules/profil/models/profil_model.dart';
import 'package:fluent_ai/app/modules/profil/models/setting_model.dart';
import 'package:fluent_ai/app/modules/profil/models/stats_model.dart';
import 'package:fluent_ai/app/modules/profil/views/statistik_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';

class ProfilController extends GetxController {
  final isLoading = true.obs;
  final isUpdatingProfile = false.obs;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<UserStatsModel?> userStats = Rx<UserStatsModel?>(null);
  final RxList<SettingsSectionModel> settingsOptions =
      <SettingsSectionModel>[].obs;

  final Color primaryColor = const Color(0xFFD84040);

  late TextEditingController editUsernameController;
  late TextEditingController editOccupationController;
  final RxString editSelectedGender = 'Pria'.obs;
  final List<String> genderOptions = ['Pria', 'Wanita', 'Lainnya'];

  @override
  void onInit() {
    super.onInit();
    editUsernameController = TextEditingController();
    editOccupationController = TextEditingController();
    fetchProfileData();
  }

  @override
  void onClose() {
    editUsernameController.dispose();
    editOccupationController.dispose();
    super.onClose();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    await _loadUserProfileFromStorage();

    userStats.value = UserStatsModel(
      // Data dummy, ganti dengan fetch API
      totalSessions: 128, consecutiveDays: 21,
      averageScore: 88.5, highestScore: 97,
    );
    _buildSettingsOptions();
    isLoading.value = false;
  }

  Future<void> _loadUserProfileFromStorage() async {
    try {
      final storedUserData = await _storage.read(key: 'user_data');
      if (storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;

        // Pastikan ada nilai default jika null dari storage
        String nameFromStorage =
            userDataMap['name'] ?? userDataMap['username'] ?? 'Pengguna';
        String usernameFromStorage = userDataMap['username'] ??
            (userDataMap['email'] ?? 'pengguna').split('@').first;
        String avatarFromStorage = userDataMap['profile_picture'] ??
            'assets/images/default_avatar.png';

        userProfile.value = UserProfileModel(
          // Gunakan ?? untuk memberikan nilai default jika null
          name: nameFromStorage,
          email: userDataMap['email'] ?? 'Tidak ada email',
          username: usernameFromStorage,
          avatarAsset: avatarFromStorage,
          joinedDate: userDataMap['created_at'] != null
              ? _formatJoinedDate(userDataMap['created_at'])
              : 'N/A',
          gender: userDataMap['gender'], // Sekarang bisa di-pass
          occupation: userDataMap['occupation'], // Sekarang bisa di-pass
        );

        editUsernameController.text = userProfile.value?.name ??
            ''; // Ambil dari 'name' yang sudah di-resolve
        editOccupationController.text = userProfile.value?.occupation ?? '';
        editSelectedGender.value =
            userProfile.value?.gender ?? genderOptions.first;

        debugPrint(
            "Profil: User data loaded from storage: ${userProfile.value?.name}");
      } else {
        debugPrint("Profil: No user data in storage. Setting default profile.");
        userProfile.value = UserProfileModel(
            name: 'Pengguna Tamu',
            email: '',
            username: 'tamu',
            avatarAsset: 'assets/images/default_avatar.png',
            joinedDate: '',
            gender: null, // Atau default value
            occupation: null // Atau default value
            );
      }
    } catch (e) {
      debugPrint("Profil: Error loading user data from storage: $e");
      userProfile.value = UserProfileModel(
          name: 'Error Load',
          email: '',
          username: 'error',
          avatarAsset: 'assets/images/default_avatar.png',
          joinedDate: '',
          gender: null,
          occupation: null);
    }
  }

  String _formatJoinedDate(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString);
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return "N/A";
    }
  }

  String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    if (month < 1 || month > 12) return ''; // Handle invalid month
    return months[month - 1];
  }

  void _buildSettingsOptions() {
    // ... (kode _buildSettingsOptions tetap sama)
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
        SettingsItemModel(
            title: 'Statistik BPS',
            icon: LucideIcons.lineChart,
            action: 'show_bps_stats'),
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
  }

  Future<void> logout() async {
    // ... (kode logout tetap sama)
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _storage.deleteAll();
              Get.offAllNamed(Routes.LOGIN);
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

  void showEditProfileDialog() {
    // ... (kode showEditProfileDialog tetap sama)
    if (userProfile.value != null) {
      editUsernameController.text = userProfile.value!.name;
      editOccupationController.text = userProfile.value!.occupation ?? '';
      editSelectedGender.value =
          userProfile.value!.gender ?? genderOptions.first;
    }

    Get.defaultDialog(
      title: "Edit Profil",
      titleStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editUsernameController,
                  decoration: const InputDecoration(
                      labelText: 'Nama Pengguna', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: editOccupationController,
                  decoration: const InputDecoration(
                      labelText: 'Pekerjaan', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder()),
                      value: editSelectedGender.value,
                      items: genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          editSelectedGender.value = newValue;
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
      confirm: Obx(() => ElevatedButton(
            onPressed:
                isUpdatingProfile.value ? null : () => _updateProfileData(),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: isUpdatingProfile.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ))
                : const Text("Simpan", style: TextStyle(color: Colors.white)),
          )),
      cancel:
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
    );
  }

  Future<void> _updateProfileData() async {
    isUpdatingProfile.value = true;
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
          snackPosition: SnackPosition.BOTTOM);
      isUpdatingProfile.value = false;
      Get.back();
      return;
    }

    try {
      // Ambil nilai username baru dari controller, pastikan tidak kosong
      String newUsername = editUsernameController.text.trim();
      if (newUsername.isEmpty)
        newUsername = userProfile.value?.name ?? 'Pengguna';

      final response = await ApiService.updateUserProfile(
        token: token,
        username: newUsername, // Gunakan nilai yang sudah divalidasi/default
        occupation: editOccupationController.text.trim(),
        gender: editSelectedGender.value,
      );

      if (response['status'] == 'success' && response.containsKey('user')) {
        final updatedUserDataMap = response['user'] as Map<String, dynamic>;

        userProfile.update((profile) {
          if (profile != null) {
            // Pastikan profile tidak null sebelum update
            profile.name = updatedUserDataMap['username'] ?? profile.name;
            profile.username = updatedUserDataMap['username'] ??
                profile.username; // Backend mengembalikan 'username'
            profile.occupation =
                updatedUserDataMap['occupation'] ?? profile.occupation;
            profile.gender = updatedUserDataMap['gender'] ?? profile.gender;
            // Jika backend mengirim profile_picture, update juga avatarAsset
            if (updatedUserDataMap.containsKey('profile_picture') &&
                updatedUserDataMap['profile_picture'] != null) {
              profile.avatarAsset = updatedUserDataMap['profile_picture'];
            }
          }
        });

        final currentStoredDataString = await _storage.read(key: 'user_data');
        Map<String, dynamic> currentStoredData = {};
        if (currentStoredDataString != null) {
          currentStoredData = jsonDecode(currentStoredDataString);
        }
        currentStoredData.addAll(updatedUserDataMap);
        // Pastikan 'username' di storage juga terupdate jika backend mengembalikan 'username'
        if (updatedUserDataMap.containsKey('username')) {
          currentStoredData['username'] = updatedUserDataMap['username'];
        }
        // Jika 'name' adalah field terpisah dan ingin disamakan dengan username
        // currentStoredData['name'] = updatedUserDataMap['username'] ?? currentStoredData['name'];

        await _storage.write(
            key: 'user_data', value: jsonEncode(currentStoredData));

        Get.back();
        Get.snackbar('Sukses', 'Profil berhasil diperbarui!',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar(
            'Gagal', response['message'] ?? 'Gagal memperbarui profil.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      final String errorMessageText =
          (e is Map && e.containsKey('message')) ? e['message'] : e.toString();
      Get.snackbar('Error', 'Terjadi kesalahan: $errorMessageText',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  void toggleSetting(String action, bool value) {
    // ... (kode toggleSetting tetap sama)
    for (var section in settingsOptions) {
      for (var item in section.items) {
        if (item.action == action && item.isSwitch) {
          item.value = value;
          settingsOptions.refresh();
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
    // ... (kode handleSettingsTap tetap sama)
    switch (item.action) {
      case 'edit_profile':
        showEditProfileDialog();
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
      case 'show_bps_stats':
        Get.to(() => const StatisticView());
        break;
      default:
        if (!item.isSwitch) {
          Get.snackbar(
              item.title, 'Anda mengetuk ${item.title}. Fitur akan datang!',
              snackPosition: SnackPosition.BOTTOM);
        }
    }
  }

  Color parseColor(String hexColor) {
    // ... (kode parseColor tetap sama)
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return primaryColor;
    }
  }
}
