// lib/app/modules/chatbot/views/chatbot_view.dart
import 'package:fluent_ai/app/modules/chatbot/controllers/chatbot_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Menggunakan LucideIcons

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD84040); // Warna utama aplikasi Anda
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBackgroundColor = isDarkMode ? Colors.grey[850]! : Colors.grey[50]!;
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        // Gunakan Row untuk title agar bisa menambahkan ikon
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bot, color: Colors.white, size: 26), // Ikon bot
            const SizedBox(width: 10),
            const Text('FluentBot'),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2, // Sedikit lebih tegas
        centerTitle: true, // Pusatkan title
        shape: const RoundedRectangleBorder( // AppBar dengan sudut sedikit melengkung di bawah
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white), // Ikon refresh yang lebih modern
            onPressed: controller.refreshChatSession,
            tooltip: "Refresh Sesi Chat",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                // Tambahkan padding bawah agar tidak tertutup input field saat scroll ke paling bawah
                padding: const EdgeInsets.only(top: 16.0, left: 12.0, right: 12.0, bottom: 80.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  // Kirim juga warna tema untuk styling yang lebih konsisten
                  return _buildMessageBubble(context, message, primaryColor, isDarkMode);
                },
              ),
            ),
          ),
          _buildMessageInputField(context, primaryColor, cardColor, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    Color userBubbleColor,
    bool isDarkMode,
  ) {
    bool isUser = message.isUserMessage;
    bool isError = message.isError;

    // Warna untuk bubble bot dan error
    final Color botBubbleColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    final Color errorBubbleColorDefault = isDarkMode ? Colors.red[800]!.withOpacity(0.7) : Colors.red[100]!;
    final Color errorTextColorDefault = isDarkMode ? Colors.red[100]! : Colors.red[700]!;

    // Penyesuaian radius untuk tampilan "tail"
    final Radius bubbleRadius = const Radius.circular(20);
    final Radius tailRadius = const Radius.circular(8); // Radius yang lebih kecil untuk "ekor"

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Agar Row tidak mengambil lebar penuh jika tidak perlu
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar untuk Bot (opsional)
            if (!isUser) ...[
              CircleAvatar(
                backgroundColor: isError ? errorBubbleColorDefault : botBubbleColor,
                foregroundColor: isError ? errorTextColorDefault : (isDarkMode ? Colors.white70 : Colors.black54),
                radius: 16,
                child: isError
                  ? const Icon(LucideIcons.alertTriangle, size: 18)
                  : const Icon(LucideIcons.bot, size: 18),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75, // Sedikit lebih kecil
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isUser
                      ? userBubbleColor
                      : (isError ? errorBubbleColorDefault : botBubbleColor),
                  borderRadius: isUser
                      ? BorderRadius.only(
                          topLeft: bubbleRadius,
                          topRight: bubbleRadius,
                          bottomLeft: bubbleRadius,
                          bottomRight: tailRadius, // Ekor di kanan bawah untuk user
                        )
                      : BorderRadius.only(
                          topLeft: tailRadius, // Ekor di kiri atas untuk bot
                          topRight: bubbleRadius,
                          bottomLeft: bubbleRadius,
                          bottomRight: bubbleRadius,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.08),
                      spreadRadius: 0.5,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Semua teks rata kiri dalam bubble
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : (isError
                                ? errorTextColorDefault
                                : (isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87)),
                        fontSize: 16, // Sedikit lebih besar
                        height: 1.4, // Line height yang lebih baik
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight, // Timestamp selalu di kanan bawah bubble
                      child: Text(
                        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : (isError
                                  ? errorTextColorDefault.withOpacity(0.7)
                                  : (isDarkMode ? Colors.white54 : Colors.black45)),
                          fontSize: 11, // Sedikit lebih besar
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
             // Avatar untuk User (opsional, jika ingin konsisten)
            if (isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: userBubbleColor.withOpacity(0.8),
                foregroundColor: Colors.white,
                radius: 16,
                child: const Icon(LucideIcons.user, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField(
    BuildContext context,
    Color primaryColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: cardColor, // Menggunakan cardColor agar konsisten dengan tema
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1), // Shadow sedikit ke atas
            blurRadius: 6.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        // Beri sedikit border atas untuk memisahkan dari list
        border: Border(top: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!, width: 0.8)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan item secara vertikal
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                minLines: 1,
                maxLines: 4, // Batasi max lines
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: 16.0, color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[700]?.withOpacity(0.5) : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.0),
                    borderSide: BorderSide.none, // Hilangkan border default
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28.0),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  isDense: true,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty && !controller.isLoading.value) {
                    controller.sendMessage(text);
                  }
                },
                onTapOutside: (_){ // Menutup keyboard saat tap di luar textfield
                    FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(13.0), // Disesuaikan agar CircularProgressIndicator pas
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  // Gunakan ElevatedButton untuk konsistensi tampilan tombol
                  : ElevatedButton(
                      onPressed: () {
                        final text = controller.textController.text;
                        if (text.trim().isNotEmpty && !controller.isLoading.value) {
                          controller.sendMessage(text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(), // Tombol bulat
                        padding: const EdgeInsets.all(14), // Ukuran tombol
                        elevation: 2,
                      ),
                      child: const Icon(Icons.send_rounded, size: 22), // Ikon send yang lebih modern
                    ),
            ),
          ],
        ),
      ),
    );
  }
}