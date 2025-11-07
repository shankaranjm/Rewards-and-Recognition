import 'package:flutter/material.dart';

// A ChangeNotifier that manages the application's theme.
// It can be either light or dark.
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Toggles the theme between light and dark mode.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // This tells all listening widgets to rebuild.
  }

  // Returns true if the current theme is dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}