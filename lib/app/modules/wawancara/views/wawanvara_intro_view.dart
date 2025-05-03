import 'package:fluent_ai/app/modules/wawancara/controllers/wawancara_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'wawancara_view.dart';

class WawancaraIntroView extends StatelessWidget {
  const WawancaraIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Latihan Wawancara',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildInstructionCard(),
              const SizedBox(height: 32),
              _buildDifficultySelector(),
              const SizedBox(height: 40),
              _buildStartButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persiapkan Wawancaramu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Latih kemampuan wawancara dengan bantuan AI',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A86FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.listChecks,
                  size: 20,
                  color: Color(0xFF3A86FF),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Petunjuk Latihan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep('1. Pilih level kesulitan wawancara'),
          _buildInstructionStep('2. Baca script yang muncul di layar'),
          _buildInstructionStep('3. Sistem akan menganalisis:'),
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 4),
            child: Column(
              children: [
                _buildSubStep('- Ekspresi wajah dan gestur tubuh'),
                _buildSubStep('- Kelancaran dan kejelasan bicara'),
                _buildSubStep('- Penggunaan kata dan struktur kalimat'),
              ],
            ),
          ),
          _buildInstructionStep('4. Dapatkan feedback real-time dan lengkap'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '◦',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.barChart2,
              size: 20,
              color: Color(0xFF3A86FF),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tingkat Kesulitan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDifficultyButton('Pemula', 0, Icons.school_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildDifficultyButton('Menengah', 1, Icons.workspace_premium_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildDifficultyButton('Mahir', 2, Icons.star_outline)),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(String label, int level, IconData icon) {
    final isSelected = Get.find<WawancaraController>().difficultyLevel.value == level;
    return OutlinedButton(
      onPressed: () => Get.find<WawancaraController>().difficultyLevel.value = level,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF3A86FF).withOpacity(0.1) : Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF3A86FF) : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF3A86FF) : Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? const Color(0xFF3A86FF) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.to(() => const WawancaraView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mulai Latihan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  LucideIcons.arrowRight,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Latihan akan berlangsung selama 5-10 menit',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}