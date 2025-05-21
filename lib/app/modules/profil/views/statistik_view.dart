// lib/app/modules/statistic/views/statistic_view.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StatisticView extends StatefulWidget {
  const StatisticView({super.key});

  @override
  State<StatisticView> createState() => _StatisticViewState();
}

class _StatisticViewState extends State<StatisticView> {
  late final WebViewController _controller;

  String get streamlitUrl {
    if (kIsWeb) {
      return 'http://192.168.56.121:8501';
    } else {
      // Android Emulator
      return 'http://192.168.56.121:8501';
      // Untuk iOS Sim/Device fisik di jaringan sama, gunakan IP PC Anda
      // return 'http://192.168.X.X:8501';
    }
  }

  int _loadingPercentage = 0;
  bool _pageFinishedLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController(); // Inisialisasi dasar

    // --- MODIFIKASI KONFIGURASI CONTROLLER ---
    if (!kIsWeb) {
      // API ini tidak diimplementasikan atau tidak diperlukan di web
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    // setBackgroundColor umumnya aman, tapi bisa juga dibungkus jika menyebabkan masalah di web
    _controller.setBackgroundColor(const Color(0x00000000));

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          if (mounted) {
            setState(() {
              _loadingPercentage = progress;
            });
          }
        },
        onPageStarted: (String url) {
          if (mounted) {
            setState(() {
              _loadingPercentage = 0;
              _pageFinishedLoading = false;
            });
          }
        },
        onPageFinished: (String url) {
          if (mounted) {
            setState(() {
              _loadingPercentage = 100;
              _pageFinishedLoading = true;
            });
          }
        },
        onWebResourceError: (WebResourceError error) {
          if (mounted) {
            setState(() {
              _pageFinishedLoading = true;
            });
          }
          debugPrint(
              "WebView Error: ${error.description}, Code: ${error.errorCode}, URL: ${error.url}, Type: ${error.errorType}, isForMainFrame: ${error.isForMainFrame}");
          Get.snackbar(
            "Error Memuat Halaman",
            "Gagal memuat statistik. Pastikan server Streamlit (${streamlitUrl}) berjalan dan URL benar. Error: ${error.description}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 7),
          );
        },
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );
    // --- AKHIR MODIFIKASI KONFIGURASI CONTROLLER ---

    _controller.loadRequest(Uri.parse(streamlitUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik BPS (Streamlit)'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (!_pageFinishedLoading ||
              (_loadingPercentage > 0 && _loadingPercentage < 100))
            Positioned(
              top: 0, // Agar berada di bawah AppBar jika AppBar memiliki elevation
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingPercentage / 100.0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary), // Menggunakan colorScheme
              ),
            ),
        ],
      ),
    );
  }
}