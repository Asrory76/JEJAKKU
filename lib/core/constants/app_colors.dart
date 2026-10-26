import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF087789);
  static const Color primaryLight = Color(0xFFE8F4F6);
  static const Color primaryDark = Color(0xFF065C6A);

  // Background & Surface
  static const Color background = Color(0xFFF4FAFB);
  static const Color surface = Colors.white;
  static const Color canvas = Color.fromARGB(255, 240, 243, 244);

  // Text Colors (Verified WCAG AA compliant >= 4.5:1 on white & background)
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF596780);

  // Status & Indicators
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);
}
