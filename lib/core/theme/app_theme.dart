import 'package:flutter/material.dart';

class AppTheme {
  // Define the color palette
  static const Color mint = Color(0xFFA8E6CD);
  static const Color periwinkle = Color(0xFFA9BEE9);
  static const Color darkSlate = Color(0xFF353C41); // Original: 0xFF525E66
  static const Color lightSurface = Color(0xFFF7F7F7);
  static const Color softNude = Color(0xFFF0E3DE);
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFD54F);

  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: mint,
      scaffoldBackgroundColor: lightSurface,
      colorScheme: const ColorScheme(
        primary: mint,
        secondary: periwinkle,
        surface: lightSurface,
        background: lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: darkSlate,
        onSurface: darkSlate,
        onBackground: darkSlate,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkSlate),
        bodyMedium: TextStyle(color: darkSlate),
        titleLarge: TextStyle(color: darkSlate),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: mint,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mint,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: periwinkle,
        ),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: periwinkle,
        color: darkSlate,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: darkSlate,
        elevation: 0,
      ),
      dividerColor: softNude,
      useMaterial3: true,
    );
  }
}
