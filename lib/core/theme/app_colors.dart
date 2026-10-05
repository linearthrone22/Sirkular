import 'package:flutter/material.dart';

/// Sirkular palette. The UI is monochrome; the two brand accents are reserved
/// for specific meanings so they stay exclusive.
class AppColors {
  AppColors._();

  // Monochrome base
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111111);
  static const muted = Color(0xFF8A8F98);
  static const border = Color(0xFFE5E7EB);

  // Brand accents (approximated from logo.png)
  /// Success indicators only (toggle on, positive trend, "Zero Waste" badge).
  static const mint = Color(0xFF4AD39A);

  /// AI-related actions and icons only (e.g. "Generate AI R&D", spark icon).
  static const purple = Color(0xFF5530D8);

  // Supporting tones
  static const mintDeep = Color(0xFF23A97A); // gradient end, text-safe on purple
  static const mintSoft = Color(0xFFE3F8EF); // badge and avatar background
  static const purpleLight = Color(0xFFB4A3FF); // AI icons on the dark sidebar
  static const sidebar = Color(0xFF1A1333); // deep purple, near black
  static const orange = Color(0xFFF59E4B); // Shopee and "packing" status
  static const danger = Color(0xFFE5484D); // expired or waste alerts
}
