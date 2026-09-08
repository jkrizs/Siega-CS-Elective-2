import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFC04B50);
  static const Color primaryLight = Color(0xFFD66B70);
  static const Color primaryDark = Color(0xFFA0363B);
  static const Color ratingStar = Color(0xFFFFB800);
  static const Color success = Color(0xFF2E7D32);

  static const Color lightScaffold = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFEEEEEE);
  static const Color lightBorderStrong = Color(0xFFDDDDDD);
  static const Color lightTextPrimary = Color(0xFF191919);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextMuted = Color(0xFF9E9E9E);
  static const Color lightPrimaryContainer = Color(0xFFFFEBEE);
  static const Color lightOnPrimaryContainer = Color(0xFFC04B50);

  static const Color lightCardBlue = Color(0xFFE5EFF5);
  static const Color lightCardRed = Color(0xFFFCEEED);
  static const Color lightCardTeal = Color(0xFFD6EEEC);
  static const Color lightCardAmber = Color(0xFFF5F3ED);

  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkBorderStrong = Color(0xFF444444);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextMuted = Color(0xFF777777);
  static const Color darkPrimaryContainer = Color(0xFF3E1F21);
  static const Color darkOnPrimaryContainer = Color(0xFFFFCDD2);

  static const Color darkCardBlue = Color(0xFF1E2830);
  static const Color darkCardRed = Color(0xFF2A1C1D);
  static const Color darkCardTeal = Color(0xFF1B2E2D);
  static const Color darkCardAmber = Color(0xFF28251E);

  static const Color footerBackground = Color(0xFF191919);
  static const Color footerInput = Color(0xFF2B2B2B);
  static const Color footerBorder = Color(0xFF2E2E2E);
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
  );

  static const TextStyle heroHeadline = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.1,
  );

  static const TextStyle heroSubhead = TextStyle(
    color: Colors.white70,
    fontSize: 13,
    height: 1.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle productTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle productPrice = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle productBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  static const TextStyle announcement = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}

class AppButtonStyles {
  static final ButtonStyle elevatedLight = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightTextPrimary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      letterSpacing: 0.5,
    ),
  );

  static final ButtonStyle elevatedDark = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.lightTextPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      letterSpacing: 0.5,
    ),
  );

  static final ButtonStyle outlinedLight = OutlinedButton.styleFrom(
    foregroundColor: AppColors.lightTextPrimary,
    side: const BorderSide(color: AppColors.lightBorderStrong),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  );

  static final ButtonStyle outlinedDark = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: AppColors.darkBorderStrong),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  );

  static final ButtonStyle pillHero = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 3,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightScaffold,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedLight,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedLight,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkScaffold,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedDark,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedDark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF222222),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
    );
  }

  static Color collectionCardBackground(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (index % 3) {
      case 0:
        return isDark ? AppColors.darkCardRed : AppColors.lightCardRed;
      case 1:
        return isDark ? AppColors.darkCardAmber : AppColors.lightCardAmber;
      case 2:
      default:
        return isDark ? AppColors.darkCardTeal : AppColors.lightCardTeal;
    }
  }

  static Color fieldNoteBackground(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (index % 2 == 0) {
      return isDark ? AppColors.darkCardTeal : AppColors.lightCardTeal;
    }
    return isDark ? AppColors.darkCardRed : AppColors.lightCardRed;
  }

  static Color editorPickCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkCardBlue
        : AppColors.lightCardBlue;
  }

  static Color get starColor => AppColors.ratingStar;
  static Color get successColor => AppColors.success;
}

class ThemeProvider extends InheritedWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const ThemeProvider({
    super.key,
    required this.toggleTheme,
    required this.isDark,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>();

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) =>
      isDark != oldWidget.isDark;
}
