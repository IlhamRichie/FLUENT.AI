import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SertifikatController extends GetxController {
  // Loading state
  final RxBool isLoading = true.obs;
  
  // Certificate data
  final RxList<Map<String, dynamic>> certificates = <Map<String, dynamic>>[
    {
      'id': 'CERT-001',
      'title': 'Public Speaking Master',
      'description': 'Menyelesaikan 10 sesi latihan Public Speaking dengan skor rata-rata di atas 85',
      'date': '25 April 2025',
      'score': 87,
      'image': 'assets/images/logo FLUENT.png',
      'unlocked': true,
      'shareable': true,
      'color': '#D84040',  // Added color field
    },
    {
      'id': 'CERT-002',
      'title': 'Interview Pro',
      'description': 'Menyelesaikan 5 simulasi wawancara kerja dengan skor rata-rata di atas 80',
      'date': '20 April 2025',
      'score': 82,
      'image': 'assets/images/logo FLUENT.png',
      'unlocked': true,
      'shareable': true,
      'color': '#3A7BD5',  // Added color field
    },
    {
      'id': 'CERT-003',
      'title': 'Consistent Learner',
      'description': 'Latihan 7 hari berturut-turut tanpa jeda',
      'date': '18 April 2025',
      'score': null,
      'image': 'assets/images/logo FLUENT.png',
      'unlocked': true,
      'shareable': true,
      'color': '#00B09B',  // Added color field
    },
    {
      'id': 'CERT-004',
      'title': 'Expression Expert',
      'description': 'Mencapai skor ekspresi di atas 90 dalam 3 sesi berturut-turut',
      'date': 'Locked',
      'score': null,
      'image': 'assets/images/logo FLUENT.png',
      'unlocked': false,
      'shareable': false,
      'color': '#6A3093',  // Added color field
    },
  ].obs;

  // Filter options
  final RxString selectedFilter = 'Semua'.obs;
  final List<String> filters = ['Semua', 'Terkunci', 'Terbuka'];

  // Search functionality
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Simulate loading data
    loadCertificates();
  }

  // Simulate loading certificates
  Future<void> loadCertificates() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    isLoading.value = false;
  }

  // Get filtered certificates based on selection and search
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

  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Share certificate
  void shareCertificate(String id) {
    final cert = certificates.firstWhere((c) => c['id'] == id);
    Get.snackbar(
      'Berbagi Sertifikat',
      'Membagikan sertifikat "${cert['title']}"',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Here you would implement actual sharing functionality
  }

  // Download certificate
  void downloadCertificate(String id) {
    final cert = certificates.firstWhere((c) => c['id'] == id);
    Get.snackbar(
      'Unduh Sertifikat',
      'Mengunduh sertifikat "${cert['title']}" sebagai PDF',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // Here you would implement actual download functionality
  }

  // View certificate details
  void viewCertificateDetails(Map<String, dynamic> certificate) {
    Get.toNamed('/certificate-detail', arguments: certificate);
  }

  // Helper function to parse color from hex string
  Color parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFD84040); // Default color
    }
  }
}