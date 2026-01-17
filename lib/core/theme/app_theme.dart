import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'JetBrainsMono'),
    ),
  );
}
