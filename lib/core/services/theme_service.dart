// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme';
  final SharedPreferences prefs;

  ThemeService(this.prefs);

  ThemeMode get currentTheme {
    final index = prefs.getInt(_themeKey);
    return index != null ? ThemeMode.values[index] : ThemeMode.system;
  }

  Future<void> toggleTheme() async {
    final newTheme = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setInt(_themeKey, newTheme.index);
  }

  Future<void> setTheme(ThemeMode theme) async {
    await prefs.setInt(_themeKey, theme.index);
  }

  // Helper to convert to Material ThemeData
  ThemeData get themeData {
    return currentTheme == ThemeMode.dark 
      ? _buildDarkTheme() 
      : _buildLightTheme();
  }

  ThemeData _buildLightTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Color.fromARGB(255, 16, 91, 23),
      colorScheme: ColorScheme.light(
        primary: Color.fromARGB(255, 16, 91, 23),
        secondary: Color.fromARGB(255, 67, 143, 57),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.light().copyWith(
      primaryColor: const Color.fromARGB(255, 58, 148, 59),
      colorScheme: ColorScheme.dark(
        primary: const Color.fromARGB(255, 67, 143, 57),
        secondary: const Color.fromARGB(255, 16, 91, 23),
      ),
    );
  }
}