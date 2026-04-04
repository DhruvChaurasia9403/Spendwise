import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color darkBgMain = Color(0xFF0F172A);
  static const Color darkBgAccent = Color(0xFF1E1B4B);
  static const Color darkOrb = Color(0xFF6366F1);
  static const Color darkCard = Color(0xFF1E293B);

  static const Color lightBgMain = Color(0xFFF8FAFC);
  static const Color lightBgAccent = Color(0xFFE2E8F0);
  static const Color lightOrb = Color(0xFF93C5FD);
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color brandPurple = Color(0xFF8B5CF6);
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFF43F5E);

  static const double glassBlur = 15.0;
  static const double glassOpacity = 0.1;

  static Color bgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBgMain
          : lightBgMain;

  static Color orbColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkOrb
          : lightOrb;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF0F172A);

  static Color textDimColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : const Color(0xFF64748B);

  static Color glassColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withAlpha((0.05 * 255).toInt())
          : Colors.white.withAlpha((0.4 * 255).toInt());

  static Color glassBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withAlpha((0.1 * 255).toInt())
          : Colors.white.withAlpha((0.6 * 255).toInt());
}