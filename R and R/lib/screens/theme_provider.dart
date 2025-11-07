import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.purple, // Or a color that stands out in dark mode
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
    cardColor: const Color(0xFF1F1F1F), // A lighter shade for cards
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.grey),
    ),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey.shade100,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.grey.shade600),
    ),
  );
}