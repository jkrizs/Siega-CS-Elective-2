import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/pokedex_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PokedexApp());
}

/// Custom scroll behavior enabling drag gestures across touch, mouse, trackpad, and stylus.
/// Essential for smooth horizontal filter bar scrolling on web and mobile emulation.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pokédex',
            debugShowCheckedModeBanner: false,
            scrollBehavior: AppScrollBehavior(),
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const PokedexScreen(),
          );
        },
      ),
    );
  }
}
