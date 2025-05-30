// lib/app/data/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // PASTIKAN INI ADALAH ALAMAT IP SERVER FLASK ANDA YANG BENAR
  // DAN BISA DIAKSES DARI EMULATOR/DEVICE
  static const String baseUrl = 'http://192.168.126.206:5000'; // Ganti jika perlu

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
              .timeout(const Duration(seconds: 20)); // Durasi timeout bisa disesuaikan
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
              .delete(url, headers: requestHeaders, body: jsonEncode(body)) // Tambahkan body jika diperlukan oleh backend
              .timeout(const Duration(seconds: 20));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('<-- ${response.statusCode} $url');
      dynamic responseData;
      try {
        if (response.body.isNotEmpty) {
          if (response.headers['content-type']?.contains('application/json') != true) {
             if (response.statusCode >= 200 && response.statusCode < 300) {
                debugPrint('Warning: Expected JSON response but received ${response.headers['content-type']} for a successful request.');
                if (response.body.trim().isEmpty) {
                  return {'status': 'success', 'message': 'Operation successful, no content returned.'};
                }
             }
            // Khusus untuk error seperti 405 yang mengembalikan HTML
            String shortBody = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
            throw {
              'status': 'error',
              'message': 'Server error ${response.statusCode}: Respon tidak valid dari server (bukan JSON). Isi: $shortBody...'
            };
          }
          responseData = jsonDecode(response.body);
        } else {
          // Jika body kosong tapi status code sukses
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return {
              'status': 'success',
              'message': 'Operation successful, no content returned.'
            };
          }
          // Jika body kosong dan status code error
          responseData = {
            'status': 'error',
            'message': 'Empty response from server with status ${response.statusCode}'
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
          errorMessage = 'Error ${response.statusCode}: Gagal memproses permintaan.';
        }
        return {
          'status': 'error',
          'message': errorMessage,
          'data': responseData // Sertakan data asli jika ada untuk debugging
        };
      }
    } on SocketException catch (e) {
      debugPrint('SocketException for $method $url: $e');
      throw {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
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
      '/auth/register', // Menggunakan prefix /auth
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
      '/auth/login', // Menggunakan prefix /auth
      {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<dynamic> signInWithGoogleToken(String idToken) async {
    // Pastikan endpoint ini benar di backend Anda dan menggunakan prefix /auth jika perlu
    return await _handleRequest(
      'POST',
      '/auth/google/app-signin',
      {'id_token': idToken},
    );
  }

  static Future<dynamic> refreshToken(String refreshToken) async {
    return await _handleRequest(
      'POST',
      '/auth/refresh', // Menggunakan prefix /auth
      {'refresh_token': refreshToken},
    );
  }

  // OTP Services
  static Future<dynamic> verifyOtp({
    required String email,
    required String otp,
    required String source,
  }) async {
    return await _handleRequest(
      'POST',
      '/auth/verify-otp', // Menggunakan prefix /auth
      {
        'email': email,
        'otp': otp,
        'source': source,
      },
    );
  }

  static Future<dynamic> requestOtp({
    required String email,
    required String source,
  }) async {
    return await _handleRequest(
      'POST',
      '/auth/request-otp', // Menggunakan prefix /auth
      {
        'email': email,
        'source': source,
      },
    );
  }

  // User Profile
  static Future<dynamic> updateUserProfile({
    required String token,
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
    // Ganti '/auth/user/update' jika endpoint update profil Anda memiliki prefix atau path berbeda
    return await _handleRequest('PUT', '/auth/user/update', body, token: token);
  }

  static Future<dynamic> requestPasswordReset(String email) async {
    return await _handleRequest(
      'POST',
      '/auth/forgot-password', // Menggunakan prefix /auth
      {'email': email},
    );
  }

  static Future<dynamic> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _handleRequest(
      'POST',
      '/auth/reset-password', // Menggunakan prefix /auth
      {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
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
      '/api/interview/start', // Asumsi ini menggunakan prefix /api
      {'category': category,},
      token: token,
    );
  }
  // ... dan seterusnya untuk metode lain
}