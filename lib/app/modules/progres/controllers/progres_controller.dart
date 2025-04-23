import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProgresController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // Data for progress charts
  final RxList<Map<String, dynamic>> weeklyProgress = <Map<String, dynamic>>[
    {"day": "Sen", "score": 65, "expression": 70, "narrative": 60},
    {"day": "Sel", "score": 70, "expression": 75, "narrative": 65},
    {"day": "Rab", "score": 75, "expression": 80, "narrative": 70},
    {"day": "Kam", "score": 80, "expression": 85, "narrative": 75},
    {"day": "Jum", "score": 85, "expression": 90, "narrative": 80},
    {"day": "Sab", "score": 82, "expression": 88, "narrative": 76},
    {"day": "Min", "score": 88, "expression": 92, "narrative": 84},
  ].obs;

  final RxList<Map<String, dynamic>> monthlyProgress = <Map<String, dynamic>>[
    {"week": "Minggu 1", "score": 65, "expression": 70, "narrative": 60},
    {"week": "Minggu 2", "score": 72, "expression": 76, "narrative": 68},
    {"week": "Minggu 3", "score": 78, "expression": 82, "narrative": 74},
    {"week": "Minggu 4", "score": 85, "expression": 88, "narrative": 82},
  ].obs;

  // Skill metrics
  final RxMap<String, dynamic> skillMetrics = {
    "expression": 82,
    "narrative": 78,
    "clarity": 75,
    "confidence": 80,
    "filler_words": 15, // per minute
  }.obs;

  // Badges and achievements
  final RxList<Map<String, dynamic>> badges = <Map<String, dynamic>>[
    {
      "title": "Pembicara Konsisten",
      "description": "Latihan 7 hari berturut-turut",
      "icon": LucideIcons.flame,
      "unlocked": true,
      "date": "20 Apr 2025"
    },
    {
      "title": "Ekspresi Master",
      "description": "Skor ekspresi di atas 85",
      "icon": LucideIcons.smile,
      "unlocked": true,
      "date": "18 Apr 2025"
    },
    {
      "title": "Narator Handal",
      "description": "Skor narasi di atas 80",
      "icon": LucideIcons.text,
      "unlocked": false,
      "date": "Locked"
    },
    {
      "title": "Tanpa Filler Words",
      "description": "0 filler words dalam 3 latihan",
      "icon": LucideIcons.volume2,
      "unlocked": false,
      "date": "Locked"
    },
  ].obs;

  // Areas to improve
  final RxList<Map<String, dynamic>> improvementAreas = <Map<String, dynamic>>[
    {
      "area": "Filler Words",
      "description": "Kurangi kata 'eee', 'mmm', 'anu'",
      "progress": 0.6,
      "suggestion": "Latihan jeda sebelum berbicara"
    },
    {
      "area": "Kecepatan Bicara",
      "description": "Terlalu cepat saat gugup",
      "progress": 0.4,
      "suggestion": "Latihan pernafasan dan tempo"
    },
    {
      "area": "Kontak Mata",
      "description": "Kurang konsisten",
      "progress": 0.7,
      "suggestion": "Latihan dengan kamera"
    },
  ].obs;

  // Timeframe selection
  final RxString selectedTimeframe = 'Mingguan'.obs;
  final List<String> timeframes = ['Mingguan', 'Bulanan'];

  // Chart data selection
  final RxString selectedChartData = 'Skor'.obs;
  final List<String> chartDataOptions = ['Skor', 'Ekspresi', 'Narasi'];

  @override
  void onInit() {
    super.onInit();
    // Simulate loading data when controller initializes
    loadData();
  }

  // Simulate loading data
  Future<void> loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network request
    isLoading.value = false;
  }

  // Refresh data
  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate refresh
    isLoading.value = false;
  }

  // Get the current progress data based on selected timeframe
  List<Map<String, dynamic>> get currentProgressData {
    return selectedTimeframe.value == 'Mingguan' 
      ? weeklyProgress
      : monthlyProgress;
  }

  // Get the chart title based on selected data
  String get chartTitle {
    return 'Perkembangan ${selectedChartData.value} (${selectedTimeframe.value})';
  }

  // Get the chart value based on selected data
  double getChartValue(Map<String, dynamic> data) {
    switch (selectedChartData.value) {
      case 'Ekspresi':
        return data['expression'].toDouble();
      case 'Narasi':
        return data['narrative'].toDouble();
      default:
        return data['score'].toDouble();
    }
  }

  // Get the max value for chart scaling
  double get maxChartValue {
    final data = currentProgressData;
    double max = 0;
    for (var item in data) {
      double value = getChartValue(item);
      if (value > max) max = value;
    }
    return max * 1.1; // Add 10% padding
  }

  // Get the label for x-axis
  String getXAxisLabel(Map<String, dynamic> data) {
    return selectedTimeframe.value == 'Mingguan' 
      ? data['day'] 
      : data['week'];
  }

  // Get color for chart based on selected data
  Color get chartColor {
    switch (selectedChartData.value) {
      case 'Ekspresi':
        return Colors.orange;
      case 'Narasi':
        return Colors.green;
      default:
        return const Color(0xFFD84040); // Using the red color from design
    }
  }

  // Change timeframe
  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
  }

  // Change chart data
  void changeChartData(String data) {
    selectedChartData.value = data;
  }
}