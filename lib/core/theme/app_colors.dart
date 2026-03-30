import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Main Brand Colors ────────────────────────────────────────────

  // Primary: Coral / Orange-Red  (#FF4D2A)
  static const Color primary = Color(0xFFFF4D2A);
  static const Color primaryLight = Color(0xFFFF7558);
  static const Color primaryDark = Color(0xFFCC3C21);

  // Secondary: Electric Blue  (#235EDE)
  static const Color secondary = Color(0xFF235EDE);
  static const Color secondaryLight = Color(0xFF4D7FE8);
  static const Color secondaryDark = Color(0xFF1A4BB5);

  // Accent: Lime Green  (#9CDE23)
  static const Color accent = Color(0xFF9CDE23);
  static const Color accentLight = Color(0xFFB4E84D);
  static const Color accentDark = Color(0xFF7EB51C);

  // ─── Auxiliary Colors ─────────────────────────────────────────────

  static const Color auxOlive = Color(0xFF708944); // olive green
  static const Color auxBrown = Color(0xFF5E443E); // warm brown
  static const Color auxSlate = Color(0xFF3E485E); // slate blue-gray

  // ─── Background ───────────────────────────────────────────────────

  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F9);

  // ─── Text ─────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // white on coral
  static const Color textOnSecondary = Color(0xFFFFFFFF); // white on blue
  static const Color textOnAccent = Color(0xFF1A1A2E);   // dark on lime

  // ─── Border ───────────────────────────────────────────────────────

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFFFF4D2A);

  // ─── Status ───────────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF235EDE); // mapped to secondary blue

  // ─── Swipe Actions ────────────────────────────────────────────────

  static const Color swipeLike = Color(0xFF9CDE23);    // lime = like
  static const Color swipePass = Color(0xFFEF4444);    // red = pass
  static const Color swipeSuperLike = Color(0xFF235EDE); // blue = super like

  // ─── Overlay ──────────────────────────────────────────────────────

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x1AFF4D2A); // subtle coral tint

  // ─── Gradients ────────────────────────────────────────────────────

  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  static const List<Color> accentGradient = [accent, accentDark];
  static const List<Color> cardGradient = [Colors.transparent, Color(0xCC0A0A14)];
}
