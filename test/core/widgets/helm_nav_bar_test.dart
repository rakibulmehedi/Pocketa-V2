// test/core/widgets/helm_nav_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/core/widgets/helm_nav_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _items = [
  HelmNavItem(icon: LucideIcons.house, label: 'Home'),
  HelmNavItem(icon: LucideIcons.arrowUpDown, label: 'Pipeline'),
  HelmNavItem(icon: LucideIcons.wallet, label: 'Spend'),
];

Widget _host({required int index, required ValueChanged<int> onTap}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar:
            HelmNavBar(items: _items, currentIndex: index, onTap: onTap),
      ),
    );

void main() {
  testWidgets('renders one HelmIcon and label per item', (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    expect(find.byType(HelmIcon), findsNWidgets(3));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('Spend'), findsOneWidget);
  });

  testWidgets('active item shows underline; inactive items do not',
      (tester) async {
    await tester.pumpWidget(_host(index: 1, onTap: (_) {}));
    expect(find.byKey(const ValueKey('helm-nav-underline-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('helm-nav-underline-0')), findsNothing);
    expect(find.byKey(const ValueKey('helm-nav-underline-2')), findsNothing);
  });

  testWidgets('active icon uses interactive; inactive uses inkTertiary',
      (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final colors = AppTheme.light.extension<HelmColors>()!;
    final homeIcon =
        tester.widget<HelmIcon>(find.byType(HelmIcon).at(0));
    final spendIcon =
        tester.widget<HelmIcon>(find.byType(HelmIcon).at(2));
    expect(homeIcon.color, colors.interactive);
    expect(spendIcon.color, colors.inkTertiary);
  });

  testWidgets('tapping an item fires onTap with its index', (tester) async {
    int tapped = -1;
    await tester.pumpWidget(_host(index: 0, onTap: (i) => tapped = i));
    await tester.tap(find.text('Spend'));
    expect(tapped, 2);
  });

  testWidgets('each item is a semantic selected/unselected button',
      (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text('Home')),
      matchesSemantics(label: 'Home', isButton: true, isSelected: true, hasSelectedState: true),
    );
    handle.dispose();
  });

  testWidgets('nav bar is at least 56pt tall', (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final size = tester.getSize(find.byType(HelmNavBar));
    expect(size.height, greaterThanOrEqualTo(56));
  });
}
