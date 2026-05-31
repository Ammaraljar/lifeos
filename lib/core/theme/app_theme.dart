import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF16213E);
  static const Color surface = Color(0xFF1F2B47);
  static const Color card = Color(0xFF243050);
  static const Color highlight = Color(0xFF4F8EF7);
  static const Color gold = Color(0xFFFFB347);
  static const Color green = Color(0xFF00C896);
  static const Color purple = Color(0xFF9C27B0);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF00BCD4);

  // Text
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8E9AC0);
  static const Color textMuted = Color(0xFF4A5580);

  // Background
  static const Color background = Color(0xFF0D1117);

  // Status
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF4F8EF7);

  // Category colors
  static const Color spiritual = Color(0xFF9C6FDE);
  static const Color english = Color(0xFF4F8EF7);
  static const Color fitness = Color(0xFF00C896);
  static const Color business = Color(0xFFFFB347);
  static const Color family = Color(0xFFFF6B6B);
  static const Color knowledge = Color(0xFF00BCD4);
}

class AppTheme {
  static ThemeData darkTheme() => _build(Brightness.dark);
  static ThemeData lightTheme() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.background : const Color(0xFFF5F7FF),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.highlight,
        onPrimary: Colors.white,
        secondary: AppColors.green,
        onSecondary: Colors.white,
        surface: isDark ? AppColors.surface : Colors.white,
        onSurface: isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E),
        error: AppColors.error,
        onError: Colors.white,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.background : const Color(0xFFF5F7FF),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? AppColors.textPrimary : AppColors.primary),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.primary,
          fontSize: 20, fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: isDark ? AppColors.card : Colors.white,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class AppConstants {
  static const String hiveHabitBox = 'habits_v2';
  static const String hiveLogBox = 'habit_logs_v2';
  static const String hiveBehaviorBox = 'behaviors_v2';
  static const String settingsLanguage = 'lang';
  static const String settingsDarkMode = 'dark';
  static const String settingsApiKey = 'api_key';
  static const int quranPagesPerYear = 1460;
  static const int prayersPerDay = 5;
}
