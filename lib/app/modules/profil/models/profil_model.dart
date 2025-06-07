class UserProfileModel {
  String name;
  String email;
  String username;
  String? avatarUrlOrPath;
  String joinedDate;
  String? lastLogin; // <-- TAMBAHKAN INI
  String? gender;
  String? occupation;
  String? authProvider;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.username,
    this.avatarUrlOrPath,
    required this.joinedDate,
    this.lastLogin, // <-- TAMBAHKAN INI
    this.gender,
    this.occupation,
    this.authProvider,
  });

  bool get isNetworkAvatar {
    if (avatarUrlOrPath == null || avatarUrlOrPath!.isEmpty) return false;
    return avatarUrlOrPath!.startsWith('http://') || avatarUrlOrPath!.startsWith('https://');
  }
}