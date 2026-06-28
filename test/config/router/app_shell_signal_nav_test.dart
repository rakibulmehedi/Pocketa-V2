import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/config/router/route_names.dart';

void main() {
  test('shell exposes Home Pipeline Spend tabs with Material icons', () {
    expect(RouteNames.home, equals('/home'));
    expect(RouteNames.pipeline, equals('/pipeline'));
    expect(RouteNames.spend, equals('/spend'));

    final source = File('lib/config/router/app_router.dart').readAsStringSync();
    final tabsStart = source.indexOf('const List<_TabItem> _tabs = [');
    final tabsSource =
        source.substring(tabsStart, source.indexOf('];', tabsStart));

    expect(tabsSource, contains('RouteNames.home'));
    expect(tabsSource, contains("label: 'Home'"));
    expect(tabsSource, contains('Icons.home_rounded'));

    expect(tabsSource, contains('RouteNames.pipeline'));
    expect(tabsSource, contains("label: 'Pipeline'"));
    expect(tabsSource, contains('Icons.account_balance_wallet_rounded'));

    expect(tabsSource, contains('RouteNames.spend'));
    expect(tabsSource, contains("label: 'Spend'"));
    expect(tabsSource, contains('Icons.wallet_rounded'));

    // History and Settings are not primary tabs — they live as AppBar actions.
    expect(tabsSource, isNot(contains('RouteNames.trace')));
    expect(tabsSource, isNot(contains('RouteNames.settings')));
  });
}
