// lib/app/modules/sertifikat/models/certificate_model.dart
import 'package:flutter/material.dart'; // Untuk IconData

class CertificateModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final int? score;
  final bool unlocked;
  final String colorHex;
  final IconData icon;

  CertificateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.score,
    required this.unlocked,
    required this.colorHex,
    required this.icon,
  });
}