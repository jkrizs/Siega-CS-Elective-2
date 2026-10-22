import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF0072A0);
  static const Color primaryBlueDark = Color(0xFF38BDF8);
  static const Color primaryHeaderTab = Color(0xFFE2DC88);
  static const Color primaryHeaderTabDark = Color(0xFFC0A448);
  static const Color headerText = Color(0xFF282828);

  static const Color retroGold = Color(0xFFE8E088);
  static const Color retroGoldGlow = Color(0xFFFFD54F);
  static const Color retroGoldBorder = Color(0xFFFACC15);

  static const Color dayScaffoldBg = Color(0xFFDED4F2);
  static const Color dayHeaderBg = Color(0xFF0072A0);
  static const Color dayHeaderBorder = Color(0xFF1E2838);
  static const Color dayFilterBarBg = Color(0xFF2C384E);
  static const Color dayFilterBarBorder = Color(0xFF1E2838);
  static const Color dayFilterChipBorder = Color(0xFF1E2430);
  static const Color dayCardBg = Color(0xFFEDE8F8);
  static const Color dayCardBorder = Color(0xFF2E3440);
  static const Color dayCardHeaderBg = Color(0xFF3B4860);
  static const Color dayCardHeaderBorder = Color(0xFF222834);
  static const Color dayPhotoBoxBg = Color(0xFFF9FAFC);
  static const Color dayPhotoBoxBorder = Color(0xFF707C94);
  static const Color dayCardFooterBg = Color(0xFFE2DCF0);
  static const Color dayCardFooterBorder = Color(0xFFC4BCD8);
  static const Color dayTextPrimary = Color(0xFF1E2430);
  static const Color dayTextSecondary = Color(0xFF6E788C);
  static const Color dayScanline = Color(0x12000000);
  static const Color dayDialogueOuterBg = Color(0xFFF8F9FA);
  static const Color dayDialogueOuterBorder = Color(0xFF333B4A);
  static const Color dayDialogueInnerBg = Colors.white;
  static const Color dayDialogueInnerBorder = Color(0xFFB0B8C8);
  static const Color dayArrowButtonBg = Color(0xFF1E2434);

  static const Color nightScaffoldBg = Color(0xFF0F131C);
  static const Color nightHeaderBg = Color(0xFF16202E);
  static const Color nightHeaderBorder = Color(0xFF243044);
  static const Color nightFilterBarBg = Color(0xFF131A26);
  static const Color nightFilterBarBorder = Color(0xFF202A3C);
  static const Color nightFilterChipBorder = Color(0xFF334155);
  static const Color nightCardBg = Color(0xFF1E2532);
  static const Color nightCardBorder = Color(0xFF3B4860);
  static const Color nightCardHeaderBg = Color(0xFF151C28);
  static const Color nightCardHeaderBorder = Color(0xFF242E40);
  static const Color nightPhotoBoxBg = Color(0xFF111722);
  static const Color nightPhotoBoxBorder = Color(0xFF475569);
  static const Color nightCardFooterBg = Color(0xFF161E2C);
  static const Color nightCardFooterBorder = Color(0xFF242E40);
  static const Color nightTextPrimary = Color(0xFFF8FAFC);
  static const Color nightTextSecondary = Color(0xFFCBD5E1);
  static const Color nightScanline = Color(0x10FFFFFF);
  static const Color nightDialogueOuterBg = Color(0xFF1E2430);
  static const Color nightDialogueOuterBorder = Color(0xFF4A5568);
  static const Color nightDialogueInnerBg = Color(0xFF141922);
  static const Color nightDialogueInnerBorder = Color(0xFF2D3748);
  static const Color nightArrowButtonBg = Color(0xFF1E283A);

  static const Color hpGaugeHigh = Color(0xFF48D078);
  static const Color hpGaugeMedium = Color(0xFFF8D030);
  static const Color hpGaugeLow = Color(0xFFF85848);
  static const Color hpBarBg = Color(0xFF404040);
  static const Color hpBarBorder = Color(0xFF202020);
  static const Color hpLabelText = Color(0xFFD48820);

  static const Color genderFemale = Color(0xFFFF70A0);
  static const Color genderMale = Color(0xFF60B8FF);

  static const Color pokeballRed = Color(0xFFE53935);
  static const Color pokeballWhite = Color(0xFFF5F5F5);
  static const Color pokeballBand = Color(0xFF1E2028);

  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorRedDark = Color(0xFFB71C1C);
  static const Color errorBg = Color(0xFFFFEBEE);

  static Color scaffoldBg(bool isDark) => isDark ? nightScaffoldBg : dayScaffoldBg;
  static Color headerBg(bool isDark) => isDark ? nightHeaderBg : dayHeaderBg;
  static Color headerTabBg(bool isDark) => isDark ? primaryHeaderTabDark : primaryHeaderTab;
  static Color headerBorder(bool isDark) => isDark ? nightHeaderBorder : dayHeaderBorder;
  static Color filterBarBg(bool isDark) => isDark ? nightFilterBarBg : dayFilterBarBg;
  static Color filterBarBorder(bool isDark) => isDark ? nightFilterBarBorder : dayFilterBarBorder;
  static Color filterChipBorder(bool isDark) => isDark ? nightFilterChipBorder : dayFilterChipBorder;
  static Color cardBg(bool isDark) => isDark ? nightCardBg : dayCardBg;
  static Color cardBorder(bool isDark) => isDark ? nightCardBorder : dayCardBorder;
  static Color cardHeaderBg(bool isDark) => isDark ? nightCardHeaderBg : dayCardHeaderBg;
  static Color cardHeaderBorder(bool isDark) => isDark ? nightCardHeaderBorder : dayCardHeaderBorder;
  static Color photoBoxBg(bool isDark) => isDark ? nightPhotoBoxBg : dayPhotoBoxBg;
  static Color photoBoxBorder(bool isDark) => isDark ? nightPhotoBoxBorder : dayPhotoBoxBorder;
  static Color cardFooterBg(bool isDark) => isDark ? nightCardFooterBg : dayCardFooterBg;
  static Color cardFooterBorder(bool isDark) => isDark ? nightCardFooterBorder : dayCardFooterBorder;
  static Color textPrimary(bool isDark) => isDark ? nightTextPrimary : dayTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? nightTextSecondary : dayTextSecondary;
  static Color scanline(bool isDark) => isDark ? nightScanline : dayScanline;
  static Color arrowButtonBg(bool isDark) => isDark ? nightArrowButtonBg : dayArrowButtonBg;
  static Color arrowColor(bool isDark) => isDark ? retroGoldGlow : retroGold;
  static Color dialogueOuterBg(bool isDark) => isDark ? nightDialogueOuterBg : dayDialogueOuterBg;
  static Color dialogueOuterBorder(bool isDark) => isDark ? nightDialogueOuterBorder : dayDialogueOuterBorder;
  static Color dialogueInnerBg(bool isDark) => isDark ? nightDialogueInnerBg : dayDialogueInnerBg;
  static Color dialogueInnerBorder(bool isDark) => isDark ? nightDialogueInnerBorder : dayDialogueInnerBorder;
}

class PokemonTypeColors {
  PokemonTypeColors._();

  static const List<String> allFilterTypes = [
    'ALL',
    'FIRE',
    'POISON',
    'WATER',
    'GRASS',
    'BUG',
    'NORMAL',
    'ELECTRIC',
    'GROUND',
    'FLYING',
  ];

  static const Map<String, Color> _typeMap = {
    'FIRE': Color(0xFFE05228),
    'POISON': Color(0xFF8A3B8C),
    'WATER': Color(0xFF3B82C4),
    'GRASS': Color(0xFF5CA444),
    'ELECTRIC': Color(0xFFDCA618),
    'BUG': Color(0xFF8E9C22),
    'NORMAL': Color(0xFF8A8868),
    'GROUND': Color(0xFFC09B42),
    'FLYING': Color(0xFF7A8CC8),
    'PSYCHIC': Color(0xFFE04A72),
    'DARK': Color(0xFF4C5866),
    'ALL': Color(0xFF3B4860),
  };

  static Color getColor(String type) {
    return _typeMap[type.toUpperCase()] ?? const Color(0xFF6B7280);
  }
}
