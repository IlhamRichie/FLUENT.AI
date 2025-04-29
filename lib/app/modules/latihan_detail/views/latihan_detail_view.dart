import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluent_ai/app/modules/latihan_detail/controllers/latihan_detail_controller.dart';

class LatihanDetailView extends GetView<LatihanDetailController> {
  const LatihanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
              controller.latihanDetail['nama'] ?? 
              controller.latihanDetail['judul'] ?? 
              'Detail Latihan',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            )),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bookmark, size: 20, color: Colors.black54),
            onPressed: () {},
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildInstructionSection(),
                  const SizedBox(height: 24),
                  _buildExampleQuestions(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      final bgColor = color.withOpacity(0.05);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(controller.latihanDetail['ikon'] ?? ''),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.latihanDetail['kategori'] ?? 
                      controller.latihanDetail['nama'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                controller.latihanDetail['deskripsi_lengkap'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              if (controller.latihanDetail['tips'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.lightbulb, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tips: ${controller.latihanDetail['tips']}",
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoSection() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      final bgColor = color.withOpacity(0.05);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Latihan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: LucideIcons.clock,
                label: 'Durasi',
                value: controller.latihanDetail['durasi'] ?? '-',
                color: color,
              ),
              const Divider(height: 24, thickness: 0.5, color: Colors.black12),
              _buildInfoItem(
                icon: LucideIcons.activity,
                label: 'Tingkat Kesulitan',
                value: controller.latihanDetail['kesulitan'] ?? '-',
                color: color,
              ),
              const Divider(height: 24, thickness: 0.5, color: Colors.black12),
              _buildInfoItem(
                icon: LucideIcons.star,
                label: 'Skor Terakhir',
                value: controller.latihanDetail['skor']?.toString() ?? '-',
                color: color,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionSection() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      final bgColor = color.withOpacity(0.05);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instruksi Latihan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...(controller.latihanDetail['instruksi'] as List<dynamic>? ?? []).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.check, size: 14, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildExampleQuestions() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      final bgColor = color.withOpacity(0.05);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contoh Pertanyaan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...(controller.latihanDetail['contoh_pertanyaan'] as List<dynamic>? ?? []).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.helpCircle, size: 14, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStartButton() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.mulaiLatihan,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Mulai Latihan Sekarang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'interview': return LucideIcons.briefcase;
      case 'public_speaking': return LucideIcons.mic2;
      case 'expression': return LucideIcons.smile;
      case 'filler_word': return LucideIcons.type;
      default: return LucideIcons.activity;
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}