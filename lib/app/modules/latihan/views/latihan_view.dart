import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart';

class LatihanView extends GetView<LatihanController> {
  const LatihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Latihan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: controller.refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD84040)),
            ));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Pilih Jenis Latihan'),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: _buildKategoriGrid(),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Latihan Terbaru'),
              ),
              _buildLatihanList(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.kategoriLatihan.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilterChip(
                    'Semua', controller.selectedCategory.value == 'Semua');
              }
              final kategori = controller.kategoriLatihan[index - 1];
              return _buildFilterChip(kategori['nama'],
                  controller.selectedCategory.value == kategori['nama']);
            },
          )),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.selectCategory(label),
      selectedColor: const Color(0xFFD84040).withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? const Color(0xFFD84040) : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? const Color(0xFFD84040) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildKategoriGrid() {
    return Obx(() => SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(Get.context!).size.width > 400 ? 2 : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            mainAxisExtent: 170,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildKategoriCard(controller.kategoriLatihan[index]),
            childCount: controller.kategoriLatihan.length,
          ),
        ));
  }

  Widget _buildKategoriCard(Map<String, dynamic> kategori) {
    final color = _parseColor(kategori['warna']);
    final bgColor = color.withOpacity(0.05);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.startLatihan(kategori),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(kategori['ikon']),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                kategori['nama'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                kategori['deskripsi'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (kategori['level'] as List)
                    .map((level) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatihanList() {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLatihanItem(controller.latihanTerbaru[index]),
            ),
            childCount: controller.latihanTerbaru.length,
          ),
        ));
  }

  Widget _buildLatihanItem(Map<String, dynamic> latihan) {
    final color = _parseColor(latihan['warna']);
    final bgColor = color.withOpacity(0.05);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.startLatihan(latihan),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(latihan['kategori']),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latihan['judul'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latihan['kategori'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            latihan['level'],
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          latihan['terakhir_dilakukan'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${latihan['skor']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const Text(
                    'Skor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'interview':
        return LucideIcons.briefcase;
      case 'public_speaking':
        return LucideIcons.mic2;
      case 'expression':
        return LucideIcons.smile;
      case 'filler_word':
        return LucideIcons.type;
      default:
        return LucideIcons.activity;
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}
