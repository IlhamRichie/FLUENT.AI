import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart';
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluent_ai/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo FLUENT.png',
              height: 24, // Sesuaikan dengan tinggi teks
              width: 24, // Sesuaikan dengan lebar yang diinginkan
            ),
            const SizedBox(width: 3), // Jarak antara logo dan teks
            const Text(
              'LUENT',
              style: TextStyle(
                color: Color(0xFFD84040),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: Colors.grey[700]),
            onPressed: () =>
                Get.snackbar('Notifikasi', 'Fitur notifikasi akan datang!'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD84040)),
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildStatsSection(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Mulai Latihan Cepat'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildQuickActionsGrid(),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Aktivitas Terakhir'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildLatestActivitiesList(),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Rekomendasi Untukmu'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildPracticeRecommendations(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        );
      }),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              'Hi, ${controller.username.value}! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),
        const SizedBox(height: 8),
        const Text(
          'Siap latihan hari ini?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: LucideIcons.award,
                  value: '${controller.averageScore.value}',
                  label: 'Rata-rata',
                  color: Colors.amber,
                ),
                _buildStatItem(
                  icon: LucideIcons.flame,
                  value: '${controller.consecutiveDays.value}',
                  label: 'Hari Berturut',
                  color: const Color(0xFFD84040),
                ),
                _buildStatItem(
                  icon: LucideIcons.star,
                  value: '${controller.tokens.value}',
                  label: 'Token',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.averageScore.value / 100,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFD84040)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Perkembangan Kamu'),
                Text('${76.5}/100'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      delegate: SliverChildListDelegate([
        _buildQuickActionCard(
          icon: LucideIcons.briefcase,
          title: 'Wawancara',
          color: Colors.blue,
          onTap: () => controller.navigateToPractice('Wawancara'),
        ),
        _buildQuickActionCard(
          icon: LucideIcons.mic2,
          title: 'Public Speaking',
          color: Colors.green,
          onTap: () => controller.navigateToPractice('Public Speaking'),
        ),
        _buildQuickActionCard(
          icon: LucideIcons.smile,
          title: 'Ekspresi',
          color: Colors.orange,
          onTap: () => controller.navigateToPractice('Ekspresi'),
        ),
        _buildQuickActionCard(
          icon: LucideIcons.plus,
          title: 'Lainnya',
          color: const Color(0xFFD84040),
          onTap: () => controller
              .navigateToLatihan(), // Dengan arrow function jika perlu parameter
        ),
      ]),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: color.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestActivitiesList() {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivityItem(controller.activities[index]),
            ),
            childCount: controller.activities.take(2).length,
          ),
        ));
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final color = _parseColor(activity['color']);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: color.withOpacity(0.05),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(activity['icon'], color: color),
        ),
        title: Text(activity['title']),
        subtitle: Text(activity['date']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${activity['score']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Text(
              'Skor',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => Get.toNamed('/activity-detail', arguments: activity),
      ),
    );
  }

  Widget _buildPracticeRecommendations() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.lightbulb, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Berdasarkan analisis terakhir:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Kamu perlu meningkatkan kecepatan bicara dan mengurangi filler words',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.practiceTypes
                      .map((type) => Chip(
                            label: Text(type['title']),
                            backgroundColor:
                                const Color(0xFFD84040).withOpacity(0.1),
                            labelStyle:
                                const TextStyle(color: Color(0xFFD84040)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: const Color(0xFFD84040).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Color _parseColor(dynamic color) {
    if (color is Color) return color;
    if (color is String && color.startsWith('#')) {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    }
    return const Color(0xFFD84040); // Default to red
  }
}
