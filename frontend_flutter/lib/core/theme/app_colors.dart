import 'package:flutter/material.dart';

/// Palet Warna Resmi Solvexa Mobile - Universitas Trilogi
/// Sesuai PRD Bagian 3.1 (Design System)
class SolvexaColors {
  SolvexaColors._();

  // Primary & Accent
  static const Color primaryNavy = Color(0xFF0F1D33);
  static const Color primaryNavyLight = Color(0xFF1E3252);
  static const Color accentAmber = Color(0xFFF5B400);
  static const Color accentAmberSoft = Color(0xFFFEF3C7);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF1F5F9);
  static const Color unreadCardBg = Color(0xFFEEF4FF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Semantic Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successBadgeBg = Color(0xFFD1FAE5);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBadgeBg = Color(0xFFFEF3C7);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerBadgeBg = Color(0xFFFEE2E2);

  // Text Hierarchy
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradient Kartu Status Penanganan Aktif
  static const LinearGradient activeStatusGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F1D33),
      Color(0xFF162B49),
      Color(0xFF243B55),
    ],
  );
}
