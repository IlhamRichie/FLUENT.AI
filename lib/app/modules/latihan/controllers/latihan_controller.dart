import 'package:get/get.dart';
import 'package:fluent_ai/app/data/services/latihan_service.dart';

class LatihanController extends GetxController {
  final LatihanService _latihanService = Get.find();
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> kategoriLatihan = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> latihanTerbaru = <Map<String, dynamic>>[].obs;
  final RxString selectedCategory = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _latihanService.getLatihanKategori(),
        _latihanService.getLatihanTerbaru(),
      ]);
      
      kategoriLatihan.assignAll(results[0]);
      latihanTerbaru.assignAll(results[1]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data latihan');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void startLatihan(Map<String, dynamic> latihan) {
    Get.toNamed('/latihan', arguments: latihan);
  }

  void refreshData() async {
    await loadData();
  }
}