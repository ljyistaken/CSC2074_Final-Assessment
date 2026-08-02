import 'package:flutter/material.dart';

abstract final class AppColors {
  static const red = Color(0xFFEF3633);
  static const redDark = Color(0xFFC91F22);
  static const ink = Color(0xFF242424);
  static const muted = Color(0xFF737B8C);
  static const border = Color(0xFFD9DEE7);
  static const soft = Color(0xFFFFF4F1);
  static const surface = Color(0xFFF7F8FA);
  static const success = Color(0xFF2E8B3C);
  static const warning = Color(0xFFFF6B35);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
      primary: AppColors.red,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 17,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 15,
          height: 1.45,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.red, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
