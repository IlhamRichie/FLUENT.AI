import 'package:fluent_ai/app/modules/intro/controllers/intro_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
                duration: const Duration(milliseconds: 700),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
                child: IntroPage(
                  key: ValueKey<String>(
                      "intro_page_${controller.introData[index]["title"]}"),
                  image: controller.introData[index]["image"]!,
                  title: controller.introData[index]["title"]!,
                  description: controller.introData[index]["description"]!,
                  accentAlignment: controller.introData[index]
                      ["accentAlignment"] as Alignment,
                  isLastPage: index == controller.introData.length - 1,
                ),
              );
            },
          ),
          // DOT SLIDER DIHILANGKAN
          // Positioned(
          //   bottom: 120,
          //   left: 0,
          //   right: 0,
          //   child: Obx(
          //     () => Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: List.generate(
          //         controller.introData.length,
          //         (index) => buildDot(index, controller.currentPage.value), // Metode buildDot juga akan dihapus
          //       ),
          //     ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
          //   ),
          // ),

          // Tombol "Mulai"
          Obx(
            () => controller.currentPage.value ==
                    controller.introData.length - 1
                ? Positioned(
                    // Posisi bottom disesuaikan karena dot slider hilang
                    bottom:
                        60, // Sebelumnya 40, dinaikkan sedikit atau sesuaikan
                    left: 60,
                    right: 60,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFa31d1d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 8,
                          shadowColor: const Color(0xFFa31d1d).withOpacity(0.5),
                        ),
                        child: const Text(
                          "Let's Go!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.elasticOut),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // Metode buildDot DIHAPUS karena dot slider tidak digunakan lagi
  // Widget buildDot(int index, int currentPage) { ... }
}

class IntroPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Alignment accentAlignment;
  final bool isLastPage;

  const IntroPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.accentAlignment,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final Duration initialDelay = 200.ms;

    return Stack(
      children: [
        Align(
          alignment: accentAlignment,
          child: CornerAccent(
            alignment: accentAlignment,
            // Anda bisa sedikit memperbesar ukuran jika efek blur/soft edge membuat visualnya terasa lebih kecil
            // size: 150,
          )
              .animate(delay: initialDelay + 800.ms)
              .fadeIn(duration: 800.ms)
              .scaleXY(
                  begin: 0.5,
                  end: 1.0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, width: 280, height: 280)
                  .animate(delay: initialDelay)
                  .fadeIn(duration: 700.ms)
                  .slideY(
                      begin: -0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic)
                  .then(delay: 100.ms)
                  .shake(hz: 3, duration: 400.ms, curve: Curves.easeInOutCubic)
                  .scaleXY(end: 1.05, duration: 300.ms, curve: Curves.easeInOut)
                  .then()
                  .scaleXY(end: 1.0, duration: 300.ms, curve: Curves.easeInOut),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)),
              )
                  .animate(delay: initialDelay + 200.ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(
                      begin: (accentAlignment == Alignment.topLeft ||
                              accentAlignment == Alignment.bottomLeft)
                          ? -0.5
                          : 0.5,
                      end: 0,
                      duration: 700.ms,
                      curve: Curves.easeOutExpo),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[700], height: 1.5),
              )
                  .animate(delay: initialDelay + 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 700.ms,
                      curve: Curves.easeOutExpo),
            ],
          ),
        ),
      ],
    );
  }
}

class CornerAccent extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;

  const CornerAccent({
    super.key,
    required this.alignment,
    this.size = 250.0, // Ukuran bisa disesuaikan
    this.color = const Color(0xFFa31d1d),
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan pusat RadialGradient berdasarkan alignment
    // Kita ingin pusatnya berada di sudut yang sebenarnya
    Alignment gradientCenter;
    if (alignment == Alignment.topLeft) {
      gradientCenter = Alignment.topLeft;
    } else if (alignment == Alignment.topRight) {
      gradientCenter = Alignment.topRight;
    } else if (alignment == Alignment.bottomLeft) {
      gradientCenter = Alignment.bottomLeft;
    } else if (alignment == Alignment.bottomRight) {
      gradientCenter = Alignment.bottomRight;
    } else {
      gradientCenter = Alignment.center; // Fallback
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: _CornerClipper(alignment),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: gradientCenter,
              radius:
                  1.0, // Radius 1.0 akan membuat gradien menyebar ke seluruh widget yang di-clip
              colors: [
                color.withOpacity(0.50), // Warna inti lebih pekat
                color.withOpacity(
                    0.0), // Meluruh menjadi transparan total di tepi
              ],
              // Stops bisa disesuaikan untuk mengatur seberapa cepat gradasi meluruh
              // [0.0, 1.0] berarti gradasi linear dari pusat ke tepi.
              // Untuk pinggiran yang lebih soft, kita ingin bagian solid lebih kecil.
              stops: const [
                0.1,
                0.6
              ], // Bagian solid (opacity 0.25) hanya sampai 0% radius, lalu mulai meluruh ke 80% radius
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerClipper extends CustomClipper<Path> {
  final Alignment alignment;

  _CornerClipper(this.alignment);

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (alignment == Alignment.topLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else if (alignment == Alignment.topRight) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
