import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class WawancaraController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;

  // Difficulty levels: 0 = Pemula, 1 = Menengah, 2 = Mahir
  var difficultyLevel = 0.obs;
  var currentQuestionIndex = 0.obs;
  var isRecording = false.obs;
  var showEvaluation = false.obs;
  var showScript = true.obs;
  var countdownValue = 3.obs;
  var recordingDuration = 0.obs;
  var displayDuration = 30.obs;
  var currentExpressionFeedback = "".obs;
  var evaluationResults = <String, dynamic>{}.obs;
  Timer? _recordingTimer;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras(); // Dapatkan daftar kamera
    
    // Cari kamera depan (lensDirection.front)
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras[0], // Fallback ke kamera belakang jika tidak ada depan
    );

    cameraController = CameraController(
      frontCamera, // Gunakan kamera depan
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menginisialisasi kamera: $e');
    }
  }

  // List of tips for countdown view
  final List<String> tips = [
    "Jaga kontak mata dengan kamera",
    "Bicaralah dengan jelas dan percaya diri",
    "Gunakan gestur tangan yang alami",
    "Senyum membantu membuat kesan baik",
    "Atur napas sebelum mulai berbicara"
  ];

  List<String> get questions {
    switch (difficultyLevel.value) {
      case 1:
        return [
          "Ceritakan pengalaman kerja terbaru Anda...",
          "Apa tantangan terbesar yang pernah Anda hadapi?",
          "Bagaimana Anda menangani konflik di tempat kerja?"
        ];
      case 2:
        return [
          "Jelaskan situasi dimana Anda harus mengambil keputusan sulit",
          "Bagaimana Anda memprioritaskan pekerjaan ketika ada banyak deadline?",
          "Apa strategi Anda untuk bekerja dalam tim yang beragam?"
        ];
      default:
        return [
          "Ceritakan tentang diri Anda",
          "Apa kelebihan dan kekurangan Anda?",
          "Mengapa Anda tertarik dengan posisi ini?"
        ];
    }
  }

  String get currentQuestion {
    return questions.isNotEmpty && currentQuestionIndex.value < questions.length
        ? questions[currentQuestionIndex.value]
        : 'No question available';
  }

  String getDifficultyLabel() {
    switch (difficultyLevel.value) {
      case 1:
        return "Menengah";
      case 2:
        return "Mahir";
      default:
        return "Pemula";
    }
  }

  String getRandomTip() {
    return tips[(DateTime.now().millisecondsSinceEpoch % tips.length).toInt()];
  }

  void startCountdown() {
    showScript.value = false;
    countdownValue.value = 3;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownValue.value--;
      if (countdownValue.value <= 0) {
        timer.cancel();
        startRecording();
      }
    });
  }

  void startRecording() {
    isRecording.value = true;
    recordingDuration.value = 0;
    currentExpressionFeedback.value = "Ekspresi: Netral";

    // Simulate expression changes
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final expressions = ["Baik", "Netral", "Kurang antusias"];
      currentExpressionFeedback.value =
          "Ekspresi: ${expressions[(DateTime.now().second % expressions.length)]}";
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value++;
    });
  }

  void stopRecording() {
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    isRecording.value = false;
    evaluateAnswer();
  }

  void evaluateAnswer() {
    // Simulate analysis time
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex.value < questions.length - 1) {
        currentQuestionIndex.value++;
        showScript.value = true;
      } else {
        evaluateInterview();
      }
    });
  }

  void evaluateInterview() {
    // Generate simulated evaluation results
    evaluationResults.value = {
      'overall_score': 70 + (difficultyLevel.value * 10),
      'response_time': '${2 + difficultyLevel.value}.5 detik',
      'expression_score': '${65 + (difficultyLevel.value * 10)}/100',
      'clarity_score': '${75 + (difficultyLevel.value * 5)}/100',
      'filler_words': 10 - difficultyLevel.value * 2,
      'feedback': [
        'Kontak mata ${difficultyLevel.value > 0 ? 'baik' : 'perlu diperbaiki'}',
        'Pengucapan ${difficultyLevel.value > 1 ? 'sangat jelas' : 'cukup jelas'}',
        'Gunakan lebih banyak contoh konkret',
        if (difficultyLevel.value < 2) 'Tingkatkan kepercayaan diri'
      ],
    };
    showEvaluation.value = true;
  }

  void restartInterview() {
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    currentQuestionIndex.value = 0;
    isRecording.value = false;
    showEvaluation.value = false;
    showScript.value = true;
    evaluationResults.clear();
  }

  void shareResults() {
    // Simulate share functionality
    Get.snackbar(
      'Berhasil',
      'Hasil latihan telah dibagikan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    cameraController?.dispose();
    super.onClose();
  }
}
