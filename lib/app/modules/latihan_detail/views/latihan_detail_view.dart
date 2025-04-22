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
          controller.latihanDetail['nama'] ?? controller.latihanDetail['judul'] ?? 'Detail Latihan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        )),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          onPressed: () => Get.back(),
        ),
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
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
        color: color.withOpacity(0.05),
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.latihanDetail['kategori'] ?? controller.latihanDetail['nama'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
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
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoSection() {
    return Obx(() {
      final color = _parseColor(controller.latihanDetail['warna'] ?? '#D84040');
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Latihan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: LucideIcons.clock,
                label: 'Durasi',
                value: controller.latihanDetail['durasi'] ?? '-',
                color: color,
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                icon: LucideIcons.activity,
                label: 'Tingkat Kesulitan',
                value: controller.latihanDetail['kesulitan'] ?? '-',
                color: color,
              ),
              const SizedBox(height: 8),
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
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionSection() {
    return Obx(() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
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
                ),
              ),
              const SizedBox(height: 12),
              ...(controller.latihanDetail['instruksi'] as List<dynamic>? ?? []).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildExampleQuestions() {
    return Obx(() {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
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
                ),
              ),
              const SizedBox(height: 12),
              ...(controller.latihanDetail['contoh_pertanyaan'] as List<dynamic>? ?? []).map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.helpCircle, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
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
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Mulai Latihan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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