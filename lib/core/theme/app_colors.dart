import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary (Koyu/Modern)
  static const Color primary = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFF2E2E4E);
  static const Color primaryDark = Color(0xFF0F0F1A);

  // Secondary (Lime/Vibrant)
  static const Color secondary = Color(0xFFD2FF57);
  static const Color secondaryLight = Color(0xFFE1FF85);
  static const Color secondaryDark = Color(0xFFB5E63A);

  // Accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF90A4);

  // Background
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F9);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1A1A2E);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF1A1A2E);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Swipe actions
  static const Color swipeLike = Color(0xFF10B981);
  static const Color swipePass = Color(0xFFEF4444);
  static const Color swipeSuperLike = Color(0xFF3B82F6);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x1A1A1A2E);

  // Gradients
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];
  static const List<Color> cardGradient = [Colors.transparent, Color(0xCC1A1A2E)];
}
