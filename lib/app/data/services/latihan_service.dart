import 'package:get/get.dart';

class LatihanService extends GetxService {
  Future<List<Map<String, dynamic>>> getLatihanKategori() async {
    // Simulasi API call
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        'id': 1,
        'nama': 'Simulasi Wawancara AI',
        'deskripsi': 'Latihan wawancara dengan berbagai skenario menggunakan AI',
        'ikon': 'interview',
        'level': ['Mudah', 'Medium', 'Sulit'],
        'warna': '#4285F4',
      },
      {
        'id': 2,
        'nama': 'Public Speaking',
        'deskripsi': 'Latihan presentasi ala TED Talk',
        'ikon': 'public_speaking',
        'level': ['Medium', 'Sulit'],
        'warna': '#34A853',
      },
      {
        'id': 3,
        'nama': 'Ekspresi & Gestur',
        'deskripsi': 'Perbaikan ekspresi wajah dan bahasa tubuh',
        'ikon': 'expression',
        'level': ['Mudah', 'Medium'],
        'warna': '#FBBC05',
      },
      {
        'id': 4,
        'nama': 'Filler Word',
        'deskripsi': 'Mengurangi kata pengisi seperti "eh", "anu", dll',
        'ikon': 'filler_word',
        'level': ['Mudah'],
        'warna': '#EA4335',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getLatihanTerbaru() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'id': 101,
        'kategori': 'Simulasi Wawancara AI',
        'judul': 'Wawancara Mobile Developer',
        'level': 'Medium',
        'terakhir_dilakukan': '2 jam lalu',
        'skor': 78,
        'warna': '#4285F4',
      },
      {
        'id': 102,
        'kategori': 'Public Speaking',
        'judul': 'Presentasi Produk Baru',
        'level': 'Sulit',
        'terakhir_dilakukan': 'Kemarin',
        'skor': 65,
        'warna': '#34A853',
      },
      {
        'id': 103,
        'kategori': 'Ekspresi & Gestur',
        'judul': 'Ekspresi Wajah Positif',
        'level': 'Mudah',
        'terakhir_dilakukan': '3 hari lalu',
        'skor': 88,
        'warna': '#FBBC05',
      },
    ];
  }
}