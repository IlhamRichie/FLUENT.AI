import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000/';

  // Helper function for handling requests
  static Future<dynamic> _handleRequest(
    String method,
    String endpoint,
    dynamic body, {
    String? token,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final requestHeaders = {...defaultHeaders, ...?headers};

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            url,
            headers: requestHeaders,
          );
          break;
        default:
          throw Exception('Invalid HTTP method');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      debugPrint('Error in $method $endpoint: $e');
      rethrow;
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

  static Future<dynamic> refreshToken(String refreshToken) async {
    return await _handleRequest(
      'POST',
      '/refresh',
      {
        'refresh_token': refreshToken,
      },
    );
  }

  // Interview Services
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

  // Analysis Services
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
    return await _handleRequest(
      'GET',
      '/api/user/stats',
      null,
      token: token,
    );
  }

  static Future<dynamic> getRecentActivities({required String token}) async {
    return await _handleRequest(
      'GET',
      '/api/user/activities',
      null,
      token: token,
    );
  }

  static Future<dynamic> getUserBadges({required String token}) async {
    return await _handleRequest(
      'GET',
      '/api/user/badges',
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

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseData);
      } else {
        throw Exception(
            jsonDecode(responseData)['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      debugPrint('Error in analyzeSpeech: $e');
      rethrow;
    }
  }

  // Admin Services (if needed in Flutter app)
  static Future<dynamic> adminLogin({
    required String username,
    required String password,
  }) async {
    return await _handleRequest(
      'POST',
      '/admin/login',
      {
        'username': username,
        'password': password,
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
  }

  static Future<dynamic> toggleUserStatus({
    required String token,
    required String userId,
  }) async {
    return await _handleRequest(
      'POST',
      '/admin/users/toggle-status/$userId',
      null,
      token: token,
    );
  }

  static Future<dynamic> getAdminDashboard({
    required String token,
  }) async {
    return await _handleRequest(
      'GET',
      '/admin/dashboard',
      null,
      token: token,
    );
  }
}
