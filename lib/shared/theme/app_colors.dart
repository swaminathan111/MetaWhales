import 'package:flutter/material.dart';

/// CardSense color palette for light and dark themes
class AppColors {
  // Primary brand colors
  static const Color primaryTeal = Color(0xFF58d5d3);
  static const Color mintGreen = Color(0xFFA8E6CD);
  static const Color periwinkle = Color(0xFFA9BEE9);
  static const Color darkSlate = Color(0xFF525E66);

  // Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primaryTeal,
    primaryContainer: mintGreen,
    secondary: periwinkle,
    secondaryContainer: Color(0xFFE8F4FD),
    surface: Colors.white,
    surfaceContainerHighest: Color(0xFFF5F5F5),
    surfaceContainerHigh: Color(0xFFFAFAFA),
    onPrimary: Colors.white,
    onPrimaryContainer: darkSlate,
    onSecondary: Colors.white,
    onSecondaryContainer: darkSlate,
    onSurface: Color(0xFF1C1B1F),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
  );

  // Dark theme color scheme (prepared for future)
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primaryTeal,
    primaryContainer: Color(0xFF004D4A),
    secondary: periwinkle,
    secondaryContainer: Color(0xFF1E2328),
    surface: Color(0xFF141218),
    surfaceContainerHighest: Color(0xFF2B2930),
    surfaceContainerHigh: Color(0xFF211F26),
    onPrimary: Color(0xFF003735),
    onPrimaryContainer: mintGreen,
    onSecondary: Color(0xFF2E3036),
    onSecondaryContainer: periwinkle,
    onSurface: Color(0xFFE6E0E9),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
  );

  // Gradient colors
  static const List<Color> primaryGradient = [primaryTeal, mintGreen];
  static const List<Color> cardGradients = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];
}
