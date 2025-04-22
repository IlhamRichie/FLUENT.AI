import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/latihan_service.dart';

class LatihanDetailController extends GetxController {
  final LatihanService _latihanService = Get.find();
  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> latihanDetail = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadLatihanDetail();
  }

  Future<void> loadLatihanDetail() async {
    try {
      isLoading.value = true;
      // Get arguments passed from navigation
      final arguments = Get.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        // Simulate loading detail data
        await Future.delayed(const Duration(seconds: 1));
        latihanDetail.value = {
          ...arguments,
          'deskripsi_lengkap': 'Ini adalah deskripsi lengkap untuk latihan ${arguments['nama'] ?? arguments['judul']}',
          'durasi': '15-30 menit',
          'kesulitan': arguments['level'] ?? 'Medium',
          'instruksi': [
            'Persiapkan diri Anda dengan baik',
            'Pastikan lingkungan tenang',
            'Gunakan headphone untuk hasil terbaik',
            'Bicara dengan jelas dan percaya diri'
          ],
          'contoh_pertanyaan': [
            'Ceritakan tentang diri Anda',
            'Apa kelebihan utama Anda?',
            'Bagaimana Anda menghadapi tantangan?'
          ],
        };
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail latihan');
    } finally {
      isLoading.value = false;
    }
  }

  void mulaiLatihan() {
    Get.snackbar('Mulai Latihan', 'Memulai latihan ${latihanDetail['nama'] ?? latihanDetail['judul']}');
    // Add your logic to start the practice session
  }
}