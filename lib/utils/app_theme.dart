import 'package:flutter/material.dart';

class AppTheme {
  // Core palette
  static const Color primary = Color(0xFF1B3A6B);
  static const Color primaryLight = Color(0xFF2A5298);
  static const Color accent = Color(0xFFE8A020);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color caution = Color(0xFFF39C12);
  static const Color background = Color(0xFFF0F4F8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5F6368);

  // Game-mode accent colors
  static const Color modeQuiz = Color(0xFF1B3A6B);
  static const Color modeScenario = Color(0xFF6B3A9E);
  static const Color modeFlash = Color(0xFF1A7A5E);
  static const Color modeMatch = Color(0xFFD35400);
  static const Color modeOrder = Color(0xFF8E44AD);
  static const Color modeWhoAmI = Color(0xFF2C3E50);
  static const Color modeFox = Color.fromARGB(255, 26, 5, 145);

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryLight],
      );

  static LinearGradient gradientFor(Color c) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c, c.withValues(alpha: 0.7)],
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration elevatedCard(Color accentColor) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );
}
