import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/app/theme/pecule_fonts.dart';
import 'package:pecule/app/theme/pecule_palette.dart';

ThemeData buildPeculeTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: PeculePalette.background,
    fontFamily: PeculeFonts.sans,
    textTheme: _textTheme,
    extensions: const [PeculeColors.dark],
  );
}

const _colorScheme = ColorScheme.dark(
  primary: PeculePalette.pollen,
  onPrimary: PeculePalette.onPollen,
  secondary: PeculePalette.pollen,
  onSecondary: PeculePalette.onPollen,
  error: PeculePalette.loss,
  onError: PeculePalette.onPollen,
  surface: PeculePalette.background,
  onSurface: PeculePalette.text,
  onSurfaceVariant: PeculePalette.textSecondary,
  surfaceContainer: PeculePalette.surface,
  surfaceContainerHigh: PeculePalette.surfaceHigh,
  outline: PeculePalette.border,
  outlineVariant: PeculePalette.surfaceHigh,
);

const _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 62,
    height: 1.05,
    letterSpacing: -0.6,
    color: PeculePalette.text,
  ),
  displayMedium: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 56,
    height: 1.08,
    color: PeculePalette.text,
  ),
  displaySmall: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 40,
    height: 1.1,
    color: PeculePalette.text,
  ),
  headlineLarge: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 44,
    height: 1.1,
    color: PeculePalette.text,
  ),
  headlineMedium: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 30,
    height: 1.1,
    color: PeculePalette.text,
  ),
  headlineSmall: TextStyle(
    fontFamily: PeculeFonts.serif,
    fontSize: 26,
    height: 1.15,
    color: PeculePalette.text,
  ),
  // Material espace les lettres par défaut sur ces styles, la maquette non.
  titleMedium: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  titleSmall: TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  bodyLarge: TextStyle(
    fontSize: 16.5,
    height: 1.6,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  bodyMedium: TextStyle(
    fontSize: 15,
    height: 1.5,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  bodySmall: TextStyle(
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0,
    color: PeculePalette.textSecondary,
  ),
  labelLarge: TextStyle(
    fontSize: 16.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  labelMedium: TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: PeculePalette.text,
  ),
  labelSmall: TextStyle(
    fontFamily: PeculeFonts.mono,
    fontSize: 11,
    letterSpacing: 0.9,
    color: PeculePalette.textSecondary,
  ),
);
