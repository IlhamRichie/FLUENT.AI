import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart';
import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';
import 'package:fluent_ai/app/modules/wawancara/controllers/wawancara_controller.dart';
import 'package:fluent_ai/app/modules/wawancara/views/wawancara_view.dart'; // Navigasi langsung
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WawancaraIntroView extends GetView<WawancaraController> {
  const WawancaraIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller diinisialisasi oleh WawancaraBinding (jika pakai named routes)
    // atau di-lazyPut/put di binding/controller yang lebih tinggi (jika navigasi langsung)

    // Memproses argumen bisa dilakukan di onInit controller, atau di sini jika sederhana
    // dan hanya untuk tampilan awal view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
        final arguments = Get.arguments as Map<String, dynamic>;
        if (arguments.containsKey('kategori')) {
          controller.selectedKategoriFromLatihan.value = arguments['kategori'] as KategoriLatihanModel?;
        } else if (arguments.containsKey('latihanItem')) {
          controller.selectedLatihanItemFromLatihan.value = arguments['latihanItem'] as LatihanItemModel?;
        }
        controller.update(['headerSubtitle']); // ID untuk GetBuilder jika digunakan
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0.5,
        // shadowColor: Colors.grey[200],
        title: const Text(
          'Latihan Wawancara',
          style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.black87),
          onPressed: () {
            controller.restartInterview(resetKategoriDanItem: true);
            Get.back();
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeader(controller),
            const SizedBox(height: 32),
            _buildInstructionCard(),
            const SizedBox(height: 32),
            _buildDifficultySelector(controller),
            const SizedBox(height: 40),
            _buildStartButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WawancaraController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persiapkan Wawancaramu!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[900]),
        ),
        const SizedBox(height: 8),
        // Menggunakan Obx karena selectedKategoriFromLatihan adalah Rxn
        Obx(() {
            String subHeaderText = 'Latih kemampuan wawancara dengan bantuan AI untuk meraih pekerjaan impianmu.';
            if (c.selectedKategoriFromLatihan.value != null) {
              subHeaderText = 'Kategori Pilihan: ${c.selectedKategoriFromLatihan.value!.nama}';
            } else if (c.selectedLatihanItemFromLatihan.value != null) {
              subHeaderText = 'Latihan Dipilih: ${c.selectedLatihanItemFromLatihan.value!.judul}';
            }
            return Text(
              subHeaderText,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
            );
          }
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0).withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 3),
          )
        ]
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3A86FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.listChecks, size: 22, color: Color(0xFF3A86FF)),
            ),
            const SizedBox(width: 12),
            const Text('Petunjuk Latihan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
          ]),
          const SizedBox(height: 16),
          _buildInstructionStep('1. Pilih level kesulitan wawancara yang diinginkan.'),
          _buildInstructionStep('2. Jawab setiap pertanyaan yang muncul di layar.'),
          _buildInstructionStep('3. Sistem AI kami akan menganalisis aspek berikut:'),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 6, bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubStep('Ekspresi wajah dan gestur tubuh Anda.'),
                _buildSubStep('Kelancaran, kejelasan, dan intonasi bicara.'),
                _buildSubStep('Penggunaan kata dan struktur kalimat.'),
              ],
            ),
          ),
          _buildInstructionStep('4. Dapatkan feedback instan dan skor di akhir sesi.'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 24, child: Icon(LucideIcons.checkCircle2, size: 16, color: Colors.green[600])),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14.5, color: Colors.grey[800], height: 1.5))),
      ]),
    );
  }

  Widget _buildSubStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 24, child: Icon(LucideIcons.arrowRight, size: 12, color: Colors.grey[500])),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4))),
      ]),
    );
  }

  Widget _buildDifficultySelector(WawancaraController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3A86FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.barChart3, size: 20, color: Color(0xFF3A86FF)),
          ),
          const SizedBox(width: 10),
          const Text('Pilih Tingkat Kesulitan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        ]),
        const SizedBox(height: 16),
        Obx(() => Row(
          children: [
            Expanded(child: _buildDifficultyButton('Pemula', 0, LucideIcons.graduationCap, c)),
            const SizedBox(width: 12),
            Expanded(child: _buildDifficultyButton('Menengah', 1, LucideIcons.award, c)),
            const SizedBox(width: 12),
            Expanded(child: _buildDifficultyButton('Mahir', 2, LucideIcons.gem, c)),
          ],
        )),
      ],
    );
  }

  Widget _buildDifficultyButton(String label, int level, IconData icon, WawancaraController c) {
    // Tidak perlu Obx di sini karena parent (_buildDifficultySelector) sudah Obx
    final isSelected = c.difficultyLevel.value == level;
    return SizedBox(
      height: 100,
      child: OutlinedButton(
        onPressed: () => c.difficultyLevel.value = level,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF3A86FF).withOpacity(0.1) : Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFF3A86FF) : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: isSelected ? 2 : 0,
          shadowColor: isSelected ? const Color(0xFF3A86FF).withOpacity(0.3) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isSelected ? const Color(0xFF3A86FF) : Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label, textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isSelected ? const Color(0xFF3A86FF) : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(WawancaraController c) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Pastikan controller (c) memiliki difficultyLevel yang sudah di-set
              // Panggil fungsi di controller untuk menyiapkan pertanyaan jika diperlukan sebelum navigasi
              // c.prepareQuestionsForSelectedLevel();
              Get.to(() => const WawancaraView()); // Navigasi langsung ke kelas View
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              shadowColor: const Color(0xFF3A86FF).withOpacity(0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mulai Latihan Sekarang',
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(width: 10),
                Icon(LucideIcons.playCircle, size: 22, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Durasi latihan diperkirakan 5-10 menit tergantung level.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
