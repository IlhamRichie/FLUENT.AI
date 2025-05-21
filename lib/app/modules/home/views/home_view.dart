// lib/app/modules/home/views/home_view.dart
import 'package:fluent_ai/app/data/services/user_service.dart';
import 'package:fluent_ai/app/modules/home/controllers/home_controller.dart';
import 'package:fluent_ai/app/modules/home/models/aktifitas_model.dart';
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor =
        controller.parseColor('#D84040'); // Warna utama aplikasi Anda

    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang lebih lembut
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo FLUENT.png',
                height: 28, width: 28), // Ukuran logo disesuaikan
            const SizedBox(width: 8),
            Text('FLUENT',
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    letterSpacing: -0.5)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(LucideIcons.bell, color: Colors.grey[700], size: 24),
                onPressed: () => Get.snackbar(
                    'Notifikasi', 'Belum ada notifikasi baru.',
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(10),
                    borderRadius: 10),
                tooltip: 'Notifikasi',
              ),
              Positioned(
                // Indikator notifikasi (dummy)
                right: 10, top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6)),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activities.isEmpty) {
          return _buildShimmerPage(theme);
        }
        return RefreshIndicator(
          // Tambahkan RefreshIndicator
          onRefresh: controller.fetchHomeData,
          color: primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildGreetingSection(theme),
              _buildStatsSection(theme, primaryColor),
              _buildSectionHeader(
                  'Mulai Latihan Cepat', LucideIcons.zap, primaryColor),
              _buildQuickActionsGrid(theme),
              _buildSectionHeader(
                  'Aktivitas Terakhir', LucideIcons.history, primaryColor,
                  onViewAll: controller.viewAllActivities),
              _buildLatestActivitiesList(theme),
              _buildSectionHeader(
                  'Rekomendasi Untukmu', LucideIcons.lightbulb, primaryColor),
              _buildPracticeRecommendations(theme, primaryColor),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        );
      }),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildShimmerPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // Shimmer untuk Greeting
              children: [
                Expanded(
                    child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)))),
                const SizedBox(width: 10),
                Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
                height: 20,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 24),
            // Shimmer untuk Stats Section
            Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 24),
            // Shimmer untuk Section Header
            Container(
                height: 20,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 16),
            // Shimmer untuk Quick Actions Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 24),
            Container(
                height: 20,
                width: 180,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 16),
            // Shimmer untuk List Aktivitas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color,
      {VoidCallback? onViewAll}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            20, 24, 16, 12), // Disesuaikan padding kanan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 22),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800])),
              ],
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                child: Text('Lihat Semua',
                    style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(ThemeData theme) {
    // UserService sudah di-inject dan bisa diakses via controller.userService
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  // Menggunakan controller untuk username dari UserService
                  'Hi, ${controller.userService.username.value}! 👋',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[850]),
                )),
            const SizedBox(height: 6),
            Text(
              'Selamat datang kembali! Siap untuk latihan dan jadi lebih fasih?',
              style:
                  TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, Color primaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.white, // Bisa juga primaryColor.withOpacity(0.05)
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Obx(() => Row(
                      // Obx untuk statistik
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            icon: LucideIcons.activity,
                            value:
                                '${controller.averageScore.value.toStringAsFixed(1)}',
                            label: 'Rata-rata',
                            color: Colors.amber.shade700),
                        _buildStatItem(
                            icon: LucideIcons.flame,
                            value: '${controller.consecutiveDays.value}',
                            label: 'Streak',
                            color: primaryColor),
                        _buildStatItem(
                            icon: LucideIcons.gem,
                            value: '${controller.tokens.value}',
                            label: 'Token',
                            color: Colors.blue.shade600),
                      ],
                    )),
                const SizedBox(height: 20),
                Obx(() => Column(
                      // Obx untuk progress bar
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progres Keseluruhan Kamu',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700])),
                            Text(
                                '${(controller.overallProgress.value * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: controller.overallProgress.value,
                            backgroundColor: primaryColor.withOpacity(0.2),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800])),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(Get.context!).size.width > 450
              ? 4
              : 2, // Lebih responsif
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.6, // Kartu dibuat lebih persegi
        ),
        delegate: SliverChildListDelegate(
          controller.quickActionItems
              .map((item) => _buildQuickActionCard(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    color: controller.parseColor(item['colorHex'] as String),
                    onTap: item['navigateTo'] != null
                        ? () => controller
                            .navigateToLatihanPage() // Navigasi ke halaman Latihan
                        : () => controller
                            .navigateToPractice(item['practiceType'] as String),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestActivitiesList(ThemeData theme) {
    return Obx(() {
      // Obx untuk activities
      if (controller.activities.isEmpty)
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Hanya tampilkan maksimal 3 aktivitas di home
            if (index >= 3) return null;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildActivityItem(controller.activities[index], theme),
            );
          },
          childCount: controller.activities.length > 3
              ? 3
              : controller.activities.length,
        ),
      );
    });
  }

  Widget _buildActivityItem(ActivityModel activity, ThemeData theme) {
    final color = controller.parseColor(activity.colorHex);
    return Card(
      elevation: 1.5,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(activity.icon, color: color, size: 22),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: Colors.grey[800]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(activity.date,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${activity.score}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 17)),
            Text('Skor',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        onTap: () => Get.toNamed('/activity-detail',
            arguments: activity), // Pastikan route ini ada
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPracticeRecommendations(ThemeData theme, Color primaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shadowColor: Colors.amber.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.amber.shade50, // Warna latar yang lembut
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.brainCircuit,
                        color: Colors.amber.shade700, size: 26),
                    const SizedBox(width: 10),
                    Text('Saran Cerdas Untukmu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.amber.shade800)),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      // Obx untuk recommendationText
                      controller.recommendationText.value,
                      style: TextStyle(
                          color: Colors.brown.shade700,
                          fontSize: 14,
                          height: 1.5),
                    )),
                const SizedBox(height: 16),
                Obx(() => Wrap(
                      // Obx untuk practiceTypes
                      spacing: 10,
                      runSpacing: 8,
                      children: controller.practiceTypes
                          .map((type) => Chip(
                                avatar: Icon(LucideIcons.checkCircle2,
                                    color: primaryColor, size: 16),
                                label: Text(type.title,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                                backgroundColor: primaryColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: primaryColor.withOpacity(0.3),
                                      width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ))
                          .toList(),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
