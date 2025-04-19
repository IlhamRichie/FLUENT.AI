import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intro_controller.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.introData.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: IntroPage(
                  key: ValueKey(controller.introData[index]["title"]),
                  image: controller.introData[index]["image"]!,
                  title: controller.introData[index]["title"]!,
                  description: controller.introData[index]["description"]!,
                ),
              );
            },
          ),

          // Indikator PageView (Dots)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.introData.length,
                  (index) => buildDot(index, controller.currentPage.value),
                ),
              ),
            ),
          ),

          // Tombol "Mulai"
          Obx(
            () => controller.currentPage.value == controller.introData.length - 1
                ? Positioned(
                    bottom: 30,
                    left: 60,
                    right: 60,
                    child: SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: controller.navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFa31d1d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Let's Go!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // Widget untuk indikator halaman (dots)
  Widget buildDot(int index, int currentPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index ? const Color(0xFFa31d1d) : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Widget Halaman Intro
class IntroPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const IntroPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, width: 250, height: 250),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}