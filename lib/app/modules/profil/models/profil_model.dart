// lib/app/modules/profil/models/user_profile_model.dart
class UserProfileModel {
  final String name;
  final String email;
  final String username;
  final String avatarAsset; // Path ke aset avatar
  final String joinedDate;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.username,
    required this.avatarAsset,
    required this.joinedDate,
  });
}