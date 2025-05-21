import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marquee/marquee.dart'; // Impor package marquee
import '../controllers/wawancara_controller.dart';
import 'package:fluent_ai/app/routes/app_pages.dart';

class WawancaraView extends GetView<WawancaraController> {
  const WawancaraView({super.key});

  // ... (kode build, _buildCameraLoadingIndicator, _buildAppBar, dll. tetap sama) ...
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.isRecording.value ||
            (controller.showScript.value &&
                !controller.showEvaluation.value &&
                controller.currentQuestionIndex.value >= 0 &&
                controller.questions.isNotEmpty)) {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Keluar Latihan?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text(
                  'Proses latihan yang sedang berjalan akan hilang. Apakah Anda yakin ingin keluar?'),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Batal',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    controller.stopRecordingAndReset();
                    Get.back(result: true);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400]),
                  child: const Text('Ya, Keluar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
        controller.restartInterview(resetKategoriDanItem: true);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.showEvaluation.value) {
            return _buildEvaluationView();
          } else if (controller.isRecording.value) {
            if (!controller.isCameraInitialized.value ||
                controller.cameraController == null ||
                !controller.cameraController!.value.isInitialized) {
              return _buildCameraLoadingIndicator();
            }
            return _buildRecordingView();
          } else if (!controller.showScript.value) {
            return _buildCountdownView();
          } else {
            return _buildScriptView();
          }
        }),
      ),
    );
  }

  Widget _buildCameraLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3A86FF)),
          SizedBox(height: 20),
          Text('Menginisialisasi kamera...',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.grey[200],
      title: Obx(() => Text(
            controller.showEvaluation.value
                ? 'Hasil Evaluasi Latihan'
                : controller.isRecording.value
                    ? 'Sesi Merekam Jawaban'
                    : 'Level ${controller.getDifficultyLabel()}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87),
          )),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(LucideIcons.x, size: 22, color: Colors.black54),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() => controller.showEvaluation.value
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(LucideIcons.share2,
                      size: 20, color: Color(0xFF3A86FF)),
                  onPressed: controller.shareResults,
                  tooltip: 'Bagikan Hasil',
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildScriptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 24),
          _buildQuestionCard(),
          const SizedBox(height: 32),
          _buildStartRecordingButtonFromScript(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.questions.isEmpty
                  ? 'Memuat pertanyaan...'
                  : 'Pertanyaan ${controller.currentQuestionIndex.value + 1} dari ${controller.questions.length}',
              style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            if (controller.questions.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (controller.currentQuestionIndex.value + 1) /
                      controller.questions.length,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
                  minHeight: 10,
                ),
              ),
          ],
        ));
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9F0).withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF3A86FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.messageSquareDashed,
                        size: 22, color: Color(0xFF3A86FF))),
                const SizedBox(width: 12),
                const Text('Pertanyaan untuk Anda:',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87))
              ]),
              const SizedBox(height: 16),
              Text(controller.currentQuestion.value,
                  style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),
              _buildInstructionItem(
                  LucideIcons.video, 'Kamera akan merekam visual Anda.'),
              _buildInstructionItem(
                  LucideIcons.mic, 'Audio jawaban Anda akan direkam.'),
              _buildInstructionItem(
                  LucideIcons.brain, 'AI akan menganalisis jawaban Anda.'),
              const SizedBox(height: 12),
              Obx(() => Text(
                    'Anda memiliki waktu sekitar ${controller.displayDuration.value} detik untuk menjawab setelah rekaman dimulai.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic),
                  )),
            ],
          )),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3A86FF).withOpacity(0.8)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[700], height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildStartRecordingButtonFromScript() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(LucideIcons.playCircle,
                size: 22, color: Colors.white),
            label: const Text('Mulai Jawab & Rekam',
                style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            onPressed: () {
              if (controller.isCameraInitialized.value) {
                controller.startCountdown();
              } else {
                Get.snackbar("Kamera Belum Siap",
                    "Mohon tunggu hingga kamera selesai diinisialisasi.",
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                shadowColor: const Color(0xFF3A86FF).withOpacity(0.4)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Rekaman akan dimulai setelah hitungan mundur.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCountdownView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(LucideIcons.camera, size: 48, color: Color(0xFF3A86FF)),
            const SizedBox(height: 16),
            const Text('Persiapkan Diri Anda!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Text('Rekaman akan dimulai dalam...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 32),
            Obx(() => Text(controller.countdownValue.value.toString(),
                style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A86FF)))),
            const SizedBox(height: 32),
            SizedBox(
              width: 70,
              height: 70,
              child: Obx(() => CircularProgressIndicator(
                    strokeWidth: 7,
                    value: controller.countdownValue.value > 0
                        ? (controller.initialCountdownValue -
                                controller.countdownValue.value) /
                            controller.initialCountdownValue
                        : 1.0,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
                    backgroundColor: Colors.grey[200],
                  )),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12)),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.lightbulb,
                          size: 22, color: Color(0xFF3A86FF)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(controller.currentTip.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[800],
                                  height: 1.4))),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingView() {
    if (!controller.isCameraInitialized.value ||
        controller.cameraController == null ||
        !controller.cameraController!.value.isInitialized) {
      return _buildCameraLoadingIndicator();
    }
    // Teks yang akan berjalan
    String runningText = controller.currentQuestion.value.isNotEmpty
        ? "Fokus pada pertanyaan: \"${controller.currentQuestion.value}\". Berikan jawaban terbaik Anda dengan percaya diri dan jelas. Perhatikan ekspresi dan intonasi."
        : "Mulai berbicara ketika Anda siap. Sistem sedang menganalisis performa Anda secara realtime.";
    // Estimasi panjang teks untuk durasi. Ini sangat kasar.
    // Anggap 1 karakter = 0.1 detik untuk marquee lambat, atau sesuaikan `velocity`
    // double estimatedDurationSeconds = runningText.length * 0.15;

    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                child: Transform.scale(
                  scaleX: -1,
                  child: CameraPreview(controller.cameraController!),
                ),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(() => AnimatedOpacity(
                        opacity: controller.isRecording.value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildRecordingIndicatorDot(),
                              const SizedBox(width: 8),
                              Text(
                                  'MEREKAM ${controller.formatDuration(controller.recordingDuration.value)}',
                                  style: TextStyle(
                                      color: Colors.red[300],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
        // --- Teks Berjalan (Marquee) ---
        Obx(() {
          // Obx di sini untuk merender ulang marquee jika currentQuestion berubah
          String marqueeTextContent = controller
                  .currentQuestion.value.isNotEmpty
              ? "Fokus pada pertanyaan: \"${controller.currentQuestion.value}\". Berikan jawaban terbaik Anda dengan percaya diri dan jelas. Perhatikan ekspresi dan intonasi Anda."
              : "Mulai berbicara ketika Anda siap. Sistem sedang menganalisis performa Anda secara realtime.";
          if (!controller.isRecording.value) {
            // Jangan tampilkan marquee jika tidak merekam
            return const SizedBox.shrink();
          }
          return Container(
            height: 40, // Atur tinggi area marquee
            color: Colors.black
                .withOpacity(0.05), // Warna latar belakang tipis untuk marquee
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Marquee(
              text: marqueeTextContent,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  color: Colors.grey[700]),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace:
                  20.0, // Jarak antar teks jika teks lebih pendek dari layar
              velocity: 30.0, // Kecepatan scroll (pixels per detik), sesuaikan
              pauseAfterRound:
                  const Duration(seconds: 2), // Jeda setelah satu putaran
              startPadding: 10.0,
              accelerationDuration: const Duration(milliseconds: 500),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
              // faderEnable: true, // Aktifkan jika ingin efek fade di ujung
              // faderColor: Colors.white.withOpacity(0.1),
            ),
          );
        }),
        // --- Akhir Teks Berjalan ---
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5))
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20,
                  16), // Kurangi padding atas agar tidak terlalu jauh dari marquee
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Analisis Realtime (Simulasi)',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 12),
                      _buildAnalysisRow(
                          icon: LucideIcons.smilePlus,
                          title: 'Ekspresi Anda',
                          value: controller.currentExpressionFeedback.value,
                          color: controller.getExpressionColor()),
                      const SizedBox(height: 10),
                      _buildAnalysisRow(
                          icon: LucideIcons.volume2,
                          title: 'Kejelasan Bicara',
                          value: controller.currentClarityFeedback.value,
                          color: controller.getClarityColor()),
                      const SizedBox(height: 10),
                      _buildAnalysisRow(
                          icon: LucideIcons.zapOff,
                          title: 'Kata Pengisi',
                          value:
                              '${controller.fillerWordCount.value} terdeteksi',
                          color: controller.getFillerWordColor()),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(LucideIcons.checkSquare, size: 20),
                          label: const Text('Selesai & Lihat Hasil'),
                          onPressed: controller.stopRecording,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicatorDot() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: controller.showRecordingDot.value
                ? Colors.redAccent[400]
                : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: controller.showRecordingDot.value
                ? [
                    BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
                        blurRadius: 6,
                        spreadRadius: 1)
                  ]
                : [],
          ),
        ));
  }

  Widget _buildAnalysisRow(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: color)),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                fontSize: 14.5,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w600, color: color),
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ... (sisa kode: _buildEvaluationView dan semua method build anaknya tetap sama) ...
  Widget _buildEvaluationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildEvaluationHeader(),
          const SizedBox(height: 24),
          _buildScoreCard(),
          const SizedBox(height: 28),
          _buildFeedbackSection(),
          const SizedBox(height: 28),
          _buildProgressChart(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildEvaluationHeader() {
    return Column(children: [
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF3A86FF).withOpacity(0.8),
                const Color(0xFF3A86FF)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF3A86FF).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1)
              ]),
          child: const Icon(LucideIcons.partyPopper,
              size: 44, color: Colors.white)),
      const SizedBox(height: 16),
      const Text('Latihan Telah Selesai!',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
      const SizedBox(height: 8),
      Obx(() => Chip(
            avatar: Icon(LucideIcons.barChart3,
                size: 16, color: Colors.blueGrey[700]),
            label: Text('Level ${controller.getDifficultyLabel()}',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[800],
                    fontWeight: FontWeight.w500)),
            backgroundColor: Colors.blueGrey[50],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          )),
    ]);
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9F0).withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Obx(() => Column(
            children: [
              _buildScoreRow(),
              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 20),
              _buildStatItem(
                  icon: LucideIcons.gauge,
                  label: 'Skor Ekspresi',
                  value: controller.evaluationResults['expression_score']
                          ?.toString() ??
                      '-'),
              const SizedBox(height: 18),
              _buildStatItem(
                  icon: LucideIcons.mic2,
                  label: 'Skor Kejelasan',
                  value: controller.evaluationResults['clarity_score']
                          ?.toString() ??
                      '-'),
              if (controller.evaluationResults['filler_words'] != null) ...[
                const SizedBox(height: 18),
                _buildStatItem(
                    icon: LucideIcons.zapOff,
                    label: 'Kata Pengisi',
                    value:
                        '${controller.evaluationResults['filler_words']} terdeteksi')
              ],
              if (controller.evaluationResults['response_time'] != null) ...[
                const SizedBox(height: 18),
                _buildStatItem(
                    icon: LucideIcons.timer,
                    label: 'Rata-rata Waktu',
                    value: controller.evaluationResults['response_time']
                            ?.toString() ??
                        '-')
              ]
            ],
          )),
    );
  }

  Widget _buildScoreRow() {
    return Obx(() {
      double overallScore =
          (controller.evaluationResults['overall_score'] as num? ?? 0)
              .toDouble();
      Color scoreColor = Colors.green.shade600;
      if (overallScore < 50)
        scoreColor = Colors.red.shade400;
      else if (overallScore < 75) scoreColor = Colors.orange.shade500;

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 100,
            height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: overallScore / 100,
                  strokeWidth: 9,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${overallScore.toInt()}',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: scoreColor)),
                Text('/100',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]))
              ])
            ])),
        const SizedBox(width: 20),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Skor Keseluruhan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
          const SizedBox(height: 6),
          Text(_getScoreFeedbackMessage(overallScore),
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[600], height: 1.4)),
        ])),
      ]);
    });
  }

  String _getScoreFeedbackMessage(double score) {
    if (score >= 85)
      return "Luar biasa! Performa Anda sangat baik dan menunjukkan pemahaman yang mendalam.";
    if (score >= 70)
      return "Bagus! Anda menunjukkan kemampuan yang solid dengan beberapa area kecil untuk ditingkatkan.";
    if (score >= 50)
      return "Cukup baik. Perhatikan feedback untuk pengembangan lebih lanjut.";
    return "Jangan menyerah! Terus berlatih dan perhatikan saran untuk peningkatan signifikan.";
  }

  Widget _buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: const Color(0xFF3A86FF))),
      const SizedBox(width: 14),
      Text(label,
          style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[850])),
    ]);
  }

  Widget _buildFeedbackSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Row(children: [
            Icon(LucideIcons.edit3, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text('Saran & Peningkatan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850]))
          ])),
      Obx(() {
        final feedbackList =
            controller.evaluationResults['feedback'] as List<dynamic>? ?? [];
        if (feedbackList.isEmpty) {
          return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text("Tidak ada saran spesifik saat ini. Kerja bagus!",
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontStyle: FontStyle.italic))));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) =>
              _buildFeedbackItem(feedbackList[index].toString()),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        );
      }),
    ]);
  }

  Widget _buildFeedbackItem(String feedback) {
    IconData feedbackIcon = LucideIcons.info;
    Color iconColor = const Color(0xFF3A86FF);
    if (feedback.toLowerCase().contains("baik") ||
        feedback.toLowerCase().contains("bagus") ||
        feedback.toLowerCase().contains("efektif") ||
        feedback.toLowerCase().contains("minimal")) {
      feedbackIcon = LucideIcons.checkCircle2;
      iconColor = Colors.green.shade600;
    } else if (feedback.toLowerCase().contains("perlu") ||
        feedback.toLowerCase().contains("kurang") ||
        feedback.toLowerCase().contains("hindari") ||
        feedback.toLowerCase().contains("cobalah") ||
        feedback.toLowerCase().contains("cukup banyak")) {
      feedbackIcon = LucideIcons.alertTriangle;
      iconColor = Colors.orange.shade700;
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: iconColor.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2))
            ]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(feedbackIcon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
              child: Text(feedback,
                  style: TextStyle(
                      fontSize: 14.5, height: 1.5, color: Colors.grey[800]))),
        ]));
  }

  Widget _buildProgressChart() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Row(children: [
            Icon(LucideIcons.trendingUp, color: Colors.teal[600], size: 20),
            const SizedBox(width: 8),
            Text('Riwayat Latihan Anda',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850]))
          ])),
      Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.withOpacity(0.3))),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(LucideIcons.barChartHorizontalBig,
                    size: 48, color: Colors.teal[600]),
                const SizedBox(height: 16),
                Text(
                    'Grafik perkembangan skor Anda akan ditampilkan di sini setelah Anda menyelesaikan beberapa sesi latihan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: Colors.teal[800], height: 1.4)),
              ])))
    ]);
  }

  Widget _buildActionButtons() {
    return Column(children: [
      SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.rotateCw,
                  size: 20, color: Colors.white),
              label: const Text('Ulangi Level Ini',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              onPressed: () =>
                  controller.restartInterview(resetKategoriDanItem: false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A86FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: const Color(0xFF3A86FF).withOpacity(0.3)))),
      const SizedBox(height: 16),
      SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              icon: const Icon(LucideIcons.listChecks,
                  size: 20, color: Color(0xFF3A86FF)),
              label: const Text('Pilih Latihan Lain',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A86FF))),
              onPressed: () => Get.offAllNamed(Routes.LATIHAN),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF3A86FF), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))))),
    ]);
  }
}
