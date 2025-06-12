import 'package:fluent_ai/app/data/services/api_service.dart';
import 'package:fluent_ai/app/modules/profil/models/session_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class DeviceManagementController extends GetxController {
  final isLoading = true.obs;
  final RxList<ActiveSessionModel> sessions = <ActiveSessionModel>[].obs;
  final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      isLoading.value = true;
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        // Handle not logged in
        return;
      }
      final response = await ApiService.getActiveSessions(token: token);
      if (response['status'] == 'success' && response['sessions'] != null) {
        final List<ActiveSessionModel> fetchedSessions =
            (response['sessions'] as List)
                .map((s) => ActiveSessionModel.fromJson(s))
                .toList();
        sessions.assignAll(fetchedSessions);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat sesi');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> terminateSession(String sessionId) async {
    // Tampilkan dialog konfirmasi
    Get.defaultDialog(
      title: 'Hapus Sesi',
      middleText: 'Anda yakin ingin mengeluarkan perangkat ini?',
      textConfirm: 'Ya, Hapus',
      textCancel: 'Batal',
      onConfirm: () async {
        Get.back(); // Tutup dialog
        try {
          final token = await _storage.read(key: 'access_token');
          if (token == null) return;
          
          final response = await ApiService.terminateSession(token: token, sessionIdToDelete: sessionId);
          if(response['status'] == 'success') {
            Get.snackbar('Sukses', 'Sesi berhasil dihapus.');
            sessions.removeWhere((s) => s.sessionId == sessionId); // Hapus dari list UI
          } else {
            Get.snackbar('Gagal', response['message'] ?? 'Gagal menghapus sesi.');
          }
        } catch (e) {
           Get.snackbar('Error', 'Terjadi kesalahan: $e');
        }
      }
    );
  }
}