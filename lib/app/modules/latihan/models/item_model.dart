// lib/app/modules/latihan/models/latihan_item_model.dart
class LatihanItemModel {
  final String id;
  final String judul;
  final String kategori; // Nama kategori (untuk mencocokkan ikon & warna)
  final String level;
  final String terakhirDilakukan;
  final int? skor;
  final String warna; // Hex color string (bisa diambil dari kategori atau spesifik)

  LatihanItemModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.level,
    required this.terakhirDilakukan,
    this.skor,
    required this.warna,
  });
}