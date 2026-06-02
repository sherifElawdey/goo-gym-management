import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark SaaS base
  static const scaffoldDark = Color(0xFF0B1220);
  static const surfaceDark = Color(0xFF141C2F);
  static const surfaceElevated = Color(0xFF1A2540);
  static const border = Color(0x33FFFFFF);
  static const glassFill = Color(0x1AFFFFFF);

  // Light variant
  static const scaffoldLight = Color(0xFFF0F4FA);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Accents
  static const primary = Color(0xFF4F8CFF);
  static const primaryLight = Color(0xFF7EB0FF);
  static const accentGreen = Color(0xFF22C55E);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const accentOrange = Color(0xFFF97316);

  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF64748B);

  static const gradientStart = Color(0xFF0B1220);
  static const gradientMid = Color(0xFF152238);
  static const gradientEnd = Color(0xFF1E3A5F);

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientMid, gradientEnd],
      );

  static LinearGradient get primaryButtonGradient => const LinearGradient(
        colors: [primary, Color(0xFF3B6FE8)],
      );

  static Color expiryUrgency(int days) {
    if (days <= 2) return accentRed;
    if (days <= 4) return accentAmber;
    return accentOrange;
  }
}
