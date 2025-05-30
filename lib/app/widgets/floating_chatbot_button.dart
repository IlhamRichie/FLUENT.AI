import 'package:fluent_ai/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Atau Icons.chat dari material

class FloatingChatbotButton extends StatelessWidget {
  const FloatingChatbotButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Anda bisa menggunakan warna dari theme atau hardcode seperti ini
    const Color fabColor = Color(0xFFD84040); // Warna primary Anda
    final Color iconColor = fabColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;


    return FloatingActionButton(
      onPressed: () {
        Get.toNamed(Routes.CHATBOT);
      },
      backgroundColor: fabColor,
      tooltip: 'Buka FluentBot',
      elevation: 4.0,
      splashColor: Colors.white.withOpacity(0.3),
      child: Icon(
        LucideIcons.bot, // Atau Icons.chat, Icons.support_agent
        color: iconColor,
        size: 28,
      ),
    );
  }
}