import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.dayScaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.retroGold,
        surface: AppColors.dayScaffoldBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dayHeaderBg,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.nightScaffoldBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlueDark,
        secondary: AppColors.retroGoldGlow,
        surface: AppColors.nightScaffoldBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.nightHeaderBg,
        elevation: 0,
      ),
    );
  }
}
