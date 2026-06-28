// VIS-041 / VIS-023 — Outline-only, token-sized icon wrapper.
// Single icon entry point for the app. Pass LucideIcons.* (outline) only.

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';

/// Icon size tokens (VIS-023).
enum HelmIconSize { sm, md, lg, xl }

/// Resolves a [HelmIconSize] to its pt value.
double helmIconSizePt(HelmIconSize size) {
  switch (size) {
    case HelmIconSize.sm:
      return 16;
    case HelmIconSize.md:
      return 20;
    case HelmIconSize.lg:
      return 24;
    case HelmIconSize.xl:
      return 28;
  }
}

/// Outline-only icon. Always pass a `LucideIcons.*` constant.
class HelmIcon extends StatelessWidget {
  final IconData icon;
  final HelmIconSize size;
  final Color? color;

  const HelmIcon(
    this.icon, {
    super.key,
    this.size = HelmIconSize.md,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: helmIconSizePt(size),
      color: color ?? context.colors.inkPrimary,
    );
  }
}
