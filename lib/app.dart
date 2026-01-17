import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

class Folder2TextApp extends StatelessWidget {
  const Folder2TextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folder2Text',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
