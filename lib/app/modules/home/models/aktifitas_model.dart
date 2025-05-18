// lib/app/modules/home/models/activity_model.dart
import 'package:flutter/material.dart'; // Untuk IconData

class ActivityModel {
  final String id;
  final String title;
  final String date;
  final int score;
  final IconData icon;
  final String colorHex; // Warna untuk aksen

  ActivityModel({
    required this.id,
    required this.title,
    required this.date,
    required this.score,
    required this.icon,
    required this.colorHex,
  });
}