import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router/app_router.dart';
import 'state/product_provider.dart';
import 'state/session_state.dart';
import 'theme/app_theme.dart';

const supabaseUrl = 'https://znnbrdixsvdwbcetztkw.supabase.co';
const supabasePublishableKey = 'sb_publishable_zH-ScBRV9Xj151BC652E6Q_3nsZhK86';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionState()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..initialize(),
        ),
      ],
      child: const HydroFlaskStoreApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class HydroFlaskStoreApp extends StatefulWidget {
  const HydroFlaskStoreApp({super.key});

  @override
  State<HydroFlaskStoreApp> createState() => _HydroFlaskStoreAppState();
}

class _HydroFlaskStoreAppState extends State<HydroFlaskStoreApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late final GoRouter _router =
      AppRouter.create(context.read<SessionState>());

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
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
        routerConfig: _router,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
