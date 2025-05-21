// lib/app/modules/latihan/views/latihan_view.dart
import 'package:fluent_ai/app/modules/latihan/controllers/latihan_controller.dart';
import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';
import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart';
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
// Impor WawancaraIntroView dan Bindingnya
import 'package:fluent_ai/app/modules/wawancara/views/wawanvara_intro_view.dart'; // Pastikan path ini benar
import 'package:fluent_ai/app/modules/wawancara/bindings/wawancara_binding.dart'; // Pastikan path ini benar
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class LatihanView extends GetView<LatihanController> {
  const LatihanView({super.key});

  // ... (build, _buildShimmerPage, _buildSectionHeader, _buildCategoryFilter, _buildKategoriGrid tetap sama) ...
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = controller.parseColor('#D84040');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('Mulai Latihan',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey[850])),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.search, size: 22, color: Colors.grey[700]),
            onPressed: () {
              Get.snackbar('Pencarian', 'Fitur pencarian latihan akan datang!',
                  snackPosition: SnackPosition.BOTTOM);
            },
            tooltip: 'Cari Latihan',
          ),
          IconButton(
            icon: Icon(LucideIcons.rotateCw, size: 22, color: Colors.grey[700]),
            onPressed: controller.refreshData,
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.semuaKategoriLatihan.isEmpty) {
          return _buildShimmerPage();
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _buildCategoryFilter(primaryColor)),
              _buildSectionHeader('Pilih Kategori Latihan',
                  LucideIcons.layoutGrid, primaryColor),
              _buildKategoriGrid(),
              Obx(() => controller.latihanTerbaru.isNotEmpty
                  ? SliverMainAxisGroup(
                      // Gunakan SliverMainAxisGroup jika ada beberapa sliver
                      slivers: [
                        _buildSectionHeader('Lanjutkan Latihan Terakhir',
                            LucideIcons.history, primaryColor),
                        _buildLatihanList(),
                      ],
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink())),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      }),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildShimmerPage() {
    /* ... (kode tetap sama) ... */
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Container(
                  height: 20,
                  width: 220,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18))),
              ),
              const SizedBox(height: 24),
              Container(
                  height: 20,
                  width: 180,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 90,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    /* ... (kode tetap sama) ... */
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          children: [
            Icon(icon, color: color.withOpacity(0.8), size: 22),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(Color primaryColor) {
    /* ... (kode tetap sama) ... */
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        height: 50,
        child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: controller.filterOptions.length,
              itemBuilder: (context, index) {
                final categoryName = controller.filterOptions[index];
                final isSelected =
                    controller.selectedCategory.value == categoryName;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: ChoiceChip(
                    label: Text(categoryName,
                        style: const TextStyle(fontSize: 13.5)),
                    selected: isSelected,
                    onSelected: (_) => controller.selectCategory(categoryName),
                    backgroundColor: Colors.white,
                    selectedColor: primaryColor.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: isSelected
                              ? primaryColor.withOpacity(0.7)
                              : Colors.grey[300]!,
                          width: 1.2),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: isSelected ? 0.5 : 0,
                    showCheckmark: false,
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildKategoriGrid() {
    /* ... (kode tetap sama) ... */
    return Obx(() {
      final kategoriList = controller.kategoriLatihan;
      if (kategoriList.isEmpty &&
          controller.selectedCategory.value != 'Semua') {
        return SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.searchX, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Kategori "${controller.selectedCategory.value}" tidak ditemukan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildKategoriCard(kategoriList[index]),
            childCount: kategoriList.length,
          ),
        ),
      );
    });
  }

  Widget _buildKategoriCard(KategoriLatihanModel kategori) {
    final color = controller.parseColor(kategori.warna);

    return Card(
      elevation: 2.5,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          String kategoriNamaLower = kategori.nama.toLowerCase();
          if (kategoriNamaLower.contains('wawancara') ||
              kategoriNamaLower.contains('narasi ai')) {
            Get.to(
              () => const WawancaraIntroView(),
              binding: WawancaraBinding(),
              arguments: {'kategori': kategori},
            );
          } else {
            controller.startLatihanKategori(kategori);
          }
        },
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Column(
          // Column utama kartu
          // crossAxisAlignment: CrossAxisAlignment.stretch, // Tidak perlu lagi jika child mengisi
          children: [
            // Bagian Atas: Ikon dengan background gradien
            Container(
              height:
                  90, // Tinggi tetap atau bisa diatur dengan Flexible/Expanded
              width: double.infinity, // Memastikan mengisi lebar kartu
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.75), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Tidak perlu borderRadius di sini karena Card sudah di-clip
              ),
              child: Center(
                  child: Icon(controller.getCategoryIcon(kategori.ikon),
                      color: Colors.white, size: 38)),
            ),

            // Bagian Bawah: Teks dengan background putih
            Expanded(
              // Expanded agar bagian ini mengisi sisa ruang vertikal
              child: Container(
                color:
                    Colors.white, // <--- Latar belakang putih untuk area teks
                width: double.infinity, // Memastikan mengisi lebar kartu
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kategori.nama,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            color: Colors.grey[850]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Gunakan Flexible untuk deskripsi agar tidak overflow jika terlalu panjang
                      // dan memungkinkan Spacer bekerja dengan baik.
                      Flexible(
                        child: Text(
                          kategori.deskripsi,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.25),
                          maxLines: 2, // Atau 3 jika masih ada ruang
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(), // Dorong info sesi & level ke bawah
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${kategori.jumlahSesi} Sesi',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: color, // Warna teks sesi dari kategori
                                fontWeight: FontWeight.w600),
                          ),
                          Flexible(
                            child: Wrap(
                              spacing: 3,
                              runSpacing: 2,
                              alignment: WrapAlignment.end,
                              children: kategori.level
                                  .map((level) => Chip(
                                        label: Text(level,
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              color: color.withOpacity(
                                                  0.95), // Warna chip dari kategori
                                              fontWeight: FontWeight.w500,
                                            )),
                                        backgroundColor:
                                            color.withOpacity(0.12),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 0),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatihanList() {
    /* ... (kode tetap sama, pastikan onTap di _buildLatihanItem juga benar) ... */
    return Obx(() {
      final latihanList = controller.latihanTerbaru;
      if (latihanList.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildLatihanItem(latihanList[index]),
            );
          },
          childCount: latihanList.length,
        ),
      );
    });
  }

  Widget _buildLatihanItem(LatihanItemModel latihan) {
    final color = controller.parseColor(latihan.warna);

    return Card(
      elevation: 1.5,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // --- PERUBAHAN DI SINI JUGA JIKA PERLU ---
          // Jika item latihan dari kategori "Narasi AI" juga harus ke WawancaraIntroView
          String kategoriNamaLower = latihan.kategori.toLowerCase();
          if (kategoriNamaLower.contains('wawancara') ||
              kategoriNamaLower.contains('narasi ai')) {
            Get.to(
              () => const WawancaraIntroView(),
              binding: WawancaraBinding(),
              arguments: {'latihanItem': latihan}, // Kirim LatihanItemModel
            );
          } else {
            // Untuk item latihan dari kategori lain
            controller.startLatihanItem(latihan);
          }
          // --- AKHIR PERUBAHAN ---
        },
        splashColor: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            /* ... (isi Row tetap sama seperti sebelumnya) ... */
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(
                    controller.getCategoryIcon(latihan.kategori,
                        isFromItem: true),
                    color: color,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latihan.judul,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: Colors.grey[800]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${latihan.kategori} • ${latihan.level}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir: ${latihan.terakhirDilakukan}',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (latihan.skor != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${latihan.skor}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: color),
                    ),
                    Text('Skor',
                        style:
                            TextStyle(fontSize: 10.5, color: Colors.grey[600])),
                  ],
                ),
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
