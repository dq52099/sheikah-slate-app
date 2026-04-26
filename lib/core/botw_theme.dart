import 'package:flutter/material.dart';

class BotwTheme {
  // --- 希卡科技配色 ---
  static const Color sheikahBlue = Color(0xFF00D2FF);
  static const Color ancientOrange = Color(0xFFFF9600);
  static const Color slateStone = Color(0xFF121212);
  static const Color slateGray = Color(0xFF2A2A2A);
  static const Color energyGreen = Color(0xFF00FF99);

  static ThemeData get slateTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: slateStone,
      colorScheme: const ColorScheme.dark(
        primary: sheikahBlue,
        secondary: ancientOrange,
        surface: slateGray,
      ),
      // --- 希卡卡片: 带有发光边框效果 ---
      cardTheme: CardTheme(
        color: slateGray.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: sheikahBlue, width: 0.5),
        ),
      ),
      // --- 文本框: 模拟终端输入 ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: sheikahBlue),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: sheikahBlue, width: 2),
        ),
        hintStyle: TextStyle(color: sheikahBlue.withOpacity(0.4), fontSize: 14),
      ),
      // --- 按钮: 模仿希卡界面按钮 ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: sheikahBlue,
          side: const BorderSide(color: sheikahBlue, width: 1.5),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: sheikahBlue, fontWeight: FontWeight.bold, letterSpacing: 2),
        bodyLarge: TextStyle(color: Colors.white70),
      ),
    );
  }
}
