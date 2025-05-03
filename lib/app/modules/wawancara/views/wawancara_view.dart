import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/wawancara_controller.dart';

class WawancaraView extends GetView<WawancaraController> {
  const WawancaraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.showEvaluation.value) {
          return _buildEvaluationView();
        } else if (controller.isRecording.value) {
          return _buildRecordingView();
        } else if (!controller.showScript.value) {
          return _buildCountdownView();
        } else {
          return _buildScriptView();
        }
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Obx(() => Text(
            controller.showEvaluation.value
                ? 'Hasil Evaluasi'
                : 'Level ${controller.getDifficultyLabel()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          )),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft,
            size: 24, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (controller.showEvaluation.value)
          IconButton(
            icon: const Icon(LucideIcons.share2,
                size: 20, color: Color(0xFF3A86FF)),
            onPressed: controller.shareResults,
          ),
      ],
    );
  }

  Widget _buildScriptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildProgressHeader(),
          const SizedBox(height: 24),
          _buildQuestionCard(),
          const SizedBox(height: 32),
          _buildStartButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pertanyaan ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (controller.currentQuestionIndex.value + 1) /
                controller.questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
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
                  LucideIcons.fileText,
                  size: 20,
                  color: Color(0xFF3A86FF),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Script Wawancara',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            controller.currentQuestion,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildInstructionItem(
              LucideIcons.eye, 'Ekspresi wajah akan dianalisis'),
          _buildInstructionItem(LucideIcons.mic, 'Kualitas suara akan dinilai'),
          _buildInstructionItem(
              LucideIcons.clock, 'Waktu respon akan dihitung'),
          const SizedBox(height: 8),
          Text(
            'Setiap kalimat akan ditampilkan selama ${controller.displayDuration} detik',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3A86FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
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
            onPressed: controller.startCountdown,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.radio, size: 20, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Mulai Rekam Jawaban',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Anda akan memiliki waktu ${controller.displayDuration} detik untuk menjawab',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownView() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Persiapkan Jawaban Anda',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latihan akan dimulai dalam',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Obx(() => Text(
                controller.countdownValue.value.toString(),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A86FF),
                ),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.lightbulb,
                    size: 20, color: Color(0xFF3A86FF)),
                const SizedBox(height: 8),
                Text(
                  'Tips: ${controller.getRandomTip()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingView() {
    return Column(
      children: [
        // Camera Preview (60% of screen)
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              // Camera preview
              Obx(() {
                if (controller.isCameraInitialized.value &&
                    controller.cameraController!.value.isInitialized) {
                  return Transform.scale(
                    scaleX: -1, // Mirror effect for front camera
                    child: CameraPreview(controller.cameraController!),
                  );
                } else {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              }),

              // Recording indicator
              Positioned(
                top: MediaQuery.of(Get.context!).padding.top + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRecordingIndicator(),
                        SizedBox(width: 8),
                        Text(
                          'SEDANG MEREKAM',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Auto-stop mechanism
              Obx(() {
                if (controller.recordingDuration.value >= 20) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.stopRecording();
                  });
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),

        // Analysis Card (40% of screen)
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis Realtime',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),

                // Expression Analysis
                _buildAnalysisRow(
                  icon: LucideIcons.smile,
                  title: 'Ekspresi',
                  value: 'Netral',
                  color: Colors.blue,
                ),

                // Gesture Analysis
                _buildAnalysisRow(
                  icon: LucideIcons.hand,
                  title: 'Gesture',
                  value: 'Stabil',
                  color: Colors.green,
                ),

                // Filler Words
                _buildAnalysisRow(
                  icon: LucideIcons.messageSquare,
                  title: 'Filler Words',
                  value: '3x (umm, ehh)',
                  color: Colors.orange,
                ),

                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.7, // Example progress
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
                ),
                SizedBox(height: 8),
                Text(
                  'Kepercayaan diri: 70%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.red[400],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildEvaluationHeader(),
          const SizedBox(height: 32),
          _buildScoreCard(),
          const SizedBox(height: 32),
          _buildFeedbackSection(),
          const SizedBox(height: 32),
          _buildProgressChart(),
          const SizedBox(height: 40),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEvaluationHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF3A86FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.badgeCheck,
            size: 40,
            color: Color(0xFF3A86FF),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Latihan Selesai!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Level ${controller.getDifficultyLabel()}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(
        children: [
          _buildScoreRow(),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _buildStatItem(
            icon: LucideIcons.clock,
            label: 'Waktu Respon',
            value: controller.evaluationResults['response_time'] ?? '-',
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: LucideIcons.smile,
            label: 'Ekspresi Wajah',
            value: controller.evaluationResults['expression_score'] ?? '-',
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: LucideIcons.volume2,
            label: 'Kejelasan Ucapan',
            value: controller.evaluationResults['clarity_score'] ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3A86FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.award,
            size: 24,
            color: Color(0xFF3A86FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skor Keseluruhan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.evaluationResults['overall_score'] ?? 0}/100',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A86FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3A86FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF3A86FF)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A86FF),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Feedback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...(controller.evaluationResults['feedback'] as List<dynamic>? ?? [])
            .map((feedback) => _buildFeedbackItem(feedback.toString()))
            .toList(),
      ],
    );
  }

  Widget _buildFeedbackItem(String feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF3A86FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.messageSquare,
              size: 14,
              color: Color(0xFF3A86FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Perkembangan Anda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E9F0)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.trendingUp,
                  size: 48,
                  color: Color(0xFF3A86FF),
                ),
                const SizedBox(height: 16),
                Text(
                  'Grafik perkembangan akan muncul setelah beberapa latihan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.restartInterview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.rotateCw, size: 20, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Ulangi Latihan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF3A86FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kembali ke Menu Utama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A86FF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
