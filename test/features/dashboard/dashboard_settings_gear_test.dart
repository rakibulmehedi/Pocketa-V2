import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard source pushes /settings from a gear action', () {
    final src = File(
      'lib/features/dashboard/presentation/views/dashboard_screen.dart',
    ).readAsStringSync();
    expect(src, contains("ValueKey('dashboard-settings-gear')"));
    expect(src, contains('LucideIcons.settings'));
    expect(src, contains('RouteNames.settings'));
  });
}
