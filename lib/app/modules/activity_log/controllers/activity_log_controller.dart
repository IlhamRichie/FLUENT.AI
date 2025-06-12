// lib/app/modules/profil/controllers/activity_log_controller.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/modules/profil/models/activity_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ActivityLogController extends GetxController {
  final isLoading = true.obs;
  final RxList<ActivityLogModel> activityLogs = <ActivityLogModel>[].obs;
  final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    fetchActivityLog();
  }

  Future<void> fetchActivityLog() async {
    try {
      isLoading.value = true;
      // Beri sedikit jeda agar animasi loading terlihat mulus
      await Future.delayed(const Duration(milliseconds: 500));
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackbar('Otentikasi Gagal', 'Sesi Anda tidak valid. Silakan login kembali.');
        isLoading.value = false;
        return;
      }

      final response = await ApiService.getActivityLog(token: token);

      if (response['status'] == 'success' && response['log'] != null) {
        final List<ActivityLogModel> fetchedLogs = (response['log'] as List)
            .map((logData) => ActivityLogModel.fromJson(logData))
            .toList();
        activityLogs.assignAll(fetchedLogs);
      } else {
        _showErrorSnackbar('Gagal Memuat', response['message'] ?? 'Tidak dapat mengambil log aktivitas.');
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi Kesalahan', 'Gagal terhubung ke server. Periksa koneksi Anda.');
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER UNTUK SNACKBAR ---

  void _showErrorSnackbar(String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure,
        inMaterialBanner: true,
      ),
    );
    // Gunakan Get.context! untuk mendapatkan BuildContext yang aman
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    }
  }
}