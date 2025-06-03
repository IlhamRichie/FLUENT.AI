// lib/app/modules/profil/views/profil_view.dart
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:fluent_ai/app/modules/profil/controllers/profil_controller.dart';
import 'package:fluent_ai/app/modules/profil/models/profil_model.dart'; // Pastikan model diimport
import 'package:fluent_ai/app/modules/profil/models/setting_model.dart';
import 'package:fluent_ai/app/modules/profil/models/stats_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors
          .white, // Atau theme.colorScheme.background jika menggunakan Material 3
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Sedikit shadow agar tidak terlalu flat
        automaticallyImplyLeading: false,
        title: Text('Profil Saya',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey[850])),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.logOut, size: 22, color: Colors.red[600]),
            onPressed: controller.logout,
            tooltip: 'Logout Akun',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        // Kondisi loading awal, saat data profil belum ada sama sekali
        if (controller.isLoading.value &&
            controller.userProfile.value == null) {
          return _buildShimmerPage(theme);
        }

        // Kondisi jika data profil gagal dimuat (setelah loading selesai tapi profile tetap null)
        if (controller.userProfile.value == null &&
            !controller.isLoading.value) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.serverOff, size: 56, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text("Oops! Gagal memuat data profil.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text("Silakan periksa koneksi internet Anda dan coba lagi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text("Coba Lagi Memuat"),
                  onPressed: controller.fetchProfileData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: controller.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                )
              ],
            ),
          ));
        }

        // Jika userProfile.value ada, kita bisa build UI utama
        // (Meskipun isLoading mungkin masih true jika sedang refresh, UI lama tetap tampil)
        final UserProfileModel? profile = controller.userProfile.value;
        final UserStatsModel? stats = controller.userStats.value;

        return RefreshIndicator(
          onRefresh: controller.fetchProfileData,
          color: controller.primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              if (profile != null)
                SliverToBoxAdapter(
                    child: _buildProfileHeader(theme,
                        profile)), // Kirim profile yang sudah dicheck non-null

              if (stats != null) ...[
                SliverToBoxAdapter(
                    child: _buildSectionHeader('Statistik Performa',
                        LucideIcons.barChartBig, controller.primaryColor)),
                SliverToBoxAdapter(
                    child: _buildStatsSection(theme,
                        stats)), // Kirim stats yang sudah dicheck non-null
              ],

              ...controller.settingsOptions.expand((section) {
                final items = section.items;
                return [
                  SliverToBoxAdapter(
                      child: _buildSectionHeader(
                          section.title,
                          _getSectionIcon(section.title),
                          controller.primaryColor)),
                  if (items.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildSettingsItem(items[index], theme);
                        },
                        childCount: items.length,
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text("Tidak ada item untuk ${section.title}.",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic)),
                      ),
                    ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 10)), // Jarak antar section
                ];
              }).toList(),
              const SliverToBoxAdapter(
                  child: SizedBox(
                      height: 80)), // Padding bawah agar tidak tertutup navbar
            ],
          ),
        );
      }),
      bottomNavigationBar:
          const NavbarView(), // Pastikan NavbarView tidak bergantung pada UserService
    );
  }

  IconData _getSectionIcon(String sectionTitle) {
    switch (sectionTitle.toLowerCase()) {
      case 'akun':
        return LucideIcons.userCircle2;
      case 'preferensi & statistik': // Sesuaikan dengan title di controller
        return LucideIcons.slidersHorizontal;
      case 'notifikasi':
        return LucideIcons.bellDot;
      case 'bantuan & info':
        return LucideIcons.helpCircle;
      default:
        return LucideIcons.settings2;
    }
  }

  Widget _buildShimmerPage(ThemeData theme) {
    // ... (kode _buildShimmerPage tetap sama dari sebelumnya) ...
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(
                        height: 15,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 6),
                    Container(
                        height: 15,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6))),
                  ]))
            ]),
            const SizedBox(height: 30),
            Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 30),
            Container(
                height: 20,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 12),
            Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 10),
            Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 24),
            Container(
                height: 20,
                width: 180,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 12),
            Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    // ... (kode _buildSectionHeader tetap sama dari sebelumnya) ...
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, UserProfileModel profile) {
    // Tentukan apakah menggunakan avatar network atau asset
    ImageProvider? avatarImageProvider;
    bool displayInitials = true;

    if (profile.avatarUrlOrPath != null &&
        profile.avatarUrlOrPath!.isNotEmpty) {
      if (profile.isNetworkAvatar) {
        // Gunakan helper dari model
        avatarImageProvider = NetworkImage(profile.avatarUrlOrPath!);
        displayInitials =
            false; // Jika ada network image, jangan tampilkan inisial awalnya
      } else if (profile.avatarUrlOrPath !=
              'assets/images/default_avatar.png' &&
          profile.avatarUrlOrPath !=
              'assets/images/profil.png' /* path default lain jika ada */) {
        // Ini adalah path aset lokal kustom (jika diimplementasikan)
        avatarImageProvider = AssetImage(profile.avatarUrlOrPath!);
        displayInitials = false;
      }
      // Jika avatarUrlOrPath adalah path default_avatar.png, maka displayInitials akan tetap true
      // dan avatarImageProvider akan null (atau bisa di-set ke AssetImage(default_avatar_path))
    }

    // Jika avatarImageProvider masih null setelah pengecekan di atas (misalnya, URL kosong atau hanya path default),
    // maka kita akan menampilkan inisial.
    if (avatarImageProvider == null) {
      displayInitials = true;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 3,
        shadowColor: controller.primaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  // Arahkan ke fungsi ganti avatar di controller jika loginnya bukan google
                  if (profile.authProvider == 'local') {
                    controller.pickAndUploadAvatar();
                  } else {
                    Get.snackbar(
                        "Info", "Foto profil diambil dari akun Google Anda.",
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                          controller.primaryColor.withOpacity(0.15),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage:
                            avatarImageProvider, // Gunakan ImageProvider yang sudah ditentukan
                        onBackgroundImageError:
                            (avatarImageProvider is NetworkImage ||
                                    avatarImageProvider
                                        is AssetImage) // Hanya jika bukan null
                                ? (exception, stackTrace) {
                                    debugPrint(
                                        "Error loading avatar: $exception. Path/URL: ${profile.avatarUrlOrPath}");
                                    // Jika error load, controller bisa dipanggil untuk set displayInitials jadi true
                                    // atau state lain untuk menampilkan inisial/default.
                                    // Untuk sekarang, biarkan child yang menangani (jika avatarImageProvider jadi null)
                                  }
                                : null,
                        child: (displayInitials ||
                                avatarImageProvider ==
                                    null) // Tampilkan inisial jika diperlukan
                            ? Text(
                                profile.name.isNotEmpty
                                    ? profile.name[0].toUpperCase()
                                    : (profile.username.isNotEmpty
                                        ? profile.username[0].toUpperCase()
                                        : 'U'),
                                style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors
                                        .white, // Warna inisial, mungkin perlu disesuaikan jika bg berbeda
                                    fontWeight: FontWeight.bold))
                            : null, // Tidak ada child jika gambar berhasil dimuat
                      ),
                    ),
                    if (profile.authProvider ==
                        'local') // Tampilkan ikon kamera hanya untuk login lokal
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: controller.primaryColor,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                        child: const Icon(LucideIcons.camera,
                            size: 14, color: Colors.white),
                      )
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, // Nama Tampilan
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[850])),
                    const SizedBox(height: 4),
                    Text(profile.email,
                        style:
                            TextStyle(fontSize: 13.5, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text('@${profile.username}', // Username sistem
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic)),
                    const SizedBox(height: 6),
                    if (profile.joinedDate.isNotEmpty &&
                        profile.joinedDate != "N/A")
                      Row(
                        children: [
                          Icon(LucideIcons.calendarPlus,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 5),
                          Text('Bergabung: ${profile.joinedDate}',
                              style: TextStyle(
                                  fontSize: 11.5, color: Colors.grey[500])),
                        ],
                      )
                  ],
                ),
              ),
              InkWell(
                onTap: controller.showEditProfileDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: controller.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(LucideIcons.edit3,
                      size: 20, color: controller.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, UserStatsModel stats) {
    // ... (kode _buildStatsSection tetap sama dari sebelumnya) ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  icon: LucideIcons.swords,
                  value: '${stats.totalSessions}',
                  label: 'Sesi Latihan',
                  color: Colors.blue.shade600),
              _buildStatItem(
                  icon: LucideIcons.flame,
                  value: '${stats.consecutiveDays}',
                  label: 'Streak Harian',
                  color: Colors.orange.shade600),
              _buildStatItem(
                  icon: LucideIcons.star,
                  value: stats.averageScore.toStringAsFixed(1),
                  label: 'Rata-rata Skor',
                  color: Colors.amber.shade700),
              _buildStatItem(
                  icon: LucideIcons.trophy,
                  value: '${stats.highestScore}',
                  label: 'Skor Tertinggi',
                  color: Colors.green.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon,
      required String value,
      required String label,
      required Color color}) {
    // ... (kode _buildStatItem tetap sama dari sebelumnya) ...
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800])),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey[600], height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(SettingsItemModel item, ThemeData theme) {
    // ... (kode _buildSettingsItem tetap sama dari sebelumnya) ...
    // Seharusnya sudah reaktif karena Obx utama di build()
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Card(
        elevation: 1,
        shadowColor: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: controller.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 20, color: controller.primaryColor),
          ),
          title: Text(item.title,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[750])),
          trailing: item.isSwitch
              ? Switch(
                  value: (item.value is bool ? item.value : false) as bool,
                  activeColor: controller.primaryColor,
                  onChanged: (val) =>
                      controller.toggleSetting(item.action, val),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              : (item.value != null && item.value is String
                  ? Text(item.value as String,
                      style: TextStyle(
                          color: controller.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13))
                  : Icon(LucideIcons.chevronRight,
                      size: 20, color: Colors.grey[400])),
          onTap:
              item.isSwitch ? null : () => controller.handleSettingsTap(item),
        ),
      ),
    );
  }
}
