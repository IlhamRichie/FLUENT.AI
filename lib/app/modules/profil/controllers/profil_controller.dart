// lib/app/modules/profil/controllers/profil_controller.dart
import 'dart:io'; // Untuk File (image_picker)
import 'package:fluent_ai/app/modules/profil/models/activity_log_model.dart';
import 'package:fluent_ai/app/modules/profil/models/profil_model.dart';
import 'package:fluent_ai/app/modules/profil/models/session_model.dart';
import 'package:fluent_ai/app/modules/profil/models/setting_model.dart';
import 'package:fluent_ai/app/modules/profil/models/stats_model.dart';
import 'package:fluent_ai/app/modules/profil/views/statistik_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart'; // Untuk ambil gambar
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:intl/intl.dart'; // Untuk formatting tanggal yang lebih baik

class ProfilController extends GetxController {
  final isLoading = true.obs;
  final isUpdatingProfile = false.obs;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker

  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<UserStatsModel?> userStats = Rx<UserStatsModel?>(null);
  final RxList<SettingsSectionModel> settingsOptions =
      <SettingsSectionModel>[].obs;

  final RxList<ActiveSessionModel> activeSessions = <ActiveSessionModel>[].obs;
  final RxList<ActivityLogModel> activityLogs = <ActivityLogModel>[].obs;
  final isLoadingSessions = false.obs;
  final isLoadingLogs = false.obs;

  final Color primaryColor = const Color(0xFFD84040);

  late TextEditingController editUsernameController; // Akan diisi dengan username sistem
  late TextEditingController editNameController; // Untuk nama tampilan
  late TextEditingController editOccupationController;
  final RxString editSelectedGender = 'Pria'.obs;
  final List<String> genderOptions = ['Pria', 'Wanita', 'Lainnya', 'Tidak ingin menyebutkan']; // Tambahkan opsi

  @override
  void onInit() {
    super.onInit();
    editUsernameController = TextEditingController();
    editNameController = TextEditingController();
    editOccupationController = TextEditingController();
    fetchProfileData();
  }

  @override
  void onClose() {
    editUsernameController.dispose();
    editNameController.dispose();
    editOccupationController.dispose();
    super.onClose();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    await _loadUserProfileFromStorage(); // Fungsi ini akan mengisi userProfile.value

    // Data dummy statistik, ganti dengan fetch API jika ada
    userStats.value = UserStatsModel(
      totalSessions: 128,
      consecutiveDays: 21,
      averageScore: 88.5,
      highestScore: 97,
    );
    _buildSettingsOptions();
    isLoading.value = false;
  }

