import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/botw_theme.dart';
import 'features/materializer/materializer_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BotwApp(),
    ),
  );
}

class BotwApp extends StatelessWidget {
  const BotwApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheikah Slate: Image Link',
      debugShowCheckedModeBanner: false,
      theme: BotwTheme.slateTheme,
      home: const MaterializerScreen(),
    );
  }
}
