import 'package:flutter_test/flutter_test.dart';
import 'package:helm/config/router/app_router.dart' show debugAppShellTabLabels;

void main() {
  test('bottom nav has the three primary tabs in order', () {
    expect(debugAppShellTabLabels, equals(['Home', 'Pipeline', 'Spend']));
  });
}
