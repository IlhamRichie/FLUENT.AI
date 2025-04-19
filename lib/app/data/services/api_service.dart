import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'http://192.168.167.186:5000'; // Update dengan IP lokal server Flask

  // Register user
  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
    String gender,
    String occupation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'gender': gender,
          'occupation': occupation,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "fail",
          "message": "Register error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": "fail", "message": "Register error: $e"};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "fail",
          "message": "Login error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": "fail", "message": "Login error: $e"};
    }
  }

  // Analyze pose using the frames
  Future<Map<String, dynamic>> analyzePose(List<String> framesBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-pose'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'frames': framesBase64}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "fail",
          "message": "Pose analysis error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": "fail", "message": "Pose analysis error: $e"};
    }
  }
}
