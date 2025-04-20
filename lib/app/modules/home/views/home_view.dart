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
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(LucideIcons.mic, color: controller.primaryColor),
      ),
      title: Text(
        'FLUENT AI',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: controller.primaryColor,
          fontSize: 20,
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.bell, color: Colors.grey[700]),
          onPressed: controller.navigateToNotification,
        ),
        IconButton(
          icon: Icon(LucideIcons.settings, color: Colors.grey[700]),
          onPressed: controller.navigateToSettings,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async => controller.refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            const SizedBox(height: 16),
            _buildStatCard(),
            const SizedBox(height: 16),
            Obx(() => controller.hasTokens.value
                ? _buildTokenBalance()
                : _buildEmptyTokenCard()),
            const SizedBox(height: 16),
            _buildInterviewLevelsSection(),
            const SizedBox(height: 16),
            _buildLatestActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                'Hi, ${controller.username.value} 👋',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )),
          const SizedBox(height: 4),
          Text(
            'Yuk latih skill bicaramu bareng AI ✨',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Radius sesuai dengan Card
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD84040).withOpacity(1), // Warna pertama
            const Color(0xFFD84040).withOpacity(0.5), // Warna kedua
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2), // Ketebalan border (2 piksel)
        child: Card(
          elevation: 1,
          color: Colors.white, // Set warna latar belakang Card menjadi putih
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Radius sedikit lebih kecil
            side: BorderSide.none, // Hilangkan border default Card
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: controller.primaryColor.withOpacity(0.1),
                      child: Icon(
                        LucideIcons.user,
                        color: controller.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => Text(
                          controller.username.value,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const Spacer(),
                    Obx(() => Text(
                          'Skor: ${controller.averageScore.value.toStringAsFixed(1)}',
                          style: TextStyle(color: Colors.grey[600]),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      value: controller.speechCount.value.toString(),
                      label: 'Ucapan',
                      icon: LucideIcons.mic2,
                    ),
                    _buildStatItem(
                      value: controller.expressionCount.value.toString(),
                      label: 'Ekspresi',
                      icon: LucideIcons.smile,
                    ),
                    _buildStatItem(
                      value: controller.narrativeCount.value.toString(),
                      label: 'Narasi',
                      icon: LucideIcons.text,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      {required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: controller.primaryColor),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyTokenCard() {
    return Container(
      decoration: BoxDecoration(
        color:
            Colors.orange.withOpacity(0.3), // Warna oranye dengan opacity 30%
        borderRadius: BorderRadius.circular(12), // Radius sesuai dengan Card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(LucideIcons.star, color: Colors.orange),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Token kamu habis nih!',
                style: TextStyle(fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: controller.getFreeTokens,
              child: const Text(
                'Dapatkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenBalance() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(LucideIcons.star, color: Colors.green),
            const SizedBox(width: 12),
            Obx(() => Text(
                  '${controller.tokens.value} Token tersedia',
                  style: const TextStyle(fontSize: 14),
                )),
            const Spacer(),
            TextButton(
              onPressed: controller.getFreeTokens,
              child: Text(
                'Token Gratis',
                style: TextStyle(color: controller.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Level Latihan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: controller.interviewLevels
                    .map((level) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildLevelCard(level),
                        ))
                    .toList(),
              )),
        ),
      ],
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level) {
    return GestureDetector(
      onTap: () => controller.startInterview(level['level']),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: level['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: level['color'].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: level['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  level['icon'],
                  color: level['color'],
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                level['level'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: level['color'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                level['time'],
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: controller.aiInterviews
                  .take(2)
                  .map((interview) => _buildActivityItem(interview))
                  .toList(),
            )),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: Text(
            'Lihat Semua Aktivitas',
            style: TextStyle(color: controller.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> interview) {
    Color statusColor = Colors.grey;
    if (interview['status'] == 'Selesai') {
      statusColor = Colors.green;
    } else if (interview['status'] == 'Belum Selesai') {
      statusColor = Colors.orange;
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: 8), // Jarak vertikal antar card
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang putih
        borderRadius: BorderRadius.circular(12), // Radius melengkung
        border: Border.all(
          color: statusColor.withOpacity(0.5), // Warna border sesuai status
          width: 1.0, // Ketebalan border tipis
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    interview['category'],
                    style: TextStyle(
                      color: controller.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    interview['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              interview['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  interview['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (interview['score'] != null) ...[
                  const Spacer(),
                  Icon(LucideIcons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${interview['score']}/100',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: controller.primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 4,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.home),
          label: 'Home',
          backgroundColor: controller.primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.plusCircle),
          label: 'Latihan',
          backgroundColor: controller.primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.fileText),
          label: 'Materi',
          backgroundColor: controller.primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.user),
          label: 'Profil',
          backgroundColor: controller.primaryColor,
        ),
      ],
    );
  }
}
