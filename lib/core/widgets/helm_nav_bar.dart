// lib/core/widgets/helm_nav_bar.dart
// VIS-013 / VIS-024 / VIS-033 / VIS-034 — Custom bottom navigation.
// Active tab: interactive icon + label + 2pt × 18pt underline 4pt below label.
// Inactive tab: inkTertiary icon + label, no underline.

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_icon.dart';

/// One destination in the [HelmNavBar].
class HelmNavItem {
  final IconData icon;
  final String label;
  const HelmNavItem({required this.icon, required this.label});
}

class HelmNavBar extends StatelessWidget {
  final List<HelmNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HelmNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    return Material(
      color: colors.canvas,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.hairline, width: 1),
            ),
          ),
          child: SizedBox(
            height: 56, // VIS-013
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavCell(
                      item: items[i],
                      index: i,
                      active: i == currentIndex,
                      activeColor: colors.interactive,
                      inactiveColor: colors.inkTertiary,
                      labelStyle: typography.labelSm,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final HelmNavItem item;
  final int index;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.index,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HelmIcon(item.icon, size: HelmIconSize.lg, color: color),
            const SizedBox(height: 2),
            Text(item.label, style: labelStyle.copyWith(color: color)),
            const SizedBox(height: 4), // VIS-024 underline gap
            if (active)
              Container(
                key: ValueKey('helm-nav-underline-$index'),
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
