import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';
import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart';
import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart'; // Untuk helper
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/routes/app_pages.dart'; // Untuk Routes

class VirtualhrdIntroController extends GetxController {
  final Rx<KategoriLatihanModel?> selectedKategori = Rx<KategoriLatihanModel?>(null);
  final Rx<LatihanItemModel?> selectedLatihanItem = Rx<LatihanItemModel?>(null);

  final RxString title = 'Simulasi Virtual HRD'.obs;
  final RxString description = 'Latih kemampuan wawancara dan interaksi profesional Anda dengan simulasi HRD berbasis AI. Dapatkan feedback instan untuk meningkatkan performa Anda.'.obs;
  final Rx<Color> primaryColor = Rx<Color>(const Color(0xFF9B59B6)); // Warna default
  final RxString iconName = 'userCheck'.obs;

  final List<Map<String, dynamic>> features = [
    {'icon': Icons.question_answer_rounded, 'text': 'Pertanyaan Realistis & Adaptif'},
    {'icon': Icons.mic_rounded, 'text': 'Rekam & Analisis Jawaban Suara'},
    {'icon': Icons.insights_rounded, 'text': 'Feedback Performa Mendalam'},
    {'icon': Icons.psychology_alt_rounded, 'text': 'Simulasi Berbagai Skenario HRD'},
  ];

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      if (arguments.containsKey('kategori')) {
        selectedKategori.value = arguments['kategori'] as KategoriLatihanModel;
        title.value = selectedKategori.value!.nama;
        description.value = selectedKategori.value!.deskripsi;
        primaryColor.value = _parseColor(selectedKategori.value!.warna);
        iconName.value = selectedKategori.value!.ikon;
      } else if (arguments.containsKey('latihanItem')) {
        selectedLatihanItem.value = arguments['latihanItem'] as LatihanItemModel;
        title.value = "Lanjutkan: ${selectedLatihanItem.value!.judul}";
        description.value = "Lanjutkan sesi latihan Virtual HRD Anda untuk ${selectedLatihanItem.value!.judul}.";
        primaryColor.value = _parseColor(selectedLatihanItem.value!.warna);
        
        final latihanCtrl = Get.isRegistered<LatihanController>() ? Get.find<LatihanController>() : null;
        if (latihanCtrl != null) {
            final kategoriModel = latihanCtrl.semuaKategoriLatihan.firstWhereOrNull((k) => k.nama == selectedLatihanItem.value!.kategori);
            if (kategoriModel != null) {
                iconName.value = kategoriModel.ikon;
            }
        }
      }
    }
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

  void startVirtualHrdSession() {
    // Navigasi ke VirtualHrdView menggunakan Rute yang sudah didefinisikan
    // Kirim argumen yang sama agar VirtualHrdController bisa menggunakannya
    Get.toNamed(Routes.VIRTUALHRD, arguments: Get.arguments);
  }
}