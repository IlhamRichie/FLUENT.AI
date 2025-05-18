// lib/app/modules/profil/models/settings_model.dart
import 'package:flutter/material.dart'; // Untuk IconData

class SettingsItemModel {
  final String title;
  final IconData icon;
  final String action; // Untuk identifikasi aksi saat onTap
  dynamic value; // Bisa String (untuk info) atau bool (untuk Switch)
  final bool isSwitch;

  SettingsItemModel({
    required this.title,
    required this.icon,
    required this.action,
    this.value,
    this.isSwitch = false,
  });
}

class SettingsSectionModel {
  final String title;
  final List<SettingsItemModel> items;

  SettingsSectionModel({required this.title, required this.items});
}