import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (from logo)
  static const Color navyBlue = Color(0xFF1A3A6B);
  static const Color navyBlueDark = Color(0xFF0F2347);
  static const Color lightBlue = Color(0xFF4DB8E8);
  static const Color skyBlue = Color(0xFF7DD4F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F8FF);

  // Semantic Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Status Colors
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusInProgress = Color(0xFF3498DB);
  static const Color statusCompleted = Color(0xFF2ECC71);
  static const Color statusCancelled = Color(0xFFE74C3C);
  static const Color statusPaymentApproved = Color(0xFF27AE60);

  // Light Theme Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF0F6FF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0EAF5);

  // Dark Theme Surfaces
  static const Color surfaceDark = Color(0xFF1E2D45);
  static const Color backgroundDark = Color(0xFF0F1C2E);
  static const Color cardDark = Color(0xFF1E2D45);
  static const Color dividerDark = Color(0xFF2A3F5F);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A3A6B);
  static const Color textSecondaryLight = Color(0xFF5A7A9F);
  static const Color textPrimaryDark = Color(0xFFE8F4FF);
  static const Color textSecondaryDark = Color(0xFF8BAFD4);

  // Gradient
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyBlue, Color(0xFF2563EB)],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBlue, skyBlue],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
  );
}
