import 'dart:ui';
import 'package:get/get.dart';

class SertifikatController extends GetxController {
  // State management
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  // Data
  final certificates = <Map<String, dynamic>>[
    {
      'id': 'CERT-001',
      'title': 'Public Speaking Master',
      'description': 'Menyelesaikan 10 sesi latihan Public Speaking dengan skor rata-rata di atas 85',
      'date': '25 April 2025',
      'score': 87,
      'unlocked': true,
      'color': '#D84040',
    },
    {
      'id': 'CERT-002',
      'title': 'Interview Pro',
      'description': 'Menyelesaikan 5 simulasi wawancara kerja dengan skor rata-rata di atas 80',
      'date': '20 April 2025',
      'score': 82,
      'unlocked': true,
      'color': '#3A7BD5',
    },
    {
      'id': 'CERT-003',
      'title': 'Consistent Learner',
      'description': 'Latihan 7 hari berturut-turut tanpa jeda',
      'date': '18 April 2025',
      'score': null,
      'unlocked': true,
      'color': '#00B09B',
    },
    {
      'id': 'CERT-004',
      'title': 'Expression Expert',
      'description': 'Mencapai skor ekspresi di atas 90 dalam 3 sesi berturut-turut',
      'date': 'Locked',
      'score': null,
      'unlocked': false,
      'color': '#6A3093',
    },
  ].obs;

  final filters = ['Semua', 'Terkunci', 'Terbuka'];

  List<Map<String, dynamic>> get filteredCertificates {
    return certificates.where((cert) {
      final matchesFilter = selectedFilter.value == 'Semua' || 
          (selectedFilter.value == 'Terbuka' && cert['unlocked']) ||
          (selectedFilter.value == 'Terkunci' && !cert['unlocked']);
      
      final matchesSearch = cert['title'].toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          cert['description'].toLowerCase().contains(searchQuery.value.toLowerCase());
      
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void changeFilter(String filter) => selectedFilter.value = filter;

  void downloadCertificate(String id) {
    Get.snackbar(
      'Unduh Sertifikat',
      'Mengunduh sertifikat dengan ID $id',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareCertificate(String id) {
    Get.snackbar(
      'Berbagi Sertifikat',
      'Membagikan sertifikat dengan ID $id',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewCertificateDetails(Map<String, dynamic> certificate) {
    Get.toNamed('/certificate-detail', arguments: certificate);
  }

  Color parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}