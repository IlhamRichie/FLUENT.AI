// lib/app/modules/profil/models/profil_model.dart

class UserProfileModel {
  String name; // Nama tampilan, bisa dari Google name atau username
  String email;
  String username; // Username unik sistem
  String? avatarUrlOrPath; // Bisa URL dari Google/upload, atau path aset lokal
  String joinedDate;
  String? gender;
  String? occupation;
  String? authProvider; // 'google', 'local', dll.

  UserProfileModel({
    required this.name,
    required this.email,
    required this.username,
    this.avatarUrlOrPath,
    required this.joinedDate,
    this.gender,
    this.occupation,
    this.authProvider,
  });

  // Helper untuk menentukan apakah avatar adalah network image atau local asset
  bool get isNetworkAvatar {
    if (avatarUrlOrPath == null || avatarUrlOrPath!.isEmpty) return false;
    return avatarUrlOrPath!.startsWith('http://') || avatarUrlOrPath!.startsWith('https://');
  }
}