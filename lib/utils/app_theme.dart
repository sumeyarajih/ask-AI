import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppTheme {
  // Dark Theme Colors
  static const Color darkRed = Color(0xFF8B0000);
  static const Color darkerRed = Color(0xFFA52A2A);
  static const Color darkGray = Color(0xFF222222);
  static const Color mediumGray = Color(0xFF333333);
  static const Color backgroundBlack = Colors.black;
  static const Color offBlack = Color(0xFF1A1A1A);
  
  // Light Theme Colors
  static const Color backgroundWhite = Color(0xFFF5F5F5);
  static const Color offWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color lightMediumGray = Color(0xFFBDBDBD);

  // Common Text Colors
  static const Color textBlack = Colors.black87;
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.grey;

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundBlack,
      primaryColor: darkRed,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkRed,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.dark(
        primary: darkRed,
        secondary: darkerRed,
        surface: darkGray,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: textWhite,
        textColor: textWhite,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: mediumGray,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: backgroundWhite,
      primaryColor: darkRed,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkRed,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.light(
        primary: darkRed,
        secondary: darkerRed,
        surface: offWhite,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: textBlack,
        textColor: textBlack,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: offWhite,
      ),
    );
  }
}
