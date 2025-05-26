// lib/app/modules/virtual_hrd/views/virtual_hrd_view.dart
import 'package:fluent_ai/app/modules/virtualhrd/controllers/virtualhrd_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:fluent_ai/app/routes/app_pages.dart'; // Untuk navigasi kembali

// Pastikan LatihanController di-inject global jika Anda mengaksesnya dari sini
// Atau, jika warna/ikon bisa didapat dari VirtualHrdController, itu lebih baik.
// import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart';

class VirtualhrdView extends GetView<VirtualhrdController> {
  const VirtualhrdView({super.key});

  String getHrdEmoji(HrdMood mood) {
    switch (mood) {
      case HrdMood.listening:
        return "🤔";
      case HrdMood.thinking:
        return "🧐";
      case HrdMood.positive:
        return "😊";
      case HrdMood.concerned:
        return "😟";
      case HrdMood.confused:
        return "😕";
      case HrdMood.neutral:
      default:
        return "🙂";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari VirtualHrdController yang sudah diinisialisasi dengan argumen
    final Color hrdColor = controller.hrdColor.value;

    return WillPopScope(
      onWillPop: controller.confirmExitSession,
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Warna latar belakang utama
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.8, // Sedikit elevasi untuk appbar
          shadowColor: Colors.grey[300],
          leading: IconButton(
              icon: Icon(LucideIcons.arrowLeft,
                  color: Colors.grey[700], size: 24),
              onPressed: () async {
                bool canPop = await controller.confirmExitSession();
                if (canPop) {
                  Get.back();
                }
              }),
          title: Text(
            'Simulasi Virtual HRD',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.grey[850]),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.showEvaluation.value) {
            return _buildEvaluationScreen(hrdColor);
          }
          // Column utama untuk layout sesi
          return Column(
            children: [
              // Area Pertanyaan (Expanded)
              Expanded(
                flex:
                    5, // Sesuaikan rasio flex jika perlu (misal 5 untuk pertanyaan)
                child: _buildQuestionArea(hrdColor),
              ),
              // Area Jawaban (Expanded)
              Expanded(
                flex: 4, // Misal 4 untuk jawaban
                child: _buildAnswerArea(),
              ),
              // Area Kontrol (Tidak Expanded, tinggi tetap)
              _buildControls(hrdColor),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuestionArea(Color hrdColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6), // Margin antar area
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: hrdColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: SingleChildScrollView(
        // Memungkinkan konten di dalam area ini untuk scroll jika lebih tinggi
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Pusatkan konten jika sedikit
          children: [
            const SizedBox(height: 10), // Beri sedikit ruang di atas
            Obx(() => Text(
                  getHrdEmoji(controller.currentHrdMood.value),
                  style: const TextStyle(
                      fontSize: 56), // Emoji lebih kecil sedikit
                )
                    .animate(key: ValueKey(controller.currentHrdMood.value))
                    .scale(duration: 300.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 200.ms)),
            const SizedBox(height: 16),
            Text(
              "Virtual HRD Bertanya:",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoadingQuestion.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(
                      color: hrdColor, strokeWidth: 3),
                );
              }
              return Padding(
                // Padding agar teks tidak terlalu mepet
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  controller.currentQuestion.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[850],
                      height: 1.4),
                )
                    .animate(key: ValueKey(controller.currentQuestion.value))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut),
              );
            }),
            const SizedBox(height: 10), // Beri sedikit ruang di bawah
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerArea() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6), // Margin antar area
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blueGrey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: SingleChildScrollView(
        // Memungkinkan konten di dalam area ini untuk scroll
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jawaban Anda:",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!)),
                  constraints:
                      const BoxConstraints(minHeight: 50), // Tinggi minimal
                  child: Text(
                    controller.userAnswerText.value.isEmpty &&
                            !controller.isListening.value
                        ? "Ketuk mic untuk menjawab..."
                        : controller.isListening.value
                            ? "\"${controller.recognizedWords.value}\"..." // Indikasi masih mendengarkan
                            : controller.userAnswerText.value,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontStyle: controller.userAnswerText.value.isEmpty &&
                                !controller.isListening.value
                            ? FontStyle.italic
                            : FontStyle.normal,
                        height: 1.4),
                  ),
                )),
            const SizedBox(height: 16),
            Text(
              "Saran dari Virtual HRD:",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: controller.hrdColor.value
                              .withOpacity(0.06), // Warna lebih lembut
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  controller.hrdColor.value.withOpacity(0.3))),
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Text(
                        controller.aiFeedbackText.value.isEmpty
                            ? "Saran akan muncul di sini."
                            : controller.aiFeedbackText.value,
                        style: TextStyle(
                            fontSize: 13.5,
                            color: controller.hrdColor.value.darken(0.15),
                            fontStyle: controller.aiFeedbackText.value.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            height: 1.4,
                            fontWeight: FontWeight.w500),
                      ),
                    ))
                .animate(key: ValueKey(controller.aiFeedbackText.value))
                .fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color hrdColor) {
    return Container(
      // Bungkus dengan Container untuk padding/margin jika perlu
      padding: const EdgeInsets.fromLTRB(
          20, 12, 20, 20), // Padding untuk area kontrol
      color: Colors.grey[
          100], // Samakan dengan background scaffold agar tidak ada garis aneh
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Agar Column tidak mengambil semua ruang
        children: [
          Obx(() => AvatarGlow(
                animate: controller.isListening.value,
                glowColor: hrdColor,
                duration: const Duration(milliseconds: 1800),
                repeat: true,
                child: Material(
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: controller.isListening.value
                        ? hrdColor.withOpacity(0.85)
                        : hrdColor,
                    radius: 35,
                    child: IconButton(
                      icon: Icon(
                        controller.isListening.value
                            ? LucideIcons.square
                            : LucideIcons.mic,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: controller.listen,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 12), // Kurangi jarak sedikit
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.arrowRightCircle,
                      size: 18), // Ikon lebih kecil
                  label: const Text("Lanjut"), // Teks lebih singkat
                  onPressed: (controller.isLoadingQuestion.value ||
                          controller.isListening.value)
                      ? null
                      : controller.submitAnswerAndNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hrdColor.darken(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14), // Padding tombol
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEvaluationScreen(Color hrdColor) {
    // ... (kode _buildEvaluationScreen tetap sama seperti jawaban sebelumnya) ...
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 20.0), // Padding disesuaikan
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10), // Beri jarak dari appbar
          Icon(LucideIcons.award,
                  size: 60, color: hrdColor) // Ukuran ikon disesuaikan
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .then(delay: 200.ms)
              .shake(hz: 3, duration: 400.ms, rotation: 0.05),
          const SizedBox(height: 20),
          Text(
            "Evaluasi Sesi Selesai!",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[850]), // Font disesuaikan
          ),
          const SizedBox(height: 10),
          Text(
            "Berikut adalah ringkasan performa Anda dalam simulasi Virtual HRD:",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.5,
                color: Colors.grey[600],
                height: 1.5), // Font disesuaikan
          ),
          const SizedBox(height: 24), // Jarak antar elemen
          Card(
            elevation: 2, // Elevasi lebih halus
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8), // Margin Card
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEvalItem(
                          "Total Pertanyaan Diajukan",
                          controller.evaluationResults['total_questions_asked']
                                  ?.toString() ??
                              '-',
                          LucideIcons.listOrdered,
                          hrdColor),
                      _buildEvalItem(
                          "Pertanyaan Dijawab",
                          controller.evaluationResults['questions_answered']
                                  ?.toString() ??
                              '-',
                          LucideIcons.checkSquare,
                          hrdColor),
                      _buildEvalItem(
                          "Kualitas Respon (Contoh)",
                          controller.evaluationResults[
                                  'average_response_quality'] ??
                              '-',
                          LucideIcons.thumbsUp,
                          hrdColor),
                      const SizedBox(height: 16),
                      Text("Poin Penting dari Sesi:",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: hrdColor)), // Font disesuaikan
                      const SizedBox(height: 8),
                      if (controller.evaluationResults['key_takeaways'] !=
                              null &&
                          (controller.evaluationResults['key_takeaways']
                                  as List)
                              .isNotEmpty)
                        ...(controller.evaluationResults['key_takeaways']
                                as List<dynamic>)
                            .map((takeaway) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(LucideIcons.star,
                                          size: 15,
                                          color: hrdColor
                                              .withOpacity(0.7)), // Ukuran ikon
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(takeaway.toString(),
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  color: Colors.grey[700],
                                                  height: 1.3))), // Font
                                    ],
                                  ),
                                ))
                            .toList()
                      else
                        Text("Tidak ada poin spesifik.",
                            style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey[600])), // Font
                      const SizedBox(height: 16),
                      Text("Saran Umum:",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: hrdColor)), // Font
                      const SizedBox(height: 8),
                      Text(
                          controller.evaluationResults['overall_feedback'] ??
                              "Terus berlatih!",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4)), // Font
                    ],
                  )),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
          const SizedBox(height: 28), // Jarak
          ElevatedButton.icon(
            icon:
                const Icon(LucideIcons.refreshCcwDot, size: 18), // Ukuran ikon
            label: const Text("Ulangi Sesi"),
            onPressed: controller.restartSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: hrdColor, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14), // Padding
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold), // Font
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)), // Bentuk tombol
            ),
          ),
          const SizedBox(height: 10), // Jarak
          TextButton(
            onPressed: () => Get.offAllNamed(Routes.LATIHAN),
            child: Text("Kembali ke Daftar Latihan",
                style: TextStyle(
                    color: hrdColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14)), // Font
          ),
          const SizedBox(height: 20), // Padding bawah
        ],
      ),
    );
  }

  Widget _buildEvalItem(
      String label, String value, IconData icon, Color color) {
    // ... (tetap sama)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color.withOpacity(0.8)), // Ukuran ikon
          const SizedBox(width: 12),
          Text("$label:",
              style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)), // Font
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey[850],
                  fontWeight: FontWeight.bold)), // Font
        ],
      ),
    );
  }
}

// Helper Color extension tetap sama
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1,
        'Amount harus antara 0.0 dan 1.0'); // Pesan assert lebih jelas
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
