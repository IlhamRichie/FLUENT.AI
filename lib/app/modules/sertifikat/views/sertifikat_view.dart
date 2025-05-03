import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:fluent_ai/app/modules/sertifikat/controllers/sertifikat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SertifikatView extends GetView<SertifikatController> {
  const SertifikatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sertifikat Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter, size: 20),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildSearchBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryFilter(),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('Daftar Sertifikat'),
          ),
          Obx(() => _buildCertificateList()),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => controller.searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Cari sertifikat...',
        prefixIcon: const Icon(LucideIcons.search, size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          borderSide: const BorderSide(color: Color(0xFFD84040)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = controller.filters[index];
            return _buildFilterChip(filter, controller.selectedFilter.value == filter);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.changeFilter(label),
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

  Widget _buildCertificateList() {
    final filtered = controller.filteredCertificates;
    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.award,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.selectedFilter.value == 'Terkunci'
                    ? 'Tidak ada sertifikat terkunci'
                    : 'Tidak ada sertifikat ditemukan',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cert = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCertificateCard(cert),
            );
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    final color = controller.parseColor(cert['color']);
    final bgColor = color.withOpacity(0.05);
    final isUnlocked = cert['unlocked'];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.viewCertificateDetails(cert),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isUnlocked ? LucideIcons.award : LucideIcons.lock,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cert['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isUnlocked && cert['score'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${cert['score']}/100',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cert['description'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    cert['date'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  if (isUnlocked) ...[
                    IconButton(
                      icon: Icon(
                        LucideIcons.download,
                        size: 18,
                        color: color,
                      ),
                      onPressed: () => controller.downloadCertificate(cert['id']),
                      tooltip: 'Unduh',
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.share2,
                        size: 18,
                        color: color,
                      ),
                      onPressed: () => controller.shareCertificate(cert['id']),
                      tooltip: 'Bagikan',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Sertifikat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: controller.filters
                      .map(
                        (filter) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: controller.selectedFilter.value == filter
                                  ? const Color(0xFFD84040)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          color: controller.selectedFilter.value == filter
                              ? const Color(0xFFD84040).withOpacity(0.05)
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              filter,
                              style: TextStyle(
                                color: controller.selectedFilter.value == filter
                                    ? const Color(0xFFD84040)
                                    : Colors.black,
                              ),
                            ),
                            trailing: controller.selectedFilter.value == filter
                                ? const Icon(
                                    LucideIcons.check,
                                    color: Color(0xFFD84040),
                                    size: 18,
                                  )
                                : null,
                            onTap: () {
                              controller.changeFilter(filter);
                              Get.back();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}