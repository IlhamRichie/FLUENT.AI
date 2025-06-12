// lib/app/data/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';


class ApiService {
  // PASTIKAN INI ADALAH ALAMAT IP SERVER FLASK ANDA YANG BENAR
  // DAN BISA DIAKSES DARI EMULATOR/DEVICE
  static const String baseUrl =
      'https://tomcat-ace-rarely.ngrok-free.app'; // Ganti jika perlu

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fungsi helper untuk membuat User-Agent
  static Future<String> _getCustomUserAgent() async {
    final deviceInfo = DeviceInfoPlugin();
    String osInfo;
    if (kIsWeb) {
      osInfo = 'Web';
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        osInfo = 'Android ${androidInfo.version.release}; ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        osInfo = 'iOS ${iosInfo.systemVersion}; ${iosInfo.utsname.machine}';
      } else {
        osInfo = Platform.operatingSystem;
      }
    }
    // Format: NamaApp/Versi (OS Versi; Model Perangkat)
    return 'FluentApp/1.0 ($osInfo)';
  }

  static Future<dynamic> _handleRequest(
    String method,
    String endpoint,
    dynamic body, {
    String? token,
    Map<String, String>? headers,
  }) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    final sessionId = await _storage.read(key: 'session_id');
    final customUserAgent = await _getCustomUserAgent();
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'User-Agent': customUserAgent,
      if (token != null) 'Authorization': 'Bearer $token',
      if (sessionId != null)
        'X-Session-ID': sessionId, // <-- TAMBAHKAN HEADER SESI
      ...?headers,
    };

    debugPrint('--> $method $url');
    if (body != null && method.toUpperCase() != 'GET') {
      debugPrint('Body: ${jsonEncode(body)}');
    }
    if (requestHeaders.containsKey('Authorization')) {
      debugPrint('Headers: Authorization: Bearer *****');
    }

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(url, headers: requestHeaders)
              .timeout(const Duration(seconds: 20));
          break;
        case 'POST':
          response = await http
              .post(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 20));
          break;
        case 'PUT':
          response = await http
              .put(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 20));
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 20));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('<-- ${response.statusCode} $url');
      dynamic responseData;
      try {
        if (response.body.isNotEmpty) {
          if (response.headers['content-type']?.contains('application/json') !=
              true) {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              debugPrint(
                  'Warning: Expected JSON response but received ${response.headers['content-type']} for a successful request.');
              if (response.body.trim().isEmpty) {
                return {
                  'status': 'success',
                  'message': 'Operation successful, no content returned.'
                };
              }
            }
            String shortBody = response.body.length > 200
                ? response.body.substring(0, 200)
                : response.body;
            throw {
              'status': 'error',
              'message':
                  'Server error ${response.statusCode}: Respon tidak valid dari server (bukan JSON). Isi: $shortBody...'
            };
          }
          responseData = jsonDecode(response.body);
        } else {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return {
              'status': 'success',
              'message': 'Operation successful, no content returned.'
            };
          }
          responseData = {
            'status': 'error',
            'message':
                'Empty response from server with status ${response.statusCode}'
          };
        }
      } catch (e) {
        debugPrint('Failed to process/decode response: $e');
        if (response.body.isNotEmpty) {
          debugPrint('Problematic response body: ${response.body}');
        }
        if (e is Map && e.containsKey('status') && e.containsKey('message')) {
          rethrow;
        }
        throw {
          'status': 'error',
          'message': 'Invalid response format from server.'
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        String errorMessage = 'Terjadi kesalahan';
        if (responseData is Map &&
            responseData.containsKey('message') &&
            responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        } else {
          errorMessage =
              'Error ${response.statusCode}: Gagal memproses permintaan.';
        }
        return {
          'status': 'error',
          'message': errorMessage,
          'data': responseData
        };
      }
    } on SocketException catch (e) {
      debugPrint('SocketException for $method $url: $e');
      throw {
        'status': 'error',
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
      };
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException for $method $url: $e');
      throw {
        'status': 'error',
        'message': 'Permintaan ke server memakan waktu terlalu lama.'
      };
    } catch (e) {
      debugPrint('Unhandled exception in _handleRequest for $method $url: $e');
      if (e is Map && e.containsKey('status') && e.containsKey('message')) {
        rethrow;
      }
      throw {
        'status': 'error',
        'message': 'Terjadi kesalahan yang tidak diketahui: ${e.toString()}'
      };
    }
  }

  // Auth Services
  static Future<dynamic> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String occupation,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/auth/register', // DISESUAIKAN: Tambahkan /api
      {
        'email': email,
        'username': username,
        'password': password,
        'gender': gender,
        'occupation': occupation,
      },
    );
  }

  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/auth/login', // DISESUAIKAN: Tambahkan /api
      {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<dynamic> signInWithGoogleToken(String idToken) async {
    // Pastikan endpoint ini benar di backend Anda. Jika ada prefix /api, tambahkan.
    // Dari kode Flask sebelumnya, kita tidak secara eksplisit membuat /api/auth/google/app-signin.
    // Jika Anda ingin menggunakan /api/auth/google/signin (atau nama serupa), Anda perlu membuatnya di Flask.
    // Untuk saat ini, saya asumsikan Anda akan membuat endpoint seperti itu.
    return await _handleRequest(
      'POST',
      '/api/auth/google/app-signin', // DISESUAIKAN: Tambahkan /api (ASUMSI ANDA AKAN MEMBUAT ENDPOINT INI DI FLASK)
      {'id_token': idToken},
    );
  }

  static Future<dynamic> refreshToken(String refreshToken) async {
    // Jika Anda mengimplementasikan refresh token, pastikan endpointnya juga ada di Flask
    // dengan prefix yang sesuai.
    return await _handleRequest(
      'POST',
      '/api/auth/refresh', // DISESUAIKAN: Tambahkan /api (ASUMSI ANDA AKAN MEMBUAT ENDPOINT INI DI FLASK)
      {'refresh_token': refreshToken},
    );
  }

  // OTP Services
  static Future<dynamic> verifyOtp({
    required String email,
    required String otp,
    required String source, // 'registration' atau 'passwordReset'
  }) async {
    return await _handleRequest(
      'POST',
      '/api/auth/verify-otp', // DISESUAIKAN: Tambahkan /api
      {
        'email': email,
        'otp': otp,
        'source': source, // source dikirim sesuai kebutuhan controller OTP Anda
      },
    );
  }

  static Future<dynamic> requestOtp({
    required String email,
    required String source, // 'registration' atau 'passwordReset'
  }) async {
    return await _handleRequest(
      'POST',
      '/api/auth/request-otp', // DISESUAIKAN: Tambahkan /api
      {
        'email': email,
        'source': source, // source dikirim sesuai kebutuhan controller OTP Anda
      },
    );
  }

  static Future<dynamic> getActiveSessions({required String token}) async {
    return await _handleRequest(
      'GET',
      '/api/user/sessions', // Sesuaikan dengan prefix blueprint Anda
      null,
      token: token,
    );
  }

  static Future<dynamic> terminateSession({
    required String token,
    required String sessionIdToDelete,
  }) async {
    return await _handleRequest(
      'DELETE',
      '/api/user/sessions/$sessionIdToDelete', // Sesuaikan dengan prefix
      null,
      token: token,
    );
  }

  static Future<dynamic> getActivityLog({required String token}) async {
    return await _handleRequest(
      'GET',
      '/api/user/activity-log', // Sesuaikan dengan prefix
      null,
      token: token,
    );
  }

  // User Profile
  static Future<dynamic> updateUserProfile({
    required String token, // Ini adalah JWT token
    String? username,
    String? occupation,
    String? gender,
  }) async {
    final Map<String, dynamic> body = {};
    if (username != null) body['username'] = username;
    if (occupation != null) body['occupation'] = occupation;
    if (gender != null) body['gender'] = gender;

    if (body.isEmpty) {
      return {'status': 'fail', 'message': 'Tidak ada data untuk diupdate.'};
    }
    // Pastikan endpoint update profil Anda juga menggunakan prefix /api jika itu standar API Anda.
    // Contoh: '/api/user/profile/update' atau '/api/auth/user/update'
    return await _handleRequest('PUT', '/api/user/profile', body,
        token:
            token); // CONTOH: /api/user/profile (SESUAIKAN DENGAN ENDPOINT FLASK ANDA)
  }

  // Password Reset untuk API (jika berbeda dari web)
  // Dari kode Flask, web forgot password mengirim link.
  // Jika API forgot password juga mengirim link, maka flow-nya mungkin sama.
  // Jika API forgot password menggunakan OTP untuk verifikasi sebelum reset, maka perlu endpoint baru.
  // Saat ini, `requestPasswordReset` dan `resetPasswordWithToken` di Flutter
  // sepertinya menargetkan endpoint yang mungkin belum ada khusus untuk API (atau menggunakan yang web)

  static Future<dynamic> requestPasswordReset(String email) async {
    return await _handleRequest(
      'POST',
      '/api/auth/forgot-password', // DISESUAIKAN ke endpoint API
      {'email': email},
    );
  }

  // Di ApiService.dart
  static Future<dynamic> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/auth/reset-password', // Endpoint API BARU untuk submit reset password
      {
        'token': token,
        'new_password':
            newPassword, // Sesuaikan dengan apa yang diharapkan backend API
        'confirm_password':
            confirmPassword, // Sesuaikan dengan apa yang diharapkan backend API
      },
    );
  }

  // ... (Metode lainnya seperti interview, analysis, dll. tetap sama) ...
  // Pastikan prefix endpoint mereka juga sudah benar jika ada
  static Future<dynamic> startInterview({
    required String token,
    required String category,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/interview/start', // Ini sudah menggunakan /api, sepertinya OK
      {
        'category': category,
      },
      token: token,
    );
  }
  // ... dan seterusnya untuk metode lain
}
