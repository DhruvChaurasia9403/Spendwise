import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color backgroundDark = Color(0xFF1E1E2C);
  static const Color backgroundMid = Color(0xFF2D2B4A);
  static const Color brandPurple = Color(0xFF4B3E7C);

  static const Color incomeGreen = Colors.greenAccent;
  static const Color expenseRed = Colors.redAccent;

  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundDark,
      backgroundMid,
      brandPurple,
    ],
  );

  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.15;
}