import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';
import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluent_ai/app/routes/app_pages.dart'; // Untuk navigasi kembali
// import 'package:camera/camera.dart'; // Jika Anda akan menggunakan analisis ekspresi user

// Enum untuk merepresentasikan mood AI HRD
enum HrdMood { neutral, listening, thinking, positive, concerned, confused }

class VirtualhrdController extends GetxController {
  // Data dari Intro
  final Rx<KategoriLatihanModel?> selectedKategori =
      Rx<KategoriLatihanModel?>(null);
  final Rx<LatihanItemModel?> selectedLatihanItem = Rx<LatihanItemModel?>(null);
  final Rx<Color> hrdColor = Rx<Color>(const Color(0xFF9B59B6)); // Default

  // State Sesi
  final RxString currentQuestion = "Memuat pertanyaan dari Virtual HRD...".obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxList<Map<String, String>> sessionLog =
      <Map<String, String>>[].obs; // Untuk menyimpan Q&A
  final RxString userAnswerText = "".obs;
  final RxString aiFeedbackText = "".obs; // Teks feedback dari AI

  // State UI & Proses
  final RxBool isListening = false.obs;
  final RxBool isLoadingQuestion = true.obs;
  final RxBool showEvaluation = false.obs;
  final RxMap<String, dynamic> evaluationResults = <String, dynamic>{}.obs;
  final Rx<HrdMood> currentHrdMood = HrdMood.neutral.obs;

  // Speech to Text
  late stt.SpeechToText _speech;
  final RxString recognizedWords = "".obs;
  // final RxDouble confidence = 0.0.obs; // Bisa digunakan untuk analisis lebih lanjut

  // Kamera & Analisis Ekspresi (Opsional, perlu setup lebih lanjut)
  // final RxBool isCameraInitialized = false.obs;
  // CameraController? cameraController;
  // List<CameraDescription>? cameras;
  // final RxString userExpression = "Netral".obs; // Hasil analisis ekspresi user

