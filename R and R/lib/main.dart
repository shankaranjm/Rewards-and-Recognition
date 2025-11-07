// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewards_recognition_app/screens/theme_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';

void main() {
  // Initialize sqflite for ffi
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    // Wrap the entire app with ChangeNotifierProvider to make the ThemeProvider available.
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const RewardsApp(),
    ),
  );
}

class RewardsApp extends StatelessWidget {
  const RewardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider instance using Provider.of.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Rewards & Recognition',
      // Define the light and dark themes.
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      // Use the themeMode property from the provider to switch themes.
      themeMode: themeProvider.themeMode,
      // The starting point of your application.
      home: LoginScreen(onThemeChanged: (bool value) {  },),
    );
  }
}