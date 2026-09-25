import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier for app theme mode.
/// Reads from SharedPreferences on init and persists changes.
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

Future<void> initThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode') ?? 'System';
  themeModeNotifier.value = _parseThemeMode(saved);
}

Future<void> saveThemeMode(String label) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', label);
  themeModeNotifier.value = _parseThemeMode(label);
}

ThemeMode _parseThemeMode(String label) {
  switch (label) {
    case 'Light':
      return ThemeMode.light;
    case 'Dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