  final List<String> dummyHrdQuestions = [
    "Selamat pagi/siang/sore! Bisa ceritakan sedikit tentang diri Anda dan latar belakang Anda?",
    "Apa yang membuat Anda tertarik dengan simulasi Virtual HRD ini?",
    "Menurut Anda, apa kualitas terpenting yang harus dimiliki seorang profesional di bidang Anda?",
    "Bagaimana Anda biasanya menghadapi tantangan atau situasi sulit dalam pekerjaan?",
    "Apakah ada pertanyaan yang ingin Anda ajukan kepada saya sebagai Virtual HRD?",
    "Terima kasih atas partisipasinya. Sesi ini akan segera berakhir."
  ];

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    // _initializeCamera(); // Aktifkan jika menggunakan kamera

    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      if (arguments.containsKey('kategori')) {
        selectedKategori.value = arguments['kategori'] as KategoriLatihanModel;
        hrdColor.value = _parseColor(selectedKategori.value!.warna);
      } else if (arguments.containsKey('latihanItem')) {
        selectedLatihanItem.value =
            arguments['latihanItem'] as LatihanItemModel;
        hrdColor.value = _parseColor(selectedLatihanItem.value!.warna);
        // Anda bisa mengambil nama kategori dari latihanItem jika perlu
      }
    }
    fetchNextHrdQuestion();
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF9B59B6);
    }
  }

  Future<void> fetchNextHrdQuestion() async {
    isLoadingQuestion.value = true;
    userAnswerText.value = "";
    aiFeedbackText.value = "";
    recognizedWords.value = "";
    currentHrdMood.value = HrdMood.neutral; // Kembali ke mood netral

    await Future.delayed(
        const Duration(milliseconds: 1200)); // Simulasi AI berpikir
    if (currentQuestionIndex.value < dummyHrdQuestions.length) {
      currentQuestion.value = dummyHrdQuestions[currentQuestionIndex.value];
    } else {
      currentQuestion.value =
          "Sesi telah selesai. Terima kasih atas partisipasi Anda!";
      await _generateFinalEvaluation();
      showEvaluation.value = true;
      currentHrdMood.value = HrdMood.positive;
    }
    isLoadingQuestion.value = false;
  }

  // Method untuk menangani permintaan keluar
  Future<bool> confirmExitSession() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Sesi?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Progres sesi Virtual HRD akan hilang. Yakin ingin keluar?'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), // Kirim false jika batal
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Lakukan pembersihan state sesi jika diperlukan sebelum keluar
              // Misalnya, stop speech recognition, dispose camera, dll.
              // onClose(); // Hati-hati memanggil onClose secara manual, biasanya GetX yang handle
              _speech.stop(); // Contoh: stop speech recognition
              Get.back(result: true); // Kirim true jika konfirmasi keluar
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child:
                const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return confirm ??
        false; // Kembalikan hasil dialog, default false jika dialog di-dismiss
  }

  void listen() async {
    if (!isListening.value) {
      bool available = await _speech.initialize(onStatus: (val) {
        debugPrint('Speech status: $val');
        if (val == 'notListening' || val == 'done') {
          isListening.value = false;
          currentHrdMood.value =
              HrdMood.thinking; // AI berpikir setelah user selesai
          if (recognizedWords.value.isNotEmpty) {
            // Proses jika ada hasil
            userAnswerText.value = recognizedWords.value;
            getAiFeedbackForAnswer(userAnswerText.value);
          } else if (_speech.lastStatus == 'done' &&
              recognizedWords.value.isEmpty) {
            // Jika selesai tapi tidak ada kata, mungkin user tidak bicara
            userAnswerText.value = "(Tidak ada jawaban terdeteksi)";
            aiFeedbackText.value =
                "Sepertinya Anda tidak mengatakan apapun. Bisa diulangi?";
            currentHrdMood.value = HrdMood.confused;
          }
        }
      }, onError: (val) {
        debugPrint('Speech error: $val');
        isListening.value = false;
        currentHrdMood.value = HrdMood.neutral;
        Get.snackbar(
            "Error Suara", "Gagal mengaktifkan layanan suara: ${val.errorMsg}",
            snackPosition: SnackPosition.BOTTOM);
      });
      if (available) {
        isListening.value = true;
        recognizedWords.value = "";
        currentHrdMood.value = HrdMood.listening; // AI mendengarkan
        _speech.listen(
          onResult: (val) => recognizedWords.value = val.recognizedWords,
          localeId: 'id_ID',
          listenFor: const Duration(
              seconds: 30), // Durasi maksimal mendengarkan per sesi
          pauseFor: const Duration(
              seconds: 3), // Jeda sebelum dianggap selesai bicara
          partialResults: true, // Tampilkan hasil sementara
        );
      } else {
        Get.snackbar("Layanan Suara", "Layanan suara tidak tersedia saat ini.",
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Tombol ditekan lagi untuk stop manual
      isListening.value = false;
      _speech.stop();
      // onStatus 'done' atau 'notListening' akan menangani sisanya
    }
  }

  void getAiFeedbackForAnswer(String answer) async {
    aiFeedbackText.value = "Hmm, saya sedang memproses jawaban Anda...";
    currentHrdMood.value = HrdMood.thinking;
    await Future.delayed(const Duration(seconds: 2)); // Simulasi analisis AI

    sessionLog.add({'question': currentQuestion.value, 'answer': answer});

    if (answer.toLowerCase().contains("motivasi") ||
        answer.toLowerCase().contains("semangat")) {
      aiFeedbackText.value =
          "Itu poin yang bagus! Menunjukkan antusiasme Anda.";
      currentHrdMood.value = HrdMood.positive;
    } else if (answer.length < 15 && answer.isNotEmpty) {
      aiFeedbackText.value =
          "Jawaban yang cukup singkat. Mungkin Anda bisa mengembangkannya lebih lanjut?";
      currentHrdMood.value = HrdMood.concerned;
    } else if (answer.isEmpty || answer == "(Tidak ada jawaban terdeteksi)") {
      aiFeedbackText.value =
          "Saya tidak mendengar jawaban Anda dengan jelas. Bisa diulangi?";
      currentHrdMood.value = HrdMood.confused;
    } else {
      aiFeedbackText.value = "Terima kasih atas jawabannya. Poin yang menarik.";
      currentHrdMood.value = HrdMood.neutral;
    }
  }

  void submitAnswerAndNext() {
    if (showEvaluation.value || isLoadingQuestion.value || isListening.value)
      return;

    // Jika user belum memberikan jawaban (misalnya langsung klik next)
    if (userAnswerText.value.isEmpty && recognizedWords.value.isEmpty) {
      userAnswerText.value = "(Tidak menjawab)";
      getAiFeedbackForAnswer(
          userAnswerText.value); // Beri feedback bahwa tidak menjawab
      // Pertimbangkan untuk tidak langsung next, tapi beri kesempatan user menjawab
      // Atau, jika memang boleh skip, baru next.
      // Untuk contoh ini, kita anggap boleh skip, tapi feedback diberikan.
    } else if (userAnswerText.value.isEmpty &&
        recognizedWords.value.isNotEmpty) {
      // Jika speech-to-text masih berjalan tapi belum final, ambil hasil sementara
      userAnswerText.value = recognizedWords.value;
      getAiFeedbackForAnswer(userAnswerText.value);
    }

    currentQuestionIndex.value++;
    fetchNextHrdQuestion();
  }

  Future<void> _generateFinalEvaluation() async {
    evaluationResults.value = {
      'total_questions_asked': dummyHrdQuestions.length,
      'questions_answered': sessionLog.length,
      'average_response_quality': 'Baik', // Dummy
      'key_takeaways': [
        'Menunjukkan pemahaman dasar terhadap pertanyaan HRD.',
        'Perlu lebih banyak detail dan contoh dalam jawaban.',
        'Penggunaan bahasa sudah cukup baik.'
      ],
      'overall_feedback':
          'Sesi yang cukup baik! Anda memiliki potensi besar. Terus berlatih untuk meningkatkan kedalaman jawaban dan kepercayaan diri Anda. Pertimbangkan untuk menggunakan metode STAR saat menjawab pertanyaan perilaku.'
    };
  }

  void restartSession() {
    currentQuestionIndex.value = 0;
    sessionLog.clear();
    showEvaluation.value = false;
    evaluationResults.clear();
    fetchNextHrdQuestion();
  }

  @override
  void onClose() {
    _speech.cancel(); // Atau _speech.stop();
    // cameraController?.dispose();
    super.onClose();
  }
}
