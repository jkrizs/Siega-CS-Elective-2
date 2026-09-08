import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HydroFlaskStoreApp());
}

class HydroFlaskStoreApp extends StatefulWidget {
  const HydroFlaskStoreApp({super.key});

  @override
  State<HydroFlaskStoreApp> createState() => _HydroFlaskStoreAppState();
}

class _HydroFlaskStoreAppState extends State<HydroFlaskStoreApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      toggleTheme: _toggleTheme,
      isDark: _themeMode == ThemeMode.dark,
      child: MaterialApp.router(
        title: 'Hydro Flask',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
