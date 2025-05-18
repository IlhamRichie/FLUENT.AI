// lib/app/modules/profil/models/user_stats_model.dart
class UserStatsModel {
  final int totalSessions;
  final int consecutiveDays;
  final double averageScore;
  final int highestScore;

  UserStatsModel({
    required this.totalSessions,
    required this.consecutiveDays,
    required this.averageScore,
    required this.highestScore,
  });
}