import 'package:camera/camera.dart';
import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart'; // Sesuaikan path
import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';   // Sesuaikan path
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math'; // Untuk Random

// Jika Anda menggunakan permission_handler, uncomment:
// import 'package:permission_handler/permission_handler.dart';

class WawancaraController extends GetxController {
  // Kamera
  CameraController? cameraController;
  var isCameraInitialized = false.obs;

  // State untuk argumen dari halaman latihan
  var selectedKategoriFromLatihan = Rxn<KategoriLatihanModel>();
  var selectedLatihanItemFromLatihan = Rxn<LatihanItemModel>();

  // State utama alur wawancara
  var difficultyLevel = 0.obs; // 0: Pemula, 1: Menengah, 2: Mahir
  var currentQuestionIndex = 0.obs;
  var isRecording = false.obs;
  var showEvaluation = false.obs;
  var showScript = true.obs;

  // Countdown
  final int initialCountdownValue = 3;
  var countdownValue = 3.obs;

  // Durasi
  var recordingDuration = 0.obs;
  var displayDuration = 30.obs; // Durasi default, bisa diubah berdasarkan level/kategori

  // Feedback Realtime (Simulasi)
  var currentExpressionFeedback = "Netral".obs;
  var currentClarityFeedback = "Cukup Jelas".obs;
  var fillerWordCount = 0.obs;
  var confidenceLevel = 70.0.obs;
  var showRecordingDot = false.obs;

  // Tip Saat Ini
  var currentTip = "Persiapkan diri Anda dengan baik!".obs; // Variabel observable untuk tip

  // Hasil Evaluasi
  var evaluationResults = <String, dynamic>{}.obs;

  // Timers
  Timer? _recordingTimer;
  Timer? _countdownTimer;
  Timer? _realtimeFeedbackTimer;
  Timer? _blinkingDotTimer;

  // Instance Random
  final Random _random = Random();

  // Daftar pertanyaan
  List<String> get questions {
    String kategoriNama = "";
    if (selectedKategoriFromLatihan.value != null) {
      kategoriNama = selectedKategoriFromLatihan.value!.nama;
    } else if (selectedLatihanItemFromLatihan.value != null) {
      kategoriNama = selectedLatihanItemFromLatihan.value!.kategori;
    }

    if (kategoriNama.toLowerCase().contains('wawancara')) {
      switch (difficultyLevel.value) {
        case 1: return [ "Pengalaman kerja terbaru Anda yang relevan?", "Tantangan terbesar dalam tim?", "Bagaimana Anda menangani kritik?", "Target karir 3 tahun ke depan?", "Mengapa kami harus memilih Anda?"];
        case 2: return [ "Inisiatif Anda dalam masalah kompleks?", "Prioritas tugas & deadline ketat?", "Kontribusi spesifik pada tim sebelumnya?", "Strategi pengembangan diri Anda?", "Hal yang ingin Anda ubah dari pengalaman lalu?"];
        default: return ["Ceritakan tentang diri Anda.", "Kelebihan utama Anda?", "Kekurangan Anda & solusinya?", "Minat Anda pada posisi & perusahaan ini?", "Apa yang Anda ketahui tentang kami?"];
      }
    }
    return ["Perkenalkan diri & latar belakang.", "Motivasi karir terbesar Anda?", "Ada pertanyaan untuk kami?"];
  }

  RxString get currentQuestion => (questions.isNotEmpty && currentQuestionIndex.value < questions.length
          ? questions[currentQuestionIndex.value]
          : 'Pertanyaan tidak tersedia atau latihan selesai.')
      .obs;

