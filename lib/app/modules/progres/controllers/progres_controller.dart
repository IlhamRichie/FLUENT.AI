// lib/app/modules/progres/controllers/progres_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Untuk IconData
import 'package:lucide_icons/lucide_icons.dart'; // Untuk IconData

class ProgresController extends GetxController {
  final isLoading = true.obs;
  final selectedTimeframe = 'Mingguan'.obs;
  final selectedChartData = 'Skor Rata-rata'.obs;

  // Dummy Data
  final timeframes = ['Mingguan', 'Bulanan', 'Tahunan'].obs;
  final chartDataOptions = ['Skor Rata-rata', 'Sesi Latihan', 'Waktu Latihan'].obs;
  
  final RxList<Map<String, dynamic>> currentProgressData = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> skillMetrics = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> improvementAreas = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> badges = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1800)); // Simulasi loading

    // Update data berdasarkan selectedTimeframe dan selectedChartData
    _updateChartData();
    _updateSkillMetrics();
    _updateImprovementAreas();
    _updateBadges();
    
    isLoading.value = false;
  }

  void _updateChartData() {
    // Logika untuk mengisi currentProgressData berdasarkan filter
    if (selectedChartData.value == 'Skor Rata-rata') {
      if (selectedTimeframe.value == 'Mingguan') {
        currentProgressData.assignAll([
          {'label': 'M1', 'value': 65.0}, {'label': 'M2', 'value': 70.0},
          {'label': 'M3', 'value': 68.0}, {'label': 'M4', 'value': 75.0},
        ]);
      } else if (selectedTimeframe.value == 'Bulanan') {
         currentProgressData.assignAll([
          {'label': 'Jan', 'value': 60.0}, {'label': 'Feb', 'value': 65.0},
          {'label': 'Mar', 'value': 72.0}, {'label': 'Apr', 'value': 70.0},
        ]);
      } else { // Tahunan
         currentProgressData.assignAll([
          {'label': 'Q1', 'value': 68.0}, {'label': 'Q2', 'value': 72.0},
          {'label': 'Q3', 'value': 75.0}, {'label': 'Q4', 'value': 78.0},
        ]);
      }
    } else if (selectedChartData.value == 'Sesi Latihan') {
      // ... data sesi latihan
       currentProgressData.assignAll([
          {'label': 'M1', 'value': 10.0}, {'label': 'M2', 'value': 12.0},
          {'label': 'M3', 'value': 8.0}, {'label': 'M4', 'value': 15.0},
        ]);
    } else { // Waktu Latihan
      // ... data waktu latihan (misalnya dalam menit)
       currentProgressData.assignAll([
          {'label': 'M1', 'value': 120.0}, {'label': 'M2', 'value': 150.0},
          {'label': 'M3', 'value': 100.0}, {'label': 'M4', 'value': 180.0},
        ]);
    }
  }

  void _updateSkillMetrics() {
    skillMetrics.assignAll({
      'expression': 75.0, 'narrative': 80.0, 'clarity': 70.0,
      'confidence': 85.0, 'filler_words': 5.0, // 5 per menit misalnya
    });
  }

  void _updateImprovementAreas() {
    improvementAreas.assignAll([
      {
        'area': 'Kejelasan Artikulasi', 'description': 'Fokus pada pengucapan kata yang lebih jelas dan vokal yang kuat.',
        'progress': 0.6, 'suggestion': 'Latihan membaca teks dengan suara keras dan merekam diri sendiri.',
        'color': '#3498DB' // Biru
      },
      {
        'area': 'Pengurangan Filler Words', 'description': 'Kurangi penggunaan "umm", "ahh", atau kata pengisi lainnya.',
        'progress': 0.4, 'suggestion': 'Berlatih berbicara dengan jeda sadar daripada menggunakan filler.',
        'color': '#E74C3C' // Merah
      },
       {
        'area': 'Kontak Mata & Gestur', 'description': 'Tingkatkan penggunaan kontak mata dan gestur tubuh yang mendukung pesan Anda.',
        'progress': 0.75, 'suggestion': 'Berlatih di depan cermin atau rekam video presentasi.',
        'color': '#2ECC71' // Hijau
      },
    ]);
  }

  void _updateBadges() {
    badges.assignAll([
      {'icon': LucideIcons.award, 'title': 'Penyelesai 10 Sesi', 'date': '20 Apr', 'unlocked': true, 'color': '#F1C40F'},
      {'icon': LucideIcons.zap, 'title': 'Skor Tertinggi', 'date': '18 Apr', 'unlocked': true, 'color': '#E67E22'},
      {'icon': LucideIcons.calendarDays, 'title': 'Rajin Mingguan', 'date': 'Terkunci', 'unlocked': false, 'color': '#BDC3C7'},
      {'icon': LucideIcons.star, 'title': 'Master Ekspresi', 'date': 'Terkunci', 'unlocked': false, 'color': '#BDC3C7'},
      {'icon': LucideIcons.shieldCheck, 'title': 'Anti Filler Word', 'date': '22 Apr', 'unlocked': true, 'color': '#9B59B6'},
      {'icon': LucideIcons.trendingUp, 'title': 'Peningkatan Pesat', 'date': 'Terkunci', 'unlocked': false, 'color': '#BDC3C7'},
    ]);
  }

  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
    refreshData(); // Atau hanya _updateChartData() jika hanya chart yang terpengaruh
  }

  void changeChartData(String dataOption) {
    selectedChartData.value = dataOption;
     refreshData(); // Atau hanya _updateChartData()
  }

  String get chartTitle {
    return '${selectedChartData.value} (${selectedTimeframe.value})';
  }

  double get maxChartValue {
    if (selectedChartData.value == 'Skor Rata-rata') return 100.0;
    if (selectedChartData.value == 'Sesi Latihan') return 20.0; // Sesuaikan
    if (selectedChartData.value == 'Waktu Latihan') return 200.0; // Sesuaikan
    return 100.0;
  }
   double get intervalChartValue {
    if (selectedChartData.value == 'Skor Rata-rata') return 20.0;
    if (selectedChartData.value == 'Sesi Latihan') return 5.0; // Sesuaikan
    if (selectedChartData.value == 'Waktu Latihan') return 50.0; // Sesuaikan
    return 20.0;
  }

  String getXAxisLabel(Map<String, dynamic> data) => data['label'] as String;
  double getChartValue(Map<String, dynamic> data) => data['value'] as double;

  Color parseColor(String hexColor) { // Helper untuk parse warna
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFFD84040); // Default
    }
  }
}