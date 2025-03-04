import 'package:flutter/material.dart';

/// Monekin brand color.
// const brandBlue = Color(0xFF0F3375);

/// Monekin brand colors
const brandBlue = Color(0xFF1c64f2);
const brandDarkBlue = Color(0xFF1724c9);
const brandLightBlue = Color(0xFF30a8ff);

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.danger,
    required this.success,
    required this.light,
    required this.dark,
    required this.shadowColor,
    required this.shadowColorLight,
    required this.brand,
    required this.brandDark,
    required this.brandLight,
    required this.inputFill,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.surface,
    required this.onSurface,
    required this.modalBackground,
  });

  final Color danger;
  final Color success;
  final Color brand;
  final Color brandDark;
  final Color brandLight;
  final Color inputFill;
  final Color light;
  final Color dark;
  final Color shadowColor;
  final Color shadowColorLight;

  /* ---- From the material color scheme: ---- */
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color surface;
  final Color onSurface;
  final Color modalBackground;

  static AppColors fromColorScheme(ColorScheme colorScheme) {
    return AppColors(
      danger: Colors.red,
      success: const Color.fromARGB(255, 55, 161, 59),
      brand: brandBlue,
      brandDark: brandDarkBlue,
      brandLight: brandLightBlue,
      light: colorScheme.surfaceContainerLow,
      dark: colorScheme.inverseSurface,
      shadowColor: const Color.fromARGB(100, 90, 90, 90),
      shadowColorLight: const Color.fromARGB(44, 90, 90, 90),
      inputFill: colorScheme.surfaceContainerHighest,
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      primaryContainer: colorScheme.primaryContainer,
      onPrimaryContainer: colorScheme.onPrimaryContainer,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      modalBackground: colorScheme.surfaceContainer,
    );
  }

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  @override
  AppColors copyWith({
    Color? danger,
    Color? success,
    Color? brand,
    Color? brandDark,
    Color? brandLight,
    Color? primary,
    Color? inputFill,
    Color? dark,
    Color? light,
    Color? shadowColor,
    Color? shadowColorLight,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? surface,
    Color? onSurface,
    Color? modalBackground,
  }) {
    return AppColors(
      danger: danger ?? this.danger,
      success: success ?? this.success,
      brand: brand ?? this.brand,
      brandDark: brandDark ?? this.brandDark,
      brandLight: brandLight ?? this.brandLight,
      inputFill: inputFill ?? this.inputFill,
      light: light ?? this.light,
      dark: dark ?? this.dark,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowColorLight: shadowColorLight ?? this.shadowColorLight,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      modalBackground: modalBackground ?? this.modalBackground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      success: Color.lerp(success, other.success, t) ?? success,
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      brandDark: Color.lerp(brandDark, other.brandDark, t) ?? brandDark,
      brandLight: Color.lerp(brandLight, other.brandLight, t) ?? brandLight,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      light: Color.lerp(light, other.light, t) ?? light,
      dark: Color.lerp(dark, other.dark, t) ?? dark,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      shadowColorLight:
          Color.lerp(shadowColorLight, other.shadowColorLight, t) ??
              shadowColorLight,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t) ??
              primaryContainer,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t) ??
              onPrimaryContainer,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      modalBackground: Color.lerp(modalBackground, other.modalBackground, t) ??
          modalBackground,
    );
  }
}
