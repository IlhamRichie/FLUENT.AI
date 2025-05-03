import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:fluent_ai/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, size: 20),
            onPressed: controller.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader('Statistik Saya'),
            ),
            SliverToBoxAdapter(
              child: _buildStatsSection(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader('Pengaturan'),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: _buildSettingsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFFD84040).withOpacity(0.2),
              width: 1,
            ),
          ),
          color: const Color(0xFFD84040).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD84040).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFFD84040).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage(controller.userProfile['avatar']),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD84040),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.userProfile['email'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${controller.userProfile['username']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bergabung ${controller.userProfile['joinedDate']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD84040).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD84040).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.edit,
                    size: 18,
                    color: Color(0xFFD84040),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatsSection() {
    return Obx(() => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFFD84040).withOpacity(0.2),
              width: 1,
            ),
          ),
          color: const Color(0xFFD84040).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      value: controller.userStats['averageScore']
                          .toStringAsFixed(1),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD84040).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD84040).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFD84040),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFD84040),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, sectionIndex) {
              final section = controller.settingsOptions[sectionIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sectionIndex != 0) const SizedBox(height: 16),
                  ...List.generate(
                    section['items'].length,
                    (itemIndex) {
                      final item = section['items'][itemIndex];
                      final isLastItem = itemIndex == section['items'].length - 1;
                      return _buildSettingsItem(item, section['title'], isLastItem);
                    },
                  ),
                ],
              );
            },
            childCount: controller.settingsOptions.length,
          ),
        ));
  }

  Widget _buildSettingsItem(
      Map<String, dynamic> item, String sectionTitle, bool isLastItem) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFD84040).withOpacity(0.2),
          width: 1,
        ),
      ),
      color: const Color(0xFFD84040).withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD84040).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD84040).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            item['icon'],
            size: 20,
            color: const Color(0xFFD84040),
          ),
        ),
        title: Text(
          item['title'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _buildSettingsTrailing(item, sectionTitle),
        onTap: () => _handleSettingsTap(item['action']),
      ),
    );
  }

  Widget _buildSettingsTrailing(
      Map<String, dynamic> item, String sectionTitle) {
    if (sectionTitle == 'Preferensi' && item['value'] is bool) {
      return Switch(
        value: item['value'],
        activeColor: const Color(0xFFD84040),
        onChanged: (value) => controller.toggleSetting(item['action'], value),
      );
    } else if (item['value'] != null) {
      return Text(
        item['value'].toString(),
        style: const TextStyle(
          color: Color(0xFFD84040),
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return const Icon(
      LucideIcons.chevronRight,
      size: 20,
      color: Color(0xFFD84040),
    );
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