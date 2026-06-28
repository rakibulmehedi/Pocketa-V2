import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  test('lucide regular outline icons resolve to IconData', () {
    expect(LucideIcons.house, isA<IconData>());
    expect(LucideIcons.arrowUpDown, isA<IconData>());
    expect(LucideIcons.wallet, isA<IconData>());
    expect(LucideIcons.settings, isA<IconData>());
  });
}
