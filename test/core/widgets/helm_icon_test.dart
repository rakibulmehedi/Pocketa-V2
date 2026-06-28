import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  test('size enum maps to correct pt values', () {
    expect(helmIconSizePt(HelmIconSize.sm), 16);
    expect(helmIconSizePt(HelmIconSize.md), 20);
    expect(helmIconSizePt(HelmIconSize.lg), 24);
    expect(helmIconSizePt(HelmIconSize.xl), 28);
  });

  testWidgets('renders the given IconData at the resolved size', (tester) async {
    await tester.pumpWidget(
      _host(const HelmIcon(LucideIcons.house, size: HelmIconSize.lg)),
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, LucideIcons.house);
    expect(icon.size, 24);
  });

  testWidgets('defaults color to inkPrimary when none provided', (tester) async {
    await tester.pumpWidget(_host(const HelmIcon(LucideIcons.settings)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppTheme.light.extension<HelmColors>()!.inkPrimary);
  });
}
