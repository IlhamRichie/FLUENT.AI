import 'package:fluent_ai/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Lighter background for contrast
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.black),
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
            side: BorderSide(
              color: Colors.blue[100]!,
              width: 1.5,
            ),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue[100]!,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage(controller.userProfile['avatar']),
                  ),
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
                      Text(
                        controller.userProfile['email'],
                        style: TextStyle(color: Colors.grey[700]),
                      ),
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
                  icon: const Icon(LucideIcons.edit,
                      size: 20, color: Colors.blue),
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
            side: BorderSide(
              color: Colors.blue[100]!,
              width: 1.5,
            ),
          ),
          color: Colors.white,
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
                      color: Colors.blue,
                    ),
                    _buildStatItem(
                      value: controller.userStats['consecutiveDays'].toString(),
                      label: 'Hari Berturut',
                      icon: LucideIcons.flame,
                      color: Colors.orange,
                    ),
                    _buildStatItem(
                      value: controller.userStats['averageScore']
                          .toStringAsFixed(1),
                      label: 'Rata-rata',
                      icon: LucideIcons.star,
                      color: Colors.purple,
                    ),
                    _buildStatItem(
                      value: controller.userStats['highestScore'].toString(),
                      label: 'Tertinggi',
                      icon: LucideIcons.trophy,
                      color: Colors.green,
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
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
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

  Widget _buildSettingsItem(
      Map<String, dynamic> item, String sectionTitle, bool isLastItem) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(item['icon'], size: 20, color: Colors.blue),
          ),
          title: Text(item['title']),
          trailing: _buildSettingsTrailing(item, sectionTitle),
          onTap: () => _handleSettingsTap(item['action']),
        ),
        if (!isLastItem) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Obx(() => Column(
          children: controller.settingsOptions
              .map(
                (section) => Column(
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
                        side: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      color: Colors.white,
                      child: Column(
                        children:
                            List.generate(section['items'].length, (index) {
                          final item = section['items'][index];
                          final isLastItem =
                              index == section['items'].length - 1;
                          return _buildSettingsItem(
                              item, section['title'], isLastItem);
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              )
              .toList(),
        ));
  }

  Widget _buildSettingsTrailing(
      Map<String, dynamic> item, String sectionTitle) {
    if (sectionTitle == 'Preferensi' && item['value'] is bool) {
      return Switch(
        value: item['value'],
        activeColor: Colors.blue,
        onChanged: (value) => controller.toggleSetting(item['action'], value),
      );
    } else if (item['value'] != null) {
      return Text(
        item['value'].toString(),
        style: TextStyle(color: Colors.grey[600]),
      );
    }
    return const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey);
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