  final List<String> tips = [
    "Jaga kontak mata dengan kamera, seolah berbicara dengan pewawancara.",
    "Bicaralah dengan jelas, tempo yang terkontrol, dan volume yang cukup.",
    "Gunakan gestur tangan yang alami untuk mendukung poin Anda.",
    "Senyum menunjukkan antusiasme dan keramahan.",
    "Atur napas Anda agar tetap tenang dan terkontrol.",
    "Dengarkan atau baca pertanyaan dengan seksama sebelum menjawab.",
    "Struktur jawaban Anda, misalnya menggunakan metode STAR (Situation, Task, Action, Result).",
    "Berikan contoh konkret dari pengalaman Anda.",
    "Tunjukkan kepercayaan diri melalui postur tubuh yang tegap.",
    "Hindari kata-kata pengisi seperti 'umm', 'eee', 'anu' secara berlebihan."
  ];

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    initCamera();
    _updateCurrentTip(); // Set tip awal
  }

  void _parseArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      if (arguments.containsKey('kategori')) {
        selectedKategoriFromLatihan.value = arguments['kategori'] as KategoriLatihanModel?;
        printInfo(info: 'Kategori diterima: ${selectedKategoriFromLatihan.value?.nama}');
      } else if (arguments.containsKey('latihanItem')) {
        selectedLatihanItemFromLatihan.value = arguments['latihanItem'] as LatihanItemModel?;
        printInfo(info: 'Item Latihan diterima: ${selectedLatihanItemFromLatihan.value?.judul}');
        // Contoh: Set difficulty level berdasarkan item jika ada
        // String? itemLevel = selectedLatihanItemFromLatihan.value?.level;
        // if (itemLevel != null) difficultyLevel.value = _parseLevelFromString(itemLevel);
      }
    }
  }

  // int _parseLevelFromString(String? levelString) {
  //   if (levelString == null) return 0; // Default Pemula
  //   if (levelString.toLowerCase() == "menengah") return 1;
  //   if (levelString.toLowerCase() == "mahir") return 2;
  //   return 0;
  // }

  @override
  void onClose() {
    _disposeTimers();
    cameraController?.dispose();
    super.onClose();
  }

  void _disposeTimers() {
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    _realtimeFeedbackTimer?.cancel();
    _blinkingDotTimer?.cancel();
  }

  Future<void> initCamera() async {
    try {
      // Uncomment jika menggunakan permission_handler
      // final cameraStatus = await Permission.camera.request();
      // final micStatus = await Permission.microphone.request();
      // if (!cameraStatus.isGranted || !micStatus.isGranted) {
      //   Get.snackbar('Izin Diperlukan', 'Izin kamera dan mikrofon diperlukan.');
      //   isCameraInitialized.value = false;
      //   return;
      // }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('Error Kamera', 'Tidak ada kamera yang tersedia.');
        isCameraInitialized.value = false;
        return;
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      cameraController = CameraController(frontCamera, ResolutionPreset.high, enableAudio: true, imageFormatGroup: ImageFormatGroup.yuv420);
      await cameraController!.initialize();
      isCameraInitialized.value = true;
      printInfo(info: "Kamera berhasil diinisialisasi");
    } catch (e) {
      Get.snackbar('Error Inisialisasi Kamera', 'Gagal: $e');
      printError(info: 'Error initCamera: $e');
      isCameraInitialized.value = false;
    }
  }

  String getDifficultyLabel() {
    switch (difficultyLevel.value) {
      case 1: return "Menengah";
      case 2: return "Mahir";
      default: return "Pemula";
    }
  }

  void _updateCurrentTip() {
    if (tips.isNotEmpty) {
      currentTip.value = tips[_random.nextInt(tips.length)];
    } else {
      currentTip.value = "Fokus dan berikan yang terbaik!";
    }
  }

  // Fungsi ini tidak lagi dipanggil oleh Obx secara langsung,
  // tapi digunakan oleh _updateCurrentTip
  String getRandomTipForDisplay() {
    if (tips.isEmpty) return "Semoga berhasil dalam latihan Anda!";
    return tips[_random.nextInt(tips.length)];
  }


  void startCountdown() {
    if (questions.isEmpty || currentQuestionIndex.value >= questions.length) {
      Get.snackbar("Selesai", "Semua pertanyaan untuk level ini telah dijawab.", snackPosition: SnackPosition.BOTTOM);
      showScript.value = true;
      return;
    }
    showScript.value = false;
    countdownValue.value = initialCountdownValue;
    _updateCurrentTip(); // Update tip setiap countdown dimulai

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue.value > 0) {
        countdownValue.value--;
      } else {
        timer.cancel();
        startRecording();
      }
    });
  }

  Future<void> startRecording() async {
    if (!isCameraInitialized.value || cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('Kamera Belum Siap', 'Mohon tunggu kamera selesai diinisialisasi.', snackPosition: SnackPosition.BOTTOM);
      showScript.value = true;
      return;
    }
    if (cameraController!.value.isRecordingVideo) {
      await cameraController!.stopVideoRecording(); // Hentikan jika sudah merekam
    }
    try {
      await cameraController!.startVideoRecording();
      isRecording.value = true;
      recordingDuration.value = 0;
      fillerWordCount.value = 0;
      confidenceLevel.value = 70.0;
      currentExpressionFeedback.value = "Netral";
      currentClarityFeedback.value = "Cukup Jelas";

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration.value++;
        if (recordingDuration.value >= displayDuration.value) {
          stopRecording();
        }
      });

      _blinkingDotTimer?.cancel();
      _blinkingDotTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
        if (!isRecording.value) {timer.cancel(); showRecordingDot.value = false; return;}
        showRecordingDot.value = !showRecordingDot.value;
      });
      _startRealtimeFeedbackSimulation();
    } catch (e) {
      Get.snackbar('Error Merekam', 'Gagal memulai rekaman: $e', snackPosition: SnackPosition.BOTTOM);
      isRecording.value = false;
      showScript.value = true;
    }
  }

  void _startRealtimeFeedbackSimulation() {
    _realtimeFeedbackTimer?.cancel();
    _realtimeFeedbackTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isRecording.value) {timer.cancel(); return;}
      final expressions = ["Netral", "Sedikit Tersenyum", "Fokus", "Antusias", "Terlalu Serius"];
      currentExpressionFeedback.value = expressions[_random.nextInt(expressions.length)];
      final clarities = ["Sangat Jelas", "Cukup Jelas", "Agak Cepat", "Kurang Intonasi", "Terlalu Pelan"];
      currentClarityFeedback.value = clarities[_random.nextInt(clarities.length)];
      if (_random.nextDouble() < 0.2) {fillerWordCount.value++;}
      confidenceLevel.value = (60 + _random.nextInt(36)).toDouble().clamp(0.0, 100.0);
    });
  }

  Future<void> stopRecording() async {
    if (!isRecording.value || cameraController == null || !cameraController!.value.isRecordingVideo) {
      if (!showEvaluation.value && questions.isNotEmpty) {evaluateAnswer();}
      return;
    }
    _disposeTimers();
    showRecordingDot.value = false;
    try {
      final XFile videoFile = await cameraController!.stopVideoRecording();
      printInfo(info: 'Video direkam di: ${videoFile.path}');
      // TODO: Kirim videoFile.path ke backend
    } catch (e) {
      Get.snackbar('Error Menghentikan Rekaman', 'Gagal: $e', snackPosition: SnackPosition.BOTTOM);
      printError(info: 'Error stopVideoRecording: $e');
    } finally {
      isRecording.value = false;
      evaluateAnswer();
    }
  }

  void stopRecordingAndReset() async {
    _disposeTimers();
    showRecordingDot.value = false;
    try {
      if (cameraController != null && cameraController!.value.isRecordingVideo) {
        await cameraController!.stopVideoRecording();
        printInfo(info: 'Rekaman dihentikan karena pengguna keluar sesi.');
      }
    } catch (e) {
      printError(info: 'Error menghentikan rekaman saat keluar sesi: $e');
    } finally {
      isRecording.value = false;
      restartInterview(resetKategoriDanItem: true);
    }
  }

  void evaluateAnswer() {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF3A86FF))), barrierDismissible: false);
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Tutup dialog loading
      if (currentQuestionIndex.value < questions.length - 1) {
        currentQuestionIndex.value++;
        showScript.value = true;
        recordingDuration.value = 0;
      } else {
        evaluateInterview();
      }
    });
  }

  void evaluateInterview() {
    int baseScore = 55;
    if (difficultyLevel.value == 1) baseScore = 65;
    if (difficultyLevel.value == 2) baseScore = 70;

    final List<String> feedbackMessages = [];
    if (confidenceLevel.value < 70) feedbackMessages.add('Tingkatkan kepercayaan diri Anda. Cobalah untuk lebih rileks dan tatap kamera.');
    else feedbackMessages.add('Kepercayaan diri Anda sudah cukup baik, pertahankan!');
    if (fillerWordCount.value > (questions.length * 0.8)) feedbackMessages.add('Anda menggunakan cukup banyak kata pengisi. Latih untuk menguranginya.');
    else if (fillerWordCount.value > (questions.length * 0.4)) feedbackMessages.add('Penggunaan kata pengisi masih bisa dikurangi untuk penyampaian yang lebih lancar.');
    else feedbackMessages.add('Penggunaan kata pengisi Anda minimal, sangat bagus!');
    final otherFeedbacks = ["Pastikan intonasi suara Anda bervariasi.", "Kontak mata dengan kamera sudah baik.", "Cobalah memberikan jawaban yang lebih terstruktur.", "Penggunaan gestur tangan Anda efektif.", "Penampilan Anda menunjukkan persiapan yang baik."];
    feedbackMessages.add(otherFeedbacks[_random.nextInt(otherFeedbacks.length)]);

    evaluationResults.value = {
      'overall_score': (baseScore + _random.nextInt(15) + (confidenceLevel.value / 15) - (fillerWordCount.value / (questions.length.isFinite && questions.isNotEmpty ? questions.length : 1) )).clamp(40,98).toInt(),
      'response_time': '${(2.0 + difficultyLevel.value + _random.nextDouble() * 1.5).toStringAsFixed(1)} detik/pertanyaan',
      'expression_score': '${(55 + _random.nextInt(36) + (difficultyLevel.value * 3)).clamp(50,95)}/100',
      'clarity_score': '${(60 + _random.nextInt(31) + (difficultyLevel.value * 4)).clamp(55,96)}/100',
      'filler_words': fillerWordCount.value,
      'feedback': feedbackMessages,
    };
    showEvaluation.value = true;
    showScript.value = false;
    isRecording.value = false;
  }

  void restartInterview({bool resetKategoriDanItem = false}) {
    _disposeTimers();
    currentQuestionIndex.value = 0;
    isRecording.value = false;
    showEvaluation.value = false;
    showScript.value = true;
    evaluationResults.clear();
    recordingDuration.value = 0;
    fillerWordCount.value = 0;
    confidenceLevel.value = 70.0;
    showRecordingDot.value = false;
    _updateCurrentTip(); // Reset tip juga

    if (resetKategoriDanItem) {
      selectedKategoriFromLatihan.value = null;
      selectedLatihanItemFromLatihan.value = null;
      // difficultyLevel.value = 0; // Reset level jika perlu
    }
    update();
  }

  void shareResults() {
    String resultText = "Hasil Latihan Wawancara FLUENT AI:\n";
    resultText += "Level: ${getDifficultyLabel()}\n";
    resultText += "Skor Keseluruhan: ${evaluationResults['overall_score'] ?? 'N/A'}/100\n";
    if (evaluationResults['feedback'] != null && (evaluationResults['feedback'] as List).isNotEmpty) {
       resultText += "Feedback Utama: ${(evaluationResults['feedback'] as List).first}\n";
    }
    resultText += "\nYuk, coba juga aplikasi FLUENT AI!";
    Get.snackbar('Berbagi Hasil', 'Fitur berbagi hasil akan segera diimplementasikan.', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF3A86FF), colorText: Colors.white);
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color getExpressionColor() {
    if (currentExpressionFeedback.value.contains("Antusias") || currentExpressionFeedback.value.contains("Senyum")) return Colors.green.shade600;
    if (currentExpressionFeedback.value.contains("Netral") || currentExpressionFeedback.value.contains("Fokus")) return Colors.blue.shade600;
    return Colors.orange.shade700;
  }
  Color getClarityColor() {
    if (currentClarityFeedback.value.contains("Jelas")) return Colors.green.shade600;
    if (currentClarityFeedback.value.contains("Cukup")) return Colors.blue.shade600;
    return Colors.orange.shade700;
  }
  Color getFillerWordColor() {
    int questionCount = questions.length.isFinite && questions.isNotEmpty ? questions.length : 1;
    if (fillerWordCount.value <= (questionCount * 0.2).floor()) return Colors.green.shade600;
    if (fillerWordCount.value <= (questionCount * 0.5).floor()) return Colors.blue.shade600;
    return Colors.orange.shade700;
  }
   Color getConfidenceColor() {
    if (confidenceLevel.value >= 80) return Colors.green.shade600;
    if (confidenceLevel.value >= 65) return Colors.blue.shade600;
    return Colors.orange.shade700;
  }
}