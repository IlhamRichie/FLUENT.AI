import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilController extends GetxController {
  // User data
  final RxMap<String, dynamic> userProfile = {
    'name': 'Ilham Rigan',
    'email': 'ilhamrigan22@gmail.com',
    'username': 'rigan22',
    'avatar': 'assets/images/avatar.png',
    'joinedDate': '15 Maret 2025',
    'language': 'Bahasa Indonesia',
    'notificationEnabled': true,
    'darkMode': false,
    'tokens': 15,
  }.obs;

  // Stats
  final RxMap<String, dynamic> userStats = {
    'totalSessions': 24,
    'consecutiveDays': 7,
    'averageScore': 78.5,
    'highestScore': 92,
  }.obs;

  // Settings options
  final RxList<Map<String, dynamic>> settingsOptions = [
    {
      'title': 'Akun',
      'icon': LucideIcons.user,
      'items': [
        {
          'title': 'Edit Profil',
          'icon': LucideIcons.edit,
          'action': 'edit_profile',
        },
        {
          'title': 'Ubah Password',
          'icon': LucideIcons.lock,
          'action': 'change_password',
        },
      ],
    },
    {
      'title': 'Preferensi',
      'icon': LucideIcons.settings,
      'items': [
        {
          'title': 'Bahasa',
          'icon': LucideIcons.languages,
          'value': 'Bahasa Indonesia',
          'action': 'change_language',
        },
        {
          'title': 'Notifikasi',
          'icon': LucideIcons.bell,
          'value': true,
          'action': 'toggle_notifications',
        },
        {
          'title': 'Tema Gelap',
          'icon': LucideIcons.moon,
          'value': false,
          'action': 'toggle_dark_mode',
        },
      ],
    },
    {
      'title': 'Bantuan',
      'icon': LucideIcons.helpCircle,
      'items': [
        {
          'title': 'Panduan Penggunaan',
          'icon': LucideIcons.bookOpen,
          'action': 'show_guide',
        },
        {
          'title': 'Hubungi Kami',
          'icon': LucideIcons.mail,
          'action': 'contact_us',
        },
        {
          'title': 'Ketentuan Layanan',
          'icon': LucideIcons.fileText,
          'action': 'show_terms',
        },
      ],
    },
  ].obs;

  // Edit profile
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with current values
    nameController.text = userProfile['name'];
    emailController.text = userProfile['email'];
    usernameController.text = userProfile['username'];
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.onClose();
  }

  // Update profile
  void updateProfile() {
    userProfile['name'] = nameController.text;
    userProfile['email'] = emailController.text;
    userProfile['username'] = usernameController.text;
    Get.back();
    Get.snackbar('Berhasil', 'Profil diperbarui');
  }

  // Toggle settings
  void toggleSetting(String action, bool value) {
    switch (action) {
      case 'toggle_notifications':
        userProfile['notificationEnabled'] = value;
        break;
      case 'toggle_dark_mode':
        userProfile['darkMode'] = value;
        Get.changeThemeMode(
          value ? ThemeMode.dark : ThemeMode.light,
        );
        break;
    }
  }

  // Logout
  void logout() {
    Get.offAllNamed('/login');
    Get.snackbar('Sampai jumpa!', 'Anda telah logout');
  }

  // Show edit dialog
  void showEditDialog() {
    Get.defaultDialog(
      title: 'Edit Profil',
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: updateProfile,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}