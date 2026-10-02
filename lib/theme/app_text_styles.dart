import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized monospace typography system matching classic Game Boy Advance
/// and Nintendo DS Pokémon games.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'monospace';

  // --- Header Styles ---
  static const TextStyle headerTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: AppColors.headerText,
    shadows: [
      Shadow(
        color: Colors.white,
        offset: Offset(1, 1),
        blurRadius: 0,
      ),
    ],
  );

  // --- Pokémon Card Styles ---
  static const TextStyle pokemonId = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w900,
    color: AppColors.retroGold,
    letterSpacing: 0.5,
  );

  static TextStyle pokemonName(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: AppColors.textPrimary(isDark),
      );

  static const TextStyle hpLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8.5,
    fontWeight: FontWeight.w900,
    color: AppColors.hpLabelText,
  );

  static TextStyle hpRatio(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary(isDark),
      );

  static const TextStyle genderMale = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: AppColors.genderMale,
  );

  static const TextStyle genderFemale = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: AppColors.genderFemale,
  );

  // --- Filter Bar Styles ---
  static TextStyle filterChip({required bool isSelected}) => TextStyle(
        fontFamily: fontFamily,
        color: isSelected ? Colors.white : const Color(0xFFD4DAE8),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      );

  // --- Type Badge Styles ---
  static const TextStyle typeBadge = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontSize: 9.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    shadows: [
      Shadow(
        color: Colors.black54,
        offset: Offset(1, 1),
        blurRadius: 0,
      ),
    ],
  );

  // --- Dialogue & State Messages ---
  static const TextStyle dialogueTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    color: AppColors.dayTextPrimary,
  );

  static const TextStyle dialogueSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: AppColors.dayTextSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle retroButton = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.retroGold,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
  );
}
