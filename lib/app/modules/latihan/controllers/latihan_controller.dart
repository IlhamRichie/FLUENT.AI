// lib/app/modules/latihan/controllers/latihan_controller.dart
import 'package:fluent_ai/app/modules/latihan/models/item_model.dart';
import 'package:fluent_ai/app/modules/latihan/models/kategori_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LatihanController extends GetxController {
  final isLoading = true.obs;
  final selectedCategory = 'Semua'.obs;

  final RxList<KategoriLatihanModel> semuaKategoriLatihan = <KategoriLatihanModel>[].obs;
  final RxList<LatihanItemModel> semuaLatihanTerbaru = <LatihanItemModel>[].obs;

  // Getter untuk kategori yang difilter (jika perlu, tapi di view juga bisa)
  List<KategoriLatihanModel> get kategoriLatihan {
    if (selectedCategory.value == 'Semua') {
      return semuaKategoriLatihan;
    }
    return semuaKategoriLatihan.where((k) => k.nama == selectedCategory.value).toList();
  }

  // Getter untuk latihan terbaru yang difilter
  List<LatihanItemModel> get latihanTerbaru {
     if (selectedCategory.value == 'Semua') {
      return semuaLatihanTerbaru.take(5).toList(); // Ambil 5 terbaru jika 'Semua'
    }
    // Filter berdasarkan kategori dan ambil beberapa item teratas
    return semuaLatihanTerbaru.where((l) => l.kategori == selectedCategory.value).take(3).toList();
  }
  
  List<String> get filterOptions => ['Semua', ...semuaKategoriLatihan.map((k) => k.nama).toSet().toList()];


  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulasi loading

    _loadKategoriLatihan();
    _loadLatihanTerbaru();

    isLoading.value = false;
  }

  void _loadKategoriLatihan() {
    semuaKategoriLatihan.assignAll([
      KategoriLatihanModel(id: 'cat-1', nama: 'Wawancara Kerja', deskripsi: 'Simulasi tanya jawab untuk persiapan wawancara.', ikon: 'briefcase', warna: '#2980B9', level: ['Pemula', 'Menengah'], jumlahSesi: 12),
      KategoriLatihanModel(id: 'cat-2', nama: 'Public Speaking', deskripsi: 'Latih kemampuan berbicara di depan umum.', ikon: 'mic2', warna: '#27AE60', level: ['Menengah', 'Mahir'], jumlahSesi: 8),
      KategoriLatihanModel(id: 'cat-3', nama: 'Ekspresi & Intonasi', deskripsi: 'Tingkatkan cara penyampaian pesan verbal.', ikon: 'smile', warna: '#E67E22', level: ['Pemula'], jumlahSesi: 5),
      KategoriLatihanModel(id: 'cat-4', nama: 'Debat Terstruktur', deskripsi: 'Asah argumen dan kemampuan berpikir kritis.', ikon: 'swords', warna: '#8E44AD', level: ['Mahir'], jumlahSesi: 7),
      KategoriLatihanModel(id: 'cat-5', nama: 'Percakapan Harian', deskripsi: 'Latihan dialog untuk situasi sehari-hari.', ikon: 'messagesSquare', warna: '#F39C12', level: ['Pemula', 'Menengah'], jumlahSesi: 15),
    ]);
  }

  void _loadLatihanTerbaru() {
    semuaLatihanTerbaru.assignAll([
      LatihanItemModel(id: 'lt-1', judul: 'Wawancara Posisi Marketing', kategori: 'Wawancara Kerja', level: 'Menengah', terakhirDilakukan: 'Kemarin', skor: 88, warna: '#2980B9'),
      LatihanItemModel(id: 'lt-2', judul: 'Pidato Pembukaan Acara', kategori: 'Public Speaking', level: 'Mahir', terakhirDilakukan: '2 hari lalu', skor: 92, warna: '#27AE60'),
      LatihanItemModel(id: 'lt-3', judul: 'Menyampaikan Kabar Buruk', kategori: 'Ekspresi & Intonasi', level: 'Pemula', terakhirDilakukan: '3 hari lalu', skor: 75, warna: '#E67E22'),
      LatihanItemModel(id: 'lt-4', judul: 'Simulasi Negosiasi Gaji', kategori: 'Wawancara Kerja', level: 'Mahir', terakhirDilakukan: '5 hari lalu', skor: 85, warna: '#2980B9'),
      LatihanItemModel(id: 'lt-5', judul: 'Presentasi Produk Baru', kategori: 'Public Speaking', level: 'Menengah', terakhirDilakukan: 'Minggu lalu', skor: 80, warna: '#27AE60'),
      LatihanItemModel(id: 'lt-6', judul: 'Argumen Pro Kontra AI', kategori: 'Debat Terstruktur', level: 'Mahir', terakhirDilakukan: 'Baru saja', skor: 95, warna: '#8E44AD'),
      LatihanItemModel(id: 'lt-7', judul: 'Memesan Makanan di Restoran', kategori: 'Percakapan Harian', level: 'Pemula', terakhirDilakukan: 'Kemarin', skor: 78, warna: '#F39C12'),
    ]);
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    // Tidak perlu refreshData() di sini jika getter sudah reaktif
  }

  void startLatihanKategori(KategoriLatihanModel kategori) {
    Get.snackbar('Mulai Latihan', 'Memulai latihan untuk kategori: ${kategori.nama}',
      backgroundColor: parseColor(kategori.warna).withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(getCategoryIcon(kategori.ikon), color: Colors.white),
    );
    // Navigasi ke halaman detail latihan kategori
  }
  
  void startLatihanItem(LatihanItemModel latihan) {
     Get.snackbar('Lanjutkan Latihan', 'Melanjutkan latihan: ${latihan.judul}',
      backgroundColor: parseColor(latihan.warna).withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(getCategoryIcon(latihan.kategori, isFromItem: true), color: Colors.white),
    );
    // Navigasi ke halaman sesi latihan
  }

  IconData getCategoryIcon(String iconName, {bool isFromItem = false}) {
    // Jika dari item, iconName adalah nama kategori, kita perlu mapping ke nama ikon di KategoriLatihanModel
    String actualIconName = iconName;
    if(isFromItem){
        final kategoriModel = semuaKategoriLatihan.firstWhereOrNull((k) => k.nama == iconName);
        if(kategoriModel != null){
            actualIconName = kategoriModel.ikon;
        }
    }

    switch (actualIconName.toLowerCase()) {
      case 'briefcase': return LucideIcons.briefcase;
      case 'mic2': return LucideIcons.mic2;
      case 'smile': return LucideIcons.smile;
      case 'type': return LucideIcons.type; // Untuk filler word jika ada
      case 'swords': return LucideIcons.swords;
      case 'messagesSquare': return LucideIcons.messagesSquare;
      default: return LucideIcons.box; // Ikon default jika tidak cocok
    }
  }

  Color parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFFD84040);
    }
  }
}