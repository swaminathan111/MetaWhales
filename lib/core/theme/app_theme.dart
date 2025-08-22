import 'package:flutter/material.dart';

final ThemeData cardSenseTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF58d5d3),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Poppins',
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF111111),
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Color(0xFF111111),
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2a2a2a),
      letterSpacing: 1.0,
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF58d5d3),
    secondary: Color(0xFF32c8c5),
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Color(0xFF111111),
    onSurface: Color(0xFF2a2a2a),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF58d5d3),
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF58d5d3),
      ),
    ),
  ),
);
