// lib/app/modules/latihan/models/kategori_latihan_model.dart
// Untuk IconData

class KategoriLatihanModel {
  final String id;
  final String nama;
  final String deskripsi;
  final String ikon; // Nama ikon dari LucideIcons (akan di-parse)
  final String warna; // Hex color string
  final List<String> level;
  final int jumlahSesi; // Tambahan: info jumlah sesi

  KategoriLatihanModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
    required this.level,
    required this.jumlahSesi,
  });
}