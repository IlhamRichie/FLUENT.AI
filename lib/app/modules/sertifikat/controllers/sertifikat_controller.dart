// lib/app/modules/sertifikat/controllers/sertifikat_controller.dart
import 'dart:ui';
import 'package:fluent_ai/app/modules/sertifikat/controllers/sertifikat_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SertifikatController extends GetxController {
  final isLoading = true.obs;
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  final RxList<CertificateModel> certificates = <CertificateModel>[].obs;
  // Di SertifikatController.dart
// final List<String> filters = ['Semua', 'Terkunci', 'Terbuka', 'Terbaru']; // Lama
  final RxList<String> filters =
      <String>['Semua', 'Terkunci', 'Terbuka', 'Terbaru'].obs; // Baru

  @override
  void onInit() {
    super.onInit();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    isLoading.value = true;
    await Future.delayed(
        const Duration(milliseconds: 1500)); // Simulasi loading

    final dummyData = [
      CertificateModel(
        id: 'CERT-001',
        title: 'Public Speaking Master',
        description:
            'Menyelesaikan 10 sesi latihan Public Speaking dengan skor rata-rata di atas 85.',
        date: '25 Apr 2025',
        score: 87,
        unlocked: true,
        colorHex: '#D84040',
        icon: LucideIcons.mic,
      ),
      CertificateModel(
        id: 'CERT-002',
        title: 'Interview Pro',
        description:
            'Menyelesaikan 5 simulasi wawancara kerja dengan skor rata-rata di atas 80.',
        date: '20 Apr 2025',
        score: 82,
        unlocked: true,
        colorHex: '#3A7BD5',
        icon: LucideIcons.briefcase,
      ),
      CertificateModel(
        id: 'CERT-003',
        title: 'Consistent Learner',
        description: 'Latihan 7 hari berturut-turut tanpa jeda.',
        date: '18 Apr 2025',
        unlocked: true,
        colorHex: '#00B09B',
        icon: LucideIcons.calendarCheck,
      ),
      CertificateModel(
        id: 'CERT-004',
        title: 'Expression Expert',
        description:
            'Mencapai skor ekspresi di atas 90 dalam 3 sesi berturut-turut.',
        date: 'Terkunci',
        unlocked: false,
        colorHex: '#6A3093',
        icon: LucideIcons.smile,
      ),
      CertificateModel(
        id: 'CERT-005',
        title: 'Vocabulary Virtuoso',
        description: 'Menguasai 500 kosakata baru dalam sebulan.',
        date: 'Terkunci',
        unlocked: false,
        colorHex: '#FDC830',
        icon: LucideIcons.bookOpenCheck,
      ),
      CertificateModel(
        id: 'CERT-006',
        title: 'Grammar Guru',
        description:
            'Menyelesaikan semua modul tata bahasa dengan akurasi 95%.',
        date: '01 Mei 2025',
        unlocked: true,
        colorHex: '#FF8C00',
        icon: LucideIcons.spellCheck2,
      ),
    ];
    certificates.assignAll(dummyData);
    isLoading.value = false;
  }

  List<CertificateModel> get filteredCertificates {
    List<CertificateModel> listToShow;

    if (selectedFilter.value == 'Semua') {
      listToShow = certificates.toList();
    } else if (selectedFilter.value == 'Terbuka') {
      listToShow = certificates.where((cert) => cert.unlocked).toList();
    } else if (selectedFilter.value == 'Terkunci') {
      listToShow = certificates.where((cert) => !cert.unlocked).toList();
    } else {
      listToShow = certificates.toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      listToShow = listToShow.where((cert) {
        return cert.title.toLowerCase().contains(query) ||
            cert.description.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedFilter.value == 'Terbaru') {
      listToShow.sort((a, b) {
        if (a.unlocked && !b.unlocked) return -1;
        if (!a.unlocked && b.unlocked) return 1;
        // Untuk sorting tanggal yang benar, Anda perlu mem-parse string tanggal ke DateTime
        // Ini contoh sederhana jika format tanggal konsisten dan bisa dibandingkan sebagai string
        return b.date.compareTo(a.date);
      });
    }
    return listToShow;
  }

  void changeFilter(String filter) => selectedFilter.value = filter;

  Color parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey[700]!;
    }
  }

  void viewCertificateDetails(CertificateModel certificate) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: parseColor(certificate.colorHex).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(certificate.icon,
                  color: parseColor(certificate.colorHex), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  certificate.title,
                  style: TextStyle(
                      color: parseColor(certificate.colorHex),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(certificate.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 16),
              _buildDetailRow(
                  LucideIcons.calendar, "Tanggal: ${certificate.date}"),
              if (certificate.score != null)
                _buildDetailRow(LucideIcons.star, "Skor: ${certificate.score}"),
              _buildDetailRow(
                certificate.unlocked ? LucideIcons.unlock : LucideIcons.lock,
                "Status: ${certificate.unlocked ? 'Terbuka' : 'Terkunci'}",
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tutup', style: TextStyle(color: Colors.grey[600])),
          ),
          if (certificate.unlocked)
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.download,
                  size: 18, color: Colors.white),
              label: const Text('Unduh', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Get.back();
                _showSnackbar(
                    'Mengunduh: ${certificate.title}', certificate.colorHex);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: parseColor(certificate.colorHex),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  void _showSnackbar(String message, String colorHex, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Gagal' : 'Sukses',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: parseColor(colorHex).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      icon: Icon(isError ? LucideIcons.xCircle : LucideIcons.checkCircle,
          color: Colors.white),
    );
  }

  void downloadCertificate(String id) {
    final cert = certificates.firstWhereOrNull((c) => c.id == id);
    if (cert != null) {
      _showSnackbar('Memproses unduhan untuk: ${cert.title}', cert.colorHex);
    }
  }

  void shareCertificate(String id) {
    final cert = certificates.firstWhereOrNull((c) => c.id == id);
    if (cert != null) {
      _showSnackbar(
          'Mempersiapkan untuk berbagi: ${cert.title}', cert.colorHex);
    }
  }
}
