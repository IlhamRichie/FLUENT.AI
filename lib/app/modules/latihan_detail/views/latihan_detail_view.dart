import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LatihanDetailView extends StatelessWidget {
  const LatihanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final practice = Get.arguments as Map<String, dynamic>;
    final levels = practice['levels'] as List<String>;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(practice['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih level kesulitan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: levels.map((level) => Chip(
                        label: Text(level),
                        backgroundColor: _getLevelColor(level).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _getLevelColor(level),
                          fontWeight: FontWeight.bold,
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Instruksi Latihan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            _buildInstructionStep(1, 'Baca prompt yang diberikan dengan seksama'),
            _buildInstructionStep(2, 'Rekam diri Anda saat menjawab pertanyaan'),
            _buildInstructionStep(3, 'Gunakan waktu yang disediakan dengan baik'),
            _buildInstructionStep(4, 'Dapatkan analisis dari AI setelah selesai'),
            const SizedBox(height: 24),
            const Text(
              'Tips:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            _buildTipItem('Perhatikan intonasi dan kecepatan bicara'),
            _buildTipItem('Gunakan gestur tubuh yang sesuai'),
            _buildTipItem('Jaga kontak mata dengan kamera'),
            _buildTipItem('Hindari filler words seperti "eh", "anu"'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.toNamed('/practice-session', arguments: {
                  ...practice,
                  'selectedLevel': levels.first,
                }),
                child: const Text(
                  'Mulai Latihan Sekarang',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lightbulb, size: 20, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Mudah':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Sulit':
        return Colors.red;
      default:
        return Get.theme.colorScheme.primary;
    }
  }
}