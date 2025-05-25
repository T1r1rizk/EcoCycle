// lib/core/providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth/auth_service.dart';
import '../screens/models/user_model.dart';
import '../core/services/theme_service.dart';

/* Shared Providers */
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/* Theme Providers */
final themeServiceProvider = Provider<ThemeService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider).value;
  assert(prefs != null, 'SharedPreferences not initialized');
  return ThemeService(prefs!);
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final service = ref.watch(themeServiceProvider);
  return ThemeNotifier(service);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService service;
  
  ThemeNotifier(this.service) : super(service.currentTheme) {
    _init();
  }

  Future<void> _init() async {
    state = service.currentTheme;
  }

  Future<void> toggleTheme() async {
    await service.toggleTheme();
    state = service.currentTheme;
  }

  Future<void> setTheme(ThemeMode theme) async {
    await service.setTheme(theme);
    state = theme;
  }
}

/* Auth Providers */
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/* App State Providers */
final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);