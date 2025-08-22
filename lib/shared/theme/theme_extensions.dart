import 'package:flutter/material.dart';

/// Custom theme extensions for CardSense-specific design tokens
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xs;   // 4.0
  final double sm;   // 8.0
  final double md;   // 16.0
  final double lg;   // 24.0
  final double xl;   // 32.0
  final double xxl;  // 48.0

  static const AppSpacing light = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
  );

  static const AppSpacing dark = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
  );

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
      xxl: lerpDouble(xxl, other.xxl, t) ?? xxl,
    );
  }
}

@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.small,
    required this.medium,
    required this.large,
    required this.card,
    required this.bottomNav,
  });

  final List<BoxShadow> small;
  final List<BoxShadow> medium;
  final List<BoxShadow> large;
  final List<BoxShadow> card;
  final List<BoxShadow> bottomNav;

  static const AppShadows light = AppShadows(
    small: [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
    medium: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    large: [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
    card: [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
    bottomNav: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  );

  static const AppShadows dark = AppShadows(
    small: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
    medium: [
      BoxShadow(
        color: Color(0x29000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    large: [
      BoxShadow(
        color: Color(0x3D000000),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
    card: [
      BoxShadow(
        color: Color(0x24000000),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
    bottomNav: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  );

  @override
  AppShadows copyWith({
    List<BoxShadow>? small,
    List<BoxShadow>? medium,
    List<BoxShadow>? large,
    List<BoxShadow>? card,
    List<BoxShadow>? bottomNav,
  }) {
    return AppShadows(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      card: card ?? this.card,
      bottomNav: bottomNav ?? this.bottomNav,
    );
  }

  @override
  AppShadows lerp(AppShadows? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      small: BoxShadow.lerpList(small, other.small, t) ?? small,
      medium: BoxShadow.lerpList(medium, other.medium, t) ?? medium,
      large: BoxShadow.lerpList(large, other.large, t) ?? large,
      card: BoxShadow.lerpList(card, other.card, t) ?? card,
      bottomNav: BoxShadow.lerpList(bottomNav, other.bottomNav, t) ?? bottomNav,
    );
  }
}

@immutable
class AppBorderRadius extends ThemeExtension<AppBorderRadius> {
  const AppBorderRadius({
    required this.small,
    required this.medium,
    required this.large,
    required this.card,
    required this.button,
    required this.input,
  });

  final BorderRadius small;   // 8.0
  final BorderRadius medium;  // 12.0
  final BorderRadius large;   // 16.0
  final BorderRadius card;    // 16.0
  final BorderRadius button;  // 20.0
  final BorderRadius input;   // 28.0

  static const AppBorderRadius light = AppBorderRadius(
    small: BorderRadius.all(Radius.circular(8.0)),
    medium: BorderRadius.all(Radius.circular(12.0)),
    large: BorderRadius.all(Radius.circular(16.0)),
    card: BorderRadius.all(Radius.circular(16.0)),
    button: BorderRadius.all(Radius.circular(20.0)),
    input: BorderRadius.all(Radius.circular(28.0)),
  );

  static const AppBorderRadius dark = AppBorderRadius(
    small: BorderRadius.all(Radius.circular(8.0)),
    medium: BorderRadius.all(Radius.circular(12.0)),
    large: BorderRadius.all(Radius.circular(16.0)),
    card: BorderRadius.all(Radius.circular(16.0)),
    button: BorderRadius.all(Radius.circular(20.0)),
    input: BorderRadius.all(Radius.circular(28.0)),
  );

  @override
  AppBorderRadius copyWith({
    BorderRadius? small,
    BorderRadius? medium,
    BorderRadius? large,
    BorderRadius? card,
    BorderRadius? button,
    BorderRadius? input,
  }) {
    return AppBorderRadius(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      card: card ?? this.card,
      button: button ?? this.button,
      input: input ?? this.input,
    );
  }

  @override
  AppBorderRadius lerp(AppBorderRadius? other, double t) {
    if (other is! AppBorderRadius) return this;
    return AppBorderRadius(
      small: BorderRadius.lerp(small, other.small, t) ?? small,
      medium: BorderRadius.lerp(medium, other.medium, t) ?? medium,
      large: BorderRadius.lerp(large, other.large, t) ?? large,
      card: BorderRadius.lerp(card, other.card, t) ?? card,
      button: BorderRadius.lerp(button, other.button, t) ?? button,
      input: BorderRadius.lerp(input, other.input, t) ?? input,
    );
  }
}

// Helper function for lerping doubles
double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}