  Future<void> _loadUserProfileFromStorage() async {
    try {
      final storedUserData = await _storage.read(key: 'user_data');
      if (storedUserData != null) {
        final userDataMap = jsonDecode(storedUserData) as Map<String, dynamic>;

        // Debug: Cetak semua data yang ada di storage
        debugPrint("Profil: Raw user_data from storage: $userDataMap");

        // Penanganan Nama dan Username:
        // 'name' bisa jadi nama lengkap dari Google, 'username' adalah username sistem.
        // Jika login biasa, 'name' mungkin awalnya sama dengan 'username'.
        String nameFromStorage = userDataMap['full_name'] ?? userDataMap['name'] ?? userDataMap['username'] ?? 'Pengguna';
        String usernameFromStorage = userDataMap['username'] ?? (userDataMap['email'] ?? 'pengguna').split('@').first;
        
        // Penanganan Avatar:
        // 'profile_picture' dari Google adalah URL. Jika login biasa, mungkin null atau path lokal (jika sudah diimplementasikan).
        String? avatarValue = userDataMap['profile_picture'];
        String defaultAvatar = 'assets/images/default_avatar.png'; // Path default avatar Anda

        // Penanganan Tanggal Bergabung:
        // Pastikan 'created_at' adalah string ISO 8601 yang valid dari backend.
        String joinedDateString = 'N/A';
        if (userDataMap['created_at'] != null && userDataMap['created_at'] is String) {
          joinedDateString = _formatJoinedDate(userDataMap['created_at']);
        } else {
          debugPrint("Profil: 'created_at' is null or not a string. Value: ${userDataMap['created_at']}");
        }

        String? authProvider = userDataMap['auth_provider']; // 'google' atau 'local'

        userProfile.value = UserProfileModel(
          name: nameFromStorage, // Nama tampilan
          email: userDataMap['email'] ?? 'Tidak ada email',
          username: usernameFromStorage, // Username sistem
          avatarUrlOrPath: avatarValue ?? defaultAvatar,
          joinedDate: joinedDateString,
          gender: userDataMap['gender'],
          occupation: userDataMap['occupation'],
          authProvider: authProvider,
        );

        // Set nilai untuk form edit
        editNameController.text = userProfile.value?.name ?? '';
        editUsernameController.text = userProfile.value?.username ?? ''; // Username sistem
        editOccupationController.text = userProfile.value?.occupation ?? '';
        editSelectedGender.value = userProfile.value?.gender ?? genderOptions.firstWhere((g) => g == 'Tidak ingin menyebutkan', orElse: () => genderOptions.first);


        debugPrint("Profil: User data loaded: Name: ${userProfile.value?.name}, Username: ${userProfile.value?.username}, Avatar: ${userProfile.value?.avatarUrlOrPath}, Joined: ${userProfile.value?.joinedDate}, AuthProvider: ${userProfile.value?.authProvider}");
      } else {
        debugPrint("Profil: No user data in storage. Setting default profile.");
        // Default jika tidak ada data sama sekali
        userProfile.value = UserProfileModel(
            name: 'Pengguna Tamu',
            email: '',
            username: 'tamu',
            avatarUrlOrPath: 'assets/images/default_avatar.png',
            joinedDate: 'N/A',
            authProvider: 'local' // Asumsi default
            );
      }
    } catch (e) {
      debugPrint("Profil: Error loading user data from storage: $e");
      userProfile.value = UserProfileModel(
          name: 'Error Load',
          email: '',
          username: 'error',
          avatarUrlOrPath: 'assets/images/default_avatar.png',
          joinedDate: 'N/A',
          authProvider: 'local'
          );
    }
  }

