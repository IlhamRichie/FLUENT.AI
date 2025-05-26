// lib/app/data/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.11.130:5000';
  // http://127.0.0.1:5000
  static Future<dynamic> _handleRequest(
    String method,
    String endpoint,
    dynamic body, {
    String? token,
    Map<String, String>? headers,
  }) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
              .timeout(const Duration(seconds: 15));
          break;
        case 'POST':
          response = await http
              .post(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await http
              .put(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('<-- ${response.statusCode} $url');
      dynamic responseData;
      try {
        if (response.body.isNotEmpty) {
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
        debugPrint('Failed to decode JSON response: $e');
        debugPrint('Problematic response body: ${response.body}');
        throw {
          'status': 'error',
          'message': 'Invalid JSON response from server.'
        }; // Throw a map for consistency
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
        // Return a map for the controller to parse
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
        rethrow; // If it's already our custom error map
      }
      throw {
        'status': 'error',
        'message': 'Terjadi kesalahan yang tidak diketahui: ${e.toString()}'
      };
    }
  }

  // Auth Services (register, login, signInWithGoogleToken, refreshToken - sama seperti sebelumnya)
  static Future<dynamic> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String occupation,
  }) async {
    return await _handleRequest(
      'POST',
      '/register',
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
      '/login',
      {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<dynamic> signInWithGoogleToken(String idToken) async {
    return await _handleRequest(
      'POST',
      '/auth/google/app-signin', // SESUAIKAN ENDPOINT BACKEND ANDA
      {'id_token': idToken},
    );
  }

  static Future<dynamic> refreshToken(String refreshToken) async {
    return await _handleRequest(
      'POST',
      '/refresh',
      {'refresh_token': refreshToken},
    );
  }

  // User Profile Update Service
  static Future<dynamic> updateUserProfile({
    required String token,
    String? username,
    String? occupation,
    String? gender,
    // Tambahkan field lain yang bisa diupdate jika ada
  }) async {
    final Map<String, dynamic> body = {};
    if (username != null) body['username'] = username;
    if (occupation != null) body['occupation'] = occupation;
    if (gender != null) body['gender'] = gender;

    if (body.isEmpty) {
      return {'status': 'fail', 'message': 'Tidak ada data untuk diupdate.'};
    }

    return await _handleRequest(
      'PUT',
      '/user/update', // Endpoint backend Anda untuk update user
      body,
      token: token,
    );
  }

  // Tambahkan method ini
  static Future<dynamic> requestPasswordReset(String email) async {
    return await _handleRequest(
      'POST',
      '/forgot-password', // SESUAIKAN ENDPOINT BACKEND ANDA
      {'email': email},
    );
  }

  // Jika Anda juga ingin menangani proses reset password di dalam aplikasi via token:
  static Future<dynamic> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _handleRequest(
      'POST',
      '/reset-password', // SESUAIKAN ENDPOINT BACKEND ANDA
      {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // Method lainnya (interview, analysis, admin - sama seperti sebelumnya)
  // ... (Interview Services) ...
  static Future<dynamic> startInterview({
    required String token,
    required String category,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/interview/start',
      {
        'category': category,
      },
      token: token,
    );
  }

  static Future<dynamic> submitAnswer({
    required String token,
    required String sessionId,
    required String answerText,
    String? audioAnswer,
  }) async {
    return await _handleRequest(
      'POST',
      '/api/interview/submit',
      {
        'session_id': sessionId,
        'answer_text': answerText,
        if (audioAnswer != null) 'audio_answer': audioAnswer,
      },
      token: token,
    );
  }

  static Future<dynamic> getResults({
    required String token,
    required String sessionId,
  }) async {
    return await _handleRequest(
      'GET',
      '/api/interview/results/$sessionId',
      null,
      token: token,
    );
  }

  // ... (Analysis Services) ...
  static Future<dynamic> analyzeRealtime({
    required String token,
    required String base64Image,
  }) async {
    return await _handleRequest(
      'POST',
      '/analyze_realtime',
      {
        'frame': base64Image,
      },
      token: token,
    );
  }

  static Future<dynamic> getUserStats({required String token}) async {
    // Anda mungkin perlu endpoint ini untuk ProfilController atau HomeController
    return await _handleRequest(
      'GET',
      '/api/user/stats', // Ganti dengan endpoint yang sesuai jika ada
      null,
      token: token,
    );
  }

  static Future<dynamic> getRecentActivities({required String token}) async {
    // Anda mungkin perlu endpoint ini untuk HomeController
    return await _handleRequest(
      'GET',
      '/api/user/activities', // Ganti dengan endpoint yang sesuai jika ada
      null,
      token: token,
    );
  }

  static Future<dynamic> getUserBadges({required String token}) async {
    return await _handleRequest(
      'GET',
      '/api/user/badges', // Ganti dengan endpoint yang sesuai jika ada
      null,
      token: token,
    );
  }

  static Future<dynamic> analyzeSpeech({
    required String token,
    required File audioFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/analyze_speech');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      ));
      debugPrint('--> POST (Multipart) $url');
      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();
      debugPrint('<-- ${response.statusCode} $url (Multipart)');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody);
      } else {
        String errorMessage = 'Gagal menganalisis suara.';
        try {
          final decodedError = jsonDecode(responseBody);
          if (decodedError is Map && decodedError.containsKey('message')) {
            errorMessage = decodedError['message'];
          }
        } catch (_) {}
        return {'status': 'error', 'message': errorMessage};
      }
    } on SocketException catch (e) {
      debugPrint('SocketException in analyzeSpeech: $e');
      throw {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server untuk analisis suara.'
      };
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException in analyzeSpeech: $e');
      throw {
        'status': 'error',
        'message': 'Analisis suara memakan waktu terlalu lama.'
      };
    } catch (e) {
      debugPrint('Error in analyzeSpeech: $e');
      if (e is Map && e.containsKey('status') && e.containsKey('message'))
        rethrow;
      throw {
        'status': 'error',
        'message': 'Gagal menganalisis suara: ${e.toString()}'
      };
    }
  }
  // ... (Admin services - tidak berubah dari kode Anda)
}
