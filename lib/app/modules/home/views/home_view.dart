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
        title: Text(
          'FLUENT',
          style: TextStyle(
            color: controller.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: Colors.grey[700]),
            onPressed: () => Get.snackbar('Notifikasi', 'Fitur notifikasi akan datang!'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildLatestActivities(),
            const SizedBox(height: 24),
            _buildPracticeRecommendations(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: controller.primaryColor,
        unselectedItemColor: Colors.grey,
        items: controller.bottomNavItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item['icon']),
          label: item['label'],
        )).toList(),
      )),
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
      color: Colors.white, // Set card color to white
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
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
                  color: Colors.red,
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
              valueColor: AlwaysStoppedAnimation<Color>(controller.primaryColor),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mulai Latihan Cepat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: LucideIcons.briefcase,
              title: 'Wawancara',
              color: Colors.blue,
              borderColor: Colors.blue[200]!,
              onTap: () => controller.navigateToPractice('Wawancara'),
            ),
            _buildQuickActionCard(
              icon: LucideIcons.mic2,
              title: 'Public Speaking',
              color: Colors.green,
              borderColor: Colors.green[200]!,
              onTap: () => controller.navigateToPractice('Public Speaking'),
            ),
            _buildQuickActionCard(
              icon: LucideIcons.smile,
              title: 'Ekspresi',
              color: Colors.orange,
              borderColor: Colors.orange[200]!,
              onTap: () => controller.navigateToPractice('Ekspresi'),
            ),
            _buildQuickActionCard(
              icon: LucideIcons.plus,
              title: 'Lainnya',
              color: controller.primaryColor,
              borderColor: Colors.grey[300]!,
              onTap: controller.showPracticeDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white, // Set card color to white
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
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

  Widget _buildLatestActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terakhir',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
          children: controller.activities.take(2).map((activity) =>
            _buildActivityItem(activity)
          ).toList(),
        )),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Get.toNamed('/activities'),
          child: Text(
            'Lihat Semua Aktivitas',
            style: TextStyle(color: controller.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Card(
      color: Colors.white, // Set card color to white
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: activity['color'].withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activity['color'].withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(activity['icon'], color: activity['color']),
        ),
        title: Text(activity['title']),
        subtitle: Text(activity['date']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${activity['score']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Skor'),
          ],
        ),
        onTap: () => Get.toNamed('/activity-detail', arguments: activity),
      ),
    );
  }

  Widget _buildPracticeRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi Untukmu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Obx(() => Card(
          color: Colors.white, // Set card color to white
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.lightbulb, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.practiceTypes.map((type) =>
                    Chip(
                      label: Text(type['title']),
                      backgroundColor: controller.primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: controller.primaryColor),
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}