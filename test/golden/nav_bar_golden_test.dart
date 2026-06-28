// test/golden/nav_bar_golden_test.dart
//
// Golden tests for HelmNavBar — paper-ledger-reskin.
// Generate: fvm flutter test test/golden/nav_bar_golden_test.dart --update-goldens --tags golden
// Verify:   fvm flutter test test/golden/nav_bar_golden_test.dart --tags golden
//
// Tagged 'golden' so CI can exclude them (macOS baselines differ from Linux rendering):
//   flutter test --exclude-tags golden

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/widgets/helm_nav_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _items = [
  HelmNavItem(icon: LucideIcons.house, label: 'Home'),
  HelmNavItem(icon: LucideIcons.arrowUpDown, label: 'Pipeline'),
  HelmNavItem(icon: LucideIcons.wallet, label: 'Spend'),
];

Widget _app(ThemeData theme) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar:
              HelmNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

void main() {
  testWidgets('nav bar light golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.light));
    await tester.pumpAndSettle();
    await expectLater(find.byType(HelmNavBar),
        matchesGoldenFile('goldens/nav_bar_light.png'));
  });

  testWidgets('nav bar dark golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.dark));
    await tester.pumpAndSettle();
    await expectLater(find.byType(HelmNavBar),
        matchesGoldenFile('goldens/nav_bar_dark.png'));
  });
}
