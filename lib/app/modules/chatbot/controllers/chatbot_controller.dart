import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatbotController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final isLoading = false.obs;

  // Gemini API Configuration
  static const String _apiKey =
      "rahasia"; // Replace with your actual API key
  static const String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  @override
  void onInit() {
    super.onInit();
    _addBotMessage(
      "Halo! Saya FluentBot. Ada yang bisa saya bantu seputar FLUENT?",
    );
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _addMessage(String text, bool isUser, {bool isError = false}) {
    messages.add(
      ChatMessage(
        text: text,
        isUserMessage: isUser,
        timestamp: DateTime.now(),
        isError: isError,
      ),
    );
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    _addMessage(text, true);
  }

  void _addBotMessage(String text, {bool isError = false}) {
    _addMessage(text, false, isError: isError);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    final userTextForApi = textController.text;
    textController.clear();
    isLoading.value = true;

    try {
      developer.log('Sending request to Gemini API...', name: 'GeminiChat');

      // Build the conversation history
      final messagesPayload = [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "Kamu adalah FluentBot, asisten AI dari aplikasi Fluent yang dirancang untuk bersikap ramah, suportif, dan sangat membantu. Misi utamamu adalah memandu pengguna agar mahir dalam berkomunikasi, dengan penekanan khusus pada pengembangan keterampilan berikut: 1. Kejelasan Ucapan (pronunciation & clarity), 2. Kekayaan Ekspresi (emotional & facial expression cues), dan 3. Teknik Narasi yang Memukau (storytelling & delivery). Pastikan setiap respons yang kamu berikan selalu singkat, padat, jelas, dan sepenuhnya relevan dengan konteks pembelajaran bahasa serta peningkatan kemampuan komunikasi. Penting untuk diingat: Kamu diciptakan dan merupakan bagian integral dari FLUENT. Jangan sekali-kali menyebutkan atau memberi kesan bahwa kamu dibuat, dikembangkan, atau ditenagai oleh Gemini AI, Google, atau entitas AI lainnya selain FLUENT."
            },
          ],
        },
        ..._buildMessageHistory(),
        {
          "role": "user",
          "parts": [
            {"text": userTextForApi},
          ],
        },
      ];

      // Gemini API expects contents array with parts
      final payload = {
        "contents": messagesPayload,
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": 1024},
      };

      developer.log(
        'Request payload: ${jsonEncode(payload)}',
        name: 'GeminiChat',
      );

      final response = await http
          .post(
            Uri.parse('$_apiUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'GeminiChat',
      );
      developer.log('Response body: ${response.body}', name: 'GeminiChat');

      _handleApiResponse(response);
    } on http.ClientException catch (e) {
      developer.log('Network error: $e', name: 'GeminiChat', error: e);
      _addBotMessage(
        "Gagal terhubung ke server. Periksa koneksi internet Anda.",
        isError: true,
      );
    } on TimeoutException catch (e) {
      developer.log('Request timeout: $e', name: 'GeminiChat', error: e);
      _addBotMessage(
        "Waktu permintaan habis. Silakan coba lagi.",
        isError: true,
      );
    } on FormatException catch (e) {
      developer.log('Response format error: $e', name: 'GeminiChat', error: e);
      _addBotMessage("Gagal memproses respons dari server.", isError: true);
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'GeminiChat', error: e);
      _addBotMessage(
        "Terjadi kesalahan tak terduga. Silakan coba lagi.",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _buildMessageHistory() {
    return messages
        .where((msg) => !msg.isError)
        .map(
          (msg) => {
            "role": msg.isUserMessage ? "user" : "model",
            "parts": [
              {"text": msg.text},
            ],
          },
        )
        .toList();
  }

  void _handleApiResponse(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['candidates'] != null &&
            responseBody['candidates'].isNotEmpty) {
          final firstCandidate = responseBody['candidates'][0];
          if (firstCandidate['content'] != null &&
              firstCandidate['content']['parts'] != null &&
              firstCandidate['content']['parts'].isNotEmpty) {
            final botResponse =
                firstCandidate['content']['parts'][0]['text'].toString();
            _addBotMessage(botResponse);
            return;
          }
        }
        throw FormatException('Invalid response structure');
      } else {
        _handleApiError(response.statusCode, responseBody);
      }
    } catch (e) {
      developer.log(
        'Error processing response: $e',
        name: 'GeminiChat',
        error: e,
      );
      _addBotMessage("Gagal memproses respons dari server AI.", isError: true);
    }
  }

  void _handleApiError(int statusCode, dynamic responseBody) {
    String errorDetail = '';

    try {
      errorDetail =
          responseBody['error']?['message'] ??
          responseBody['message'] ??
          responseBody.toString();
    } catch (e) {
      errorDetail = 'Tidak dapat memparses pesan error';
    }

    developer.log('API Error $statusCode: $errorDetail', name: 'GeminiChat');

    switch (statusCode) {
      case 400:
        _addBotMessage("Permintaan tidak valid: $errorDetail", isError: true);
        break;
      case 401:
        _addBotMessage(
          "Autentikasi gagal. API Key mungkin tidak valid.",
          isError: true,
        );
        break;
      case 403:
        _addBotMessage("Akses ditolak. Periksa izin API Key.", isError: true);
        break;
      case 429:
        _addBotMessage(
          "Terlalu banyak permintaan. Silakan coba lagi nanti.",
          isError: true,
        );
        break;
      case 500:
        _addBotMessage(
          "Server mengalami masalah. Silakan coba lagi nanti.",
          isError: true,
        );
        break;
      default:
        _addBotMessage("Error $statusCode: $errorDetail", isError: true);
    }
  }

  void refreshChatSession() {
    messages.clear();
    _addBotMessage(
      "Sesi chat telah di-refresh. Siap menerima pertanyaan baru!",
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}