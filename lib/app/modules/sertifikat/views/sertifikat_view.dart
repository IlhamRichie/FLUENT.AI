// lib/app/modules/sertifikat/views/sertifikat_view.dart
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:fluent_ai/app/modules/sertifikat/controllers/sertifikat_controller.dart';
import 'package:fluent_ai/app/modules/sertifikat/controllers/sertifikat_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class SertifikatView extends GetView<SertifikatController> {
  const SertifikatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50], // Warna latar belakang lebih lembut
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        title: const Text(
          'Sertifikat Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.filter, size: 22, color: Colors.grey[700]),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(LucideIcons.rotateCw, size: 22, color: Colors.grey[700]),
            onPressed: () => controller.fetchCertificates(), // Tombol Refresh
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildSearchBar(theme),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryFilter(theme),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            sliver: SliverToBoxAdapter(
              child: Obx(() => Text(
                    controller.isLoading.value 
                        ? 'Memuat Sertifikat...' 
                        : '${controller.filteredCertificates.length} Sertifikat Ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  )),
            ),
          ),
          Obx(() { // Ini adalah Obx utama yang akan menangani state list
            if (controller.isLoading.value) {
              return _buildShimmerList();
            }

            final filteredList = controller.filteredCertificates;
            if (filteredList.isEmpty) {
              return _buildEmptyState(theme);
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cert = filteredList[index];
                    return _buildCertificateCard(cert, theme);
                  },
                  childCount: filteredList.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24), // Padding bawah
          ),
        ],
      ),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      onChanged: (value) => controller.searchQuery.value = value,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        hintText: 'Cari berdasarkan judul atau deskripsi...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon: Icon(LucideIcons.search, size: 20, color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: controller.parseColor(controller.certificates.firstOrNull?.colorHex ?? '#D84040'), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return SizedBox(
      height: 50, // Tinggi ditambah untuk padding chip yang lebih baik
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.filters.length,
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            final isSelected = controller.selectedFilter.value == filter;
            final chipColor = controller.parseColor(controller.certificates.firstOrNull?.colorHex ?? '#D84040');

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => controller.changeFilter(filter),
                backgroundColor: Colors.white,
                selectedColor: chipColor.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected ? chipColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? chipColor : Colors.grey[300]!,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: isSelected ? 1 : 0,
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          },
          childCount: 5, // Jumlah shimmer item
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining( // Agar mengisi sisa ruang
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.folderSearch, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'Oops, Tidak Ada Sertifikat!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                controller.selectedFilter.value == 'Semua' && controller.searchQuery.value.isEmpty
                    ? 'Anda belum memiliki sertifikat apapun.'
                    : 'Tidak ada sertifikat yang cocok dengan filter atau pencarian Anda. Coba ubah kriteria.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
              if(controller.selectedFilter.value != 'Semua' || controller.searchQuery.value.isNotEmpty)
                ElevatedButton.icon(
                    icon: const Icon(LucideIcons.rotateCcw, size: 18),
                    label: const Text('Reset Filter'),
                    onPressed: (){
                        controller.selectedFilter.value = 'Semua';
                        controller.searchQuery.value = '';
                        // Jika search bar memiliki TextEditingController, clear juga
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: controller.parseColor(controller.certificates.firstOrNull?.colorHex ?? '#D84040'),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert, ThemeData theme) {
    final color = controller.parseColor(cert.colorHex);
    final isUnlocked = cert.unlocked;

    return Card(
      elevation: isUnlocked ? 2.5 : 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnlocked ? color.withOpacity(0.5) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      color: isUnlocked ? Colors.white : Colors.grey[200],
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.viewCertificateDetails(cert),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      cert.icon,
                      color: isUnlocked ? color : Colors.grey[600],
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isUnlocked ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked ? cert.date : 'Terkunci',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked && cert.score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Skor: ${cert.score}',
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (!isUnlocked)
                    Icon(LucideIcons.lock, color: Colors.grey[500], size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cert.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isUnlocked ? Colors.grey[700] : Colors.grey[600],
                  height: 1.4
                ),
              ),
              if (isUnlocked) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(LucideIcons.share2, 'Bagikan', color, () => controller.shareCertificate(cert.id)),
                    const SizedBox(width: 8),
                    _actionButton(LucideIcons.download, 'Unduh', color, () => controller.downloadCertificate(cert.id)),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // backgroundColor: color.withOpacity(0.05),
      ),
    );
  }

  void _showFilterDialog() { // Implementasi dialog filter (mirip sebelumnya, bisa disesuaikan)
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Sertifikat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: controller.filters.map((filter) {
                    final isSelected = controller.selectedFilter.value == filter;
                    final color = controller.parseColor(controller.certificates.firstOrNull?.colorHex ?? '#D84040');
                    return ListTile(
                      title: Text(filter, style: TextStyle(color: isSelected ? color : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      onTap: () {
                        controller.changeFilter(filter);
                        Get.back();
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      selected: isSelected,
                      selectedTileColor: color.withOpacity(0.1),
                      trailing: isSelected ? Icon(LucideIcons.checkCircle, color: color, size: 20) : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}