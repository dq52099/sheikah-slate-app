import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'core/botw_theme.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const BotwApp(),
    ),
  );
}

class BotwApp extends StatelessWidget {
  const BotwApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '希卡之石',
      debugShowCheckedModeBanner: false,
      theme: BotwTheme.slateTheme,
      home: const LoginScreen(),
    );
  }
}
