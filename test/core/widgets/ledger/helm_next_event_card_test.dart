import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/widgets/ledger/helm_next_event_card.dart';
import 'package:helm/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  testWidgets('renders label, title, action', (tester) async {
    await tester.pumpWidget(_wrap(HelmNextEventCard(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'Upwork payout lands in 3 days',
      actionLabel: 'Mark as received',
      onAction: () {},
    )));
    expect(find.text('NEXT EVENT'), findsOneWidget);
    expect(find.text('Upwork payout lands in 3 days'), findsOneWidget);
    expect(find.text('Mark as received'), findsOneWidget);
  });

  testWidgets('tapping action fires callback', (tester) async {
    var fired = false;
    await tester.pumpWidget(_wrap(HelmNextEventCard(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'x',
      actionLabel: 'Go',
      onAction: () => fired = true,
    )));
    await tester.tap(find.text('Go'));
    await tester.pump();
    expect(fired, isTrue);
  });

  testWidgets('View trace button appears when onTrace provided', (tester) async {
    await tester.pumpWidget(_wrap(HelmNextEventCard(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'x',
      actionLabel: 'Go',
      onAction: () {},
      onTrace: () {},
    )));
    expect(find.text('View trace'), findsOneWidget);
  });

  testWidgets('View trace button absent when onTrace null', (tester) async {
    await tester.pumpWidget(_wrap(HelmNextEventCard(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'x',
      actionLabel: 'Go',
      onAction: () {},
    )));
    expect(find.text('View trace'), findsNothing);
  });

  testWidgets('tapping View trace fires onTrace', (tester) async {
    var traceFired = false;
    await tester.pumpWidget(_wrap(HelmNextEventCard(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'x',
      actionLabel: 'Go',
      onAction: () {},
      onTrace: () => traceFired = true,
    )));
    await tester.tap(find.text('View trace'));
    await tester.pump();
    expect(traceFired, isTrue);
  });
}
