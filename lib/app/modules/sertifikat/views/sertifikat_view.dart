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
        title: const Text('Sertifikat Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() => _buildCertificateList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Cari sertifikat...',
          prefixIcon: const Icon(LucideIcons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateList() {
    if (controller.filteredCertificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.award, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              controller.selectedFilter.value == 'Terkunci'
                  ? 'Tidak ada sertifikat terkunci'
                  : 'Tidak ada sertifikat ditemukan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredCertificates.length,
      itemBuilder: (context, index) {
        final cert = controller.filteredCertificates[index];
        return _buildCertificateCard(cert);
      },
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  Icon(
                    cert['unlocked'] ? LucideIcons.award : LucideIcons.lock,
                    color: cert['unlocked'] ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cert['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (cert['unlocked'] && cert['score'] != null)
                    Chip(
                      label: Text('${cert['score']}/100'),
                      backgroundColor: Colors.green.withOpacity(0.1),
                      labelStyle: const TextStyle(color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(cert['description']),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    cert['date'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (cert['unlocked']) ...[
                    IconButton(
                      icon: const Icon(LucideIcons.download, size: 20),
                      onPressed: () => controller.downloadCertificate(cert['id']),
                      tooltip: 'Unduh',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.share2, size: 20),
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
      AlertDialog(
        title: const Text('Filter Sertifikat'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.filters.map((filter) => 
            RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: controller.selectedFilter.value,
              onChanged: (value) {
                controller.changeFilter(value!);
                Get.back();
              },
            ),
          ).toList(),
        )),
      ),
    );
  }
}