// lib/core/themes/app_theme.dart
// UX-5.05 — Rebuilt using Helm design token foundation.
//
// AppTheme.light / AppTheme.dark are the canonical theme accessors.

import 'package:flutter/material.dart';

import 'helm_colors.dart';
import 'helm_motion.dart';
import 'helm_spacing.dart';
import 'helm_typography.dart';

// ---------------------------------------------------------------------------
// AppTheme — new token-based API (ThemeMode.system only)
// ---------------------------------------------------------------------------
class AppTheme {
  static ThemeData get light => _buildTheme(isLight: true);
  static ThemeData get dark  => _buildTheme(isLight: false);

  static ThemeData _buildTheme({required bool isLight}) {
    final colors     = isLight ? HelmColors.light : HelmColors.dark;
    final typography = HelmTypography.build(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: colors.canvas,

      // ── ColorScheme ────────────────────────────────────────────────────────
      // NOT ColorScheme.fromSeed — hand-mapped from HelmColors tokens.
      colorScheme: ColorScheme(
        brightness:   isLight ? Brightness.light : Brightness.dark,
        primary:      colors.interactive,
        onPrimary:    colors.surface,
        secondary:    colors.interactive,
        onSecondary:  colors.surface,
        error:        colors.stateAtRisk,
        onError:      colors.surface,
        surface:      colors.surface,
        onSurface:    colors.inkPrimary,
      ),

      // ── ThemeExtensions ────────────────────────────────────────────────────
      extensions: <ThemeExtension<dynamic>>[colors, typography],

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.inkPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card — zero elevation, hairline border ─────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          side: BorderSide(
            color: colors.divider,
            width: HelmSpacing.cardBorder,
          ),
        ),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: colors.interactive,
          foregroundColor: colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HelmSpacing.buttonRadius),
          ),
          textStyle: typography.headingSm,
          animationDuration: HelmMotion.base,
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.interactive,
          textStyle: typography.bodyMd,
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          borderSide: BorderSide(color: colors.interactive, width: 2),
        ),
        labelStyle: typography.labelMd.copyWith(color: colors.inkSecondary),
        hintStyle:  typography.bodyMd.copyWith(color: colors.inkTertiary),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: HelmSpacing.cardBorder,
        space: 0,
      ),

      // ── TextTheme — mapped from HelmTypography ──────────────────────────
      textTheme: TextTheme(
        displayLarge:  typography.displayLarge,
        displayMedium: typography.displayHero,
        titleLarge:    typography.headingLg,
        titleMedium:   typography.headingMd,
        titleSmall:    typography.headingSm,
        bodyLarge:     typography.bodyLg,
        bodyMedium:    typography.bodyMd,
        bodySmall:     typography.bodySm,
        labelLarge:    typography.labelMd,
        labelSmall:    typography.labelSm,
      ),
    );
  }
}

