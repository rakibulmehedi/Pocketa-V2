// lib/core/themes/helm_colors.dart
// UX-5.01 — Visual Identity: Color Token Foundation
// DO NOT use withOpacity() for text colors — all text colors are solid pre-resolved hex.
// withValues(alpha:) is reserved for DECORATIVE elements only (rails, dots).

import 'package:flutter/material.dart';

class HelmColors extends ThemeExtension<HelmColors> {
  const HelmColors({
    required this.canvas,
    required this.surface,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.interactive,
    required this.divider,
    required this.hairline,
    required this.stateSafe,
    required this.stateTight,
    required this.stateAtRisk,
    required this.stateHope,
    required this.stateHopeMuted,
  });

  final Color canvas;
  final Color surface;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color interactive;
  final Color divider;
  final Color hairline;
  final Color stateSafe;
  final Color stateTight;
  final Color stateAtRisk;
  final Color stateHope;
  final Color stateHopeMuted;

  // ---------------------------------------------------------------------------
  // Light mode — REFINED system values (doc 08 overrides 07)
  // All text colors are solid pre-resolved hex (no alpha for text).
  // ---------------------------------------------------------------------------
  static const HelmColors light = HelmColors(
    canvas:         Color(0xFFF3ECE0), // warm paper
    surface:        Color(0xFFEAE0D0), // cards, elevated panels
    inkPrimary:     Color(0xFF2B2521), // numbers, critical text
    inkSecondary:   Color(0xFF5C5247), // labels, timestamps
    // WCAG AA 4.5:1 verified against canvas background (#F3ECE0).
    // #8A7A5E was ~3.5:1 (fail). Darkened to #6B5C42 → ~5.6:1 (pass).
    inkTertiary:    Color(0xFF6B5C42), // helper text, metadata
    interactive:    Color(0xFFC2603F), // terracotta — tappable affordances
    divider:        Color(0xFFDED2BF), // card borders
    hairline:       Color(0xFFE8DECB), // internal dividers
    stateSafe:      Color(0xFF567059), // stable signal, runway rail (darkened from 5E7C63 for WCAG AA on paper)
    stateTight:     Color(0xFF7A6024), // reduced runway (darkened from 9A7B2F for WCAG AA on paper)
    stateAtRisk:    Color(0xFFA8443A), // imminent harm only
    stateHope:      Color(0xFF5A7585), // uncertain/pending money text
    stateHopeMuted: Color(0xFF8A9DA6), // pending decorative markers
  );

  // ---------------------------------------------------------------------------
  // Dark mode — hand-tuned for contrast on dark canvases
  // ---------------------------------------------------------------------------
  static const HelmColors dark = HelmColors(
    canvas:         Color(0xFF1E1813), // warm espresso (NOT black)
    surface:        Color(0xFF271F18),
    inkPrimary:     Color(0xFFF3EAD9),
    inkSecondary:   Color(0xFFC7B9A2),
    inkTertiary:    Color(0xFF9A8A70),
    interactive:    Color(0xFFD8744F), // terracotta, lifted for dark
    divider:        Color(0xFF3A2F25),
    hairline:       Color(0xFF332A21),
    stateSafe:      Color(0xFF86A88A),
    stateTight:     Color(0xFFD4A668),
    stateAtRisk:    Color(0xFFC56A58),
    stateHope:      Color(0xFF7A95A8),
    stateHopeMuted: Color(0xFF5A6E77),
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension contract
  // ---------------------------------------------------------------------------
  @override
  HelmColors copyWith({
    Color? canvas,
    Color? surface,
    Color? inkPrimary,
    Color? inkSecondary,
    Color? inkTertiary,
    Color? interactive,
    Color? divider,
    Color? hairline,
    Color? stateSafe,
    Color? stateTight,
    Color? stateAtRisk,
    Color? stateHope,
    Color? stateHopeMuted,
  }) {
    return HelmColors(
      canvas:         canvas         ?? this.canvas,
      surface:        surface        ?? this.surface,
      inkPrimary:     inkPrimary     ?? this.inkPrimary,
      inkSecondary:   inkSecondary   ?? this.inkSecondary,
      inkTertiary:    inkTertiary    ?? this.inkTertiary,
      interactive:    interactive    ?? this.interactive,
      divider:        divider        ?? this.divider,
      hairline:       hairline       ?? this.hairline,
      stateSafe:      stateSafe      ?? this.stateSafe,
      stateTight:     stateTight     ?? this.stateTight,
      stateAtRisk:    stateAtRisk    ?? this.stateAtRisk,
      stateHope:      stateHope      ?? this.stateHope,
      stateHopeMuted: stateHopeMuted ?? this.stateHopeMuted,
    );
  }

  @override
  HelmColors lerp(ThemeExtension<HelmColors>? other, double t) {
    if (other is! HelmColors) return this;
    return HelmColors(
      canvas:         Color.lerp(canvas,         other.canvas,         t)!,
      surface:        Color.lerp(surface,        other.surface,        t)!,
      inkPrimary:     Color.lerp(inkPrimary,     other.inkPrimary,     t)!,
      inkSecondary:   Color.lerp(inkSecondary,   other.inkSecondary,   t)!,
      inkTertiary:    Color.lerp(inkTertiary,    other.inkTertiary,    t)!,
      interactive:    Color.lerp(interactive,    other.interactive,    t)!,
      divider:        Color.lerp(divider,        other.divider,        t)!,
      hairline:       Color.lerp(hairline,       other.hairline,       t)!,
      stateSafe:      Color.lerp(stateSafe,      other.stateSafe,      t)!,
      stateTight:     Color.lerp(stateTight,     other.stateTight,     t)!,
      stateAtRisk:    Color.lerp(stateAtRisk,    other.stateAtRisk,    t)!,
      stateHope:      Color.lerp(stateHope,      other.stateHope,      t)!,
      stateHopeMuted: Color.lerp(stateHopeMuted, other.stateHopeMuted, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// BuildContext extension — access colors without boilerplate
// ---------------------------------------------------------------------------
extension BuildContextHelmColors on BuildContext {
  HelmColors get colors {
    final theme = Theme.of(this);
    return theme.extension<HelmColors>() ??
        (theme.brightness == Brightness.dark ? HelmColors.dark : HelmColors.light);
  }
}