  String _formatJoinedDate(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString).toLocal(); // Konversi ke waktu lokal
      // Gunakan intl package untuk formatting yang lebih baik dan lokalisasi jika perlu
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime); // Format: 31 Mei 2025
    } catch (e) {
      debugPrint("Profil: Error parsing joined date '$isoDateString': $e");
      return "N/A";
    }
  }

  // Fungsi _getMonthName tidak lagi diperlukan jika menggunakan intl DateFormat

  void _buildSettingsOptions() {
    // ... (kode _buildSettingsOptions tetap sama) ...
    // Sesuaikan jika perlu, misal tombol 'Ubah Avatar'
     List<SettingsItemModel> accountItems = [
      SettingsItemModel(
          title: 'Edit Detail Profil', icon: LucideIcons.userCog, action: 'edit_profile_details'),
      SettingsItemModel(
          title: 'Ubah Password', icon: LucideIcons.keyRound, action: 'change_password'),
      SettingsItemModel(
          title: 'Manajemen Perangkat & Sesi',icon: LucideIcons.smartphone,action: 'manage_devices'),
      SettingsItemModel(
          title: 'Log Aktivitas',icon: LucideIcons.history,action: 'show_activity_log'),
    ];

    // Tambahkan opsi ubah avatar jika bukan login Google (atau jika Anda ingin Google user juga bisa override)
    // Untuk saat ini, kita asumsikan hanya pengguna 'local' yang bisa ubah avatar via upload
    if (userProfile.value?.authProvider == 'local') {
      accountItems.insert(1, SettingsItemModel( // Sisipkan setelah edit detail
          title: 'Ubah Foto Profil', icon: LucideIcons.image, action: 'change_avatar'));
    }

    // Tambahkan daftar item keamanan & aktivitas
    List<SettingsItemModel> securityItems = [
      SettingsItemModel(
          title: 'Autentikasi Dua Faktor', icon: LucideIcons.shieldCheck, action: 'toggle_2fa', value: false, isSwitch: true),
      SettingsItemModel(
          title: 'Riwayat Login', icon: LucideIcons.clock, action: 'show_login_history'),
    ];

    settingsOptions.assignAll([
      SettingsSectionModel(title: 'Akun', items: accountItems),
      SettingsSectionModel(title: 'Keamanan & Aktivitas', items: securityItems),
      SettingsSectionModel(title: 'Preferensi & Statistik', items: [
         SettingsItemModel(
          title: 'Preferensi Bahasa', icon: LucideIcons.languages, action: 'change_language', value: 'Indonesia'),
        SettingsItemModel(
          title: 'Statistik Belajar', icon: LucideIcons.lineChart, action: 'show_learning_stats'), // Ganti nama jika perlu
      ]),
      // ... (Sisa section notifikasi dan bantuan tetap sama) ...
       SettingsSectionModel(title: 'Notifikasi', items: [
        SettingsItemModel(
            title: 'Notifikasi Umum', icon: LucideIcons.bellRing, action: 'toggle_general_notif', value: true, isSwitch: true),
        SettingsItemModel(
            title: 'Notifikasi Latihan', icon: LucideIcons.dumbbell, action: 'toggle_practice_notif', value: false, isSwitch: true),
      ]),
      SettingsSectionModel(title: 'Bantuan & Info', items: [
        SettingsItemModel(
            title: 'Panduan Pengguna', icon: LucideIcons.bookOpen, action: 'show_guide'),
        SettingsItemModel(
            title: 'Hubungi Kami', icon: LucideIcons.mailQuestion, action: 'contact_us'),
        SettingsItemModel(
            title: 'Syarat & Ketentuan', icon: LucideIcons.fileText, action: 'show_terms'),
        SettingsItemModel(
            title: 'Tentang Aplikasi', icon: LucideIcons.info, action: 'show_about', value: 'Versi 1.0.0'),
      ]),
    ]);
  }

  Future<void> logout() async {
    // ... (kode logout tetap sama) ...
     Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog dulu
              // Hapus data Google Sign-In jika login dengan Google
              if (userProfile.value?.authProvider == 'google') {
                try {
                  final GoogleSignIn _googleSignIn = GoogleSignIn();
                  await _googleSignIn.signOut();
                  debugPrint("Profil: Google Sign Out berhasil saat logout.");
                } catch (e) {
                  debugPrint("Profil: Error saat Google Sign Out: $e");
                }
              }
              await _storage.deleteAll(); // Hapus semua data dari secure storage
              Get.offAllNamed(Routes.LOGIN); // Arahkan ke halaman login
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
    if (userProfile.value != null) {
      editNameController.text = userProfile.value!.name;
      editUsernameController.text = userProfile.value!.username; // Username untuk field username
      editOccupationController.text = userProfile.value!.occupation ?? '';
      editSelectedGender.value = userProfile.value!.gender ?? genderOptions.firstWhere((g) => g == 'Tidak ingin menyebutkan', orElse: () => genderOptions.first);
    }

    Get.defaultDialog(
      title: "Edit Detail Profil",
      titleStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editNameController, // Controller untuk Nama Tampilan
                  decoration: const InputDecoration(
                      labelText: 'Nama Tampilan', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: editUsernameController, // Controller untuk Username Sistem
                  decoration: const InputDecoration(
                      labelText: 'Username (unik)', border: OutlineInputBorder()),
                  // Mungkin ingin menambahkan validasi unik atau readonly jika tidak boleh diubah
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
                isUpdatingProfile.value ? null : () => _updateProfileDetails(),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: isUpdatingProfile.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text("Simpan", style: TextStyle(color: Colors.white)),
          )),
      cancel:
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
    );
  }

  Future<void> _updateProfileDetails() async { // Ganti nama fungsi dari _updateProfileData
    isUpdatingProfile.value = true;
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
          snackPosition: SnackPosition.BOTTOM);
      isUpdatingProfile.value = false;
      Get.back(); // Tutup dialog edit
      return;
    }

    try {
      String newName = editNameController.text.trim();
      String newUsername = editUsernameController.text.trim();
      if (newName.isEmpty) newName = userProfile.value?.name ?? 'Pengguna';
      if (newUsername.isEmpty) newUsername = userProfile.value?.username ?? 'pengguna';


      final response = await ApiService.updateUserProfile(
        token: token,
        // Kirim 'name' dan 'username' jika backend bisa memproses keduanya.
        // Atau pilih salah satu jika backend hanya punya satu field nama.
        // Untuk contoh ini, kita asumsikan backend bisa update 'username' (sebagai nama tampilan utama)
        username: newUsername, // Ini akan menjadi nama tampilan utama jika backend hanya punya 'username'
                                // Jika backend punya 'name' dan 'username' terpisah, kirim keduanya
        // name: newName, // Jika backend punya field 'name' terpisah
        occupation: editOccupationController.text.trim(),
        gender: editSelectedGender.value,
      );

      if (response['status'] == 'success' && response.containsKey('user')) {
        final updatedUserDataMap = response['user'] as Map<String, dynamic>;

        userProfile.update((profile) {
          if (profile != null) {
            // Update name dan username di model lokal
            profile.name = updatedUserDataMap['full_name'] ?? updatedUserDataMap['name'] ?? updatedUserDataMap['username'] ?? profile.name;
            profile.username = updatedUserDataMap['username'] ?? profile.username;
            profile.occupation = updatedUserDataMap['occupation'] ?? profile.occupation;
            profile.gender = updatedUserDataMap['gender'] ?? profile.gender;
            if (updatedUserDataMap.containsKey('profile_picture') && updatedUserDataMap['profile_picture'] != null) {
              profile.avatarUrlOrPath = updatedUserDataMap['profile_picture'];
            }
          }
        });

        // Update data di storage
        final currentStoredDataString = await _storage.read(key: 'user_data');
        Map<String, dynamic> currentStoredData = {};
        if (currentStoredDataString != null) {
          currentStoredData = jsonDecode(currentStoredDataString);
        }
        // Gabungkan data lama dengan data baru dari respons 'user'
        currentStoredData.addAll(updatedUserDataMap); 
        // Pastikan semua field yang relevan terupdate di storage
        currentStoredData['name'] = userProfile.value?.name; // Ambil dari model yang sudah diupdate
        currentStoredData['username'] = userProfile.value?.username;
        currentStoredData['occupation'] = userProfile.value?.occupation;
        currentStoredData['gender'] = userProfile.value?.gender;
        currentStoredData['profile_picture'] = userProfile.value?.avatarUrlOrPath;


        await _storage.write(key: 'user_data', value: jsonEncode(currentStoredData));

        Get.back(); // Tutup dialog edit
        Get.snackbar('Sukses', 'Profil berhasil diperbarui!',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Gagal', response['message'] ?? 'Gagal memperbarui profil.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      final String errorMessageText = (e is Map && e.containsKey('message')) ? e['message'] : e.toString();
      Get.snackbar('Error', 'Terjadi kesalahan: $errorMessageText',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // Fungsi untuk memilih dan mengupload avatar (placeholder)
  Future<void> pickAndUploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // Pengguna membatalkan

      File imageFile = File(image.path);
      isUpdatingProfile.value = true; // Atau loading state khusus avatar

      // TODO: Implementasi ApiService.uploadAvatar(imageFile)
      // Ini akan mengirim gambar ke backend Anda. Backend harus:
      // 1. Menerima file gambar (multipart/form-data).
      // 2. Menyimpan gambar (misal, ke folder static atau cloud storage).
      // 3. Mengembalikan URL publik dari gambar yang baru diupload.
      // 4. Mengupdate field 'profile_picture' user di database dengan URL baru.

      // --- Contoh Panggilan ke ApiService (Anda perlu membuat fungsi ini di ApiService) ---
      // final token = await _storage.read(key: 'access_token');
      // if (token == null) { /* handle error */ return; }
      //
      // final uploadResponse = await ApiService.uploadUserAvatar(token: token, imageFile: imageFile);
      //
      // if (uploadResponse['status'] == 'success' && uploadResponse.containsKey('user')) {
      //   final updatedUserDataMap = uploadResponse['user'] as Map<String, dynamic>;
      //
      //   // Update userProfile dan storage dengan data baru (termasuk avatarUrlOrPath baru)
      //   userProfile.update((profile) {
      //     if (profile != null) {
      //       profile.avatarUrlOrPath = updatedUserDataMap['profile_picture'] ?? profile.avatarUrlOrPath;
      //       // Update field lain jika backend mengirimnya
      //     }
      //   });
      //   // Update juga di _storage
      //   final currentStoredDataString = await _storage.read(key: 'user_data');
      //   Map<String, dynamic> currentStoredData = {};
      //   if (currentStoredDataString != null) currentStoredData = jsonDecode(currentStoredDataString);
      //   currentStoredData.addAll(updatedUserDataMap);
      //   await _storage.write(key: 'user_data', value: jsonEncode(currentStoredData));
      //
      //   Get.snackbar('Sukses', 'Foto profil berhasil diperbarui!', snackPosition: SnackPosition.BOTTOM);
      // } else {
      //   Get.snackbar('Gagal', uploadResponse['message'] ?? 'Gagal mengupload foto profil.', snackPosition: SnackPosition.BOTTOM);
      // }
      // --- Akhir Contoh Panggilan ---

      // Untuk sekarang, kita hanya simulasi update lokal (ganti dengan logika upload sebenarnya)
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network
      userProfile.update((profile) {
        if (profile != null) {
          profile.avatarUrlOrPath = imageFile.path; // Ini akan jadi path lokal, bukan URL.
                                                  // Seharusnya ini diisi dengan URL dari backend setelah upload.
        }
      });
      Get.snackbar('Placeholder', 'Fitur upload avatar belum terhubung ke backend.', snackPosition: SnackPosition.BOTTOM);


    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdatingProfile.value = false;
    }
  }


  void toggleSetting(String action, bool value) {
    // ... (kode toggleSetting tetap sama) ...
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
    // ... (kode handleSettingsTap tetap sama, tambahkan case 'change_avatar') ...
    switch (item.action) {
      case 'edit_profile_details': // Ganti nama action
        showEditProfileDialog();
        break;
      case 'change_avatar':
        pickAndUploadAvatar(); // Panggil fungsi baru
        break;
      case 'change_password':
        Get.snackbar('Ubah Password', 'Fitur ini akan segera hadir!',
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 'change_language':
        Get.snackbar('Ubah Bahasa', 'Saat ini hanya mendukung Bahasa Indonesia.',
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 'show_learning_stats': // Ganti nama action jika perlu
        Get.to(() => const StatisticView());
        break;
      case 'manage_devices':
        // Navigasi ke halaman baru yang akan kita buat
        Get.toNamed(Routes.DEVICE_MANAGEMENT);
        break;
      case 'show_activity_log':
        // Navigasi ke halaman baru yang akan kita buat
        Get.toNamed(Routes.ACTIVITY_LOG);
        break;
      default:
        if (!item.isSwitch) {
          Get.snackbar(item.title, 'Anda mengetuk ${item.title}. Fitur akan datang!',
              snackPosition: SnackPosition.BOTTOM);
        }
    }
  }

  Color parseColor(String hexColor) {
    // ... (kode parseColor tetap sama) ...
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor"; // Pastikan Alpha ada
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      debugPrint("Error parsing color: $hexColor, $e");
      return primaryColor; // Default color on error
    }
  }
}