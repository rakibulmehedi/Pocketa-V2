import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pipeline gates the audit-trail link behind non-guest mode', () {
    final src = File(
      'lib/features/income/presentation/views/pipeline_screen.dart',
    ).readAsStringSync();
    expect(src, contains("ValueKey('pipeline-audit-link')"));
    expect(src, contains('SharedPrefServices.getGuestMode()'));
    expect(src, contains('RouteNames.trace'));
    expect(src, contains('LucideIcons.history'));
  });
}
