import 'package:fluent_ai/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: controller.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(controller.userProfile['avatar']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userProfile['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(controller.userProfile['email']),
                  Text(
                    '@${controller.userProfile['username']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Bergabung ${controller.userProfile['joinedDate']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit, size: 20),
              onPressed: controller.showEditDialog,
              tooltip: 'Edit Profil',
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatsSection() {
    return Obx(() => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: controller.userStats['totalSessions'].toString(),
                  label: 'Sesi',
                  icon: LucideIcons.activity,
                ),
                _buildStatItem(
                  value: controller.userStats['consecutiveDays'].toString(),
                  label: 'Hari Berturut',
                  icon: LucideIcons.flame,
                ),
                _buildStatItem(
                  value: controller.userStats['averageScore'].toStringAsFixed(1),
                  label: 'Rata-rata',
                  icon: LucideIcons.star,
                ),
                _buildStatItem(
                  value: controller.userStats['highestScore'].toString(),
                  label: 'Tertinggi',
                  icon: LucideIcons.trophy,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Obx(() => Column(
      children: controller.settingsOptions.map((section) => 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                section['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: section['items'].map<Widget>((item) => 
                  _buildSettingsItem(item, section['title']),
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ).toList(),
    ));
  }

  Widget _buildSettingsItem(Map<String, dynamic> item, String sectionTitle) {
    return ListTile(
      leading: Icon(item['icon']),
      title: Text(item['title']),
      trailing: _buildSettingsTrailing(item, sectionTitle),
      onTap: () => _handleSettingsTap(item['action']),
    );
  }

  Widget _buildSettingsTrailing(Map<String, dynamic> item, String sectionTitle) {
    if (sectionTitle == 'Preferensi' && item['value'] is bool) {
      return Switch(
        value: item['value'],
        onChanged: (value) => controller.toggleSetting(item['action'], value),
      );
    } else if (item['value'] != null) {
      return Text(
        item['value'].toString(),
        style: TextStyle(color: Colors.grey[600]),
      );
    }
    return const Icon(LucideIcons.chevronRight, size: 20);
  }

  void _handleSettingsTap(String action) {
    switch (action) {
      case 'edit_profile':
        controller.showEditDialog();
        break;
      case 'change_password':
        Get.snackbar('Ubah Password', 'Fitur akan datang segera!');
        break;
      case 'change_language':
        Get.snackbar('Ubah Bahasa', 'Fitur akan datang segera!');
        break;
      case 'show_guide':
        case 'contact_us':
        case 'show_terms':
          break;
      default:
        Get.snackbar('Aksi', 'Fitur akan datang segera!');
    }
  }
}