// lib/app/modules/profil/models/profil_model.dart

class UserProfileModel {
  String name; // Dijadikan non-nullable, karena akan diisi dari username jika name asli null
  final String email;
  String username; // Dijadikan non-nullable
  String avatarAsset; // Dijadikan non-nullable, akan ada path default
  final String joinedDate;
  String? gender; // Opsional
  String? occupation; // Opsional

  UserProfileModel({
    required this.name,
    required this.email,
    required this.username,
    required this.avatarAsset,
    required this.joinedDate,
    this.gender, // Tambahkan parameter ini
    this.occupation, // Tambahkan parameter ini
  });
}