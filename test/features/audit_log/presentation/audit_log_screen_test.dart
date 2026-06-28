// test/features/audit_log/presentation/audit_log_screen_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/features/audit_log/data/services/audit_chain_service.dart';
import 'package:helm/features/audit_log/domain/entities/audit_event.dart';
import 'package:helm/features/audit_log/presentation/providers/audit_providers.dart';
import 'package:helm/features/audit_log/presentation/views/audit_log_screen.dart';
import 'package:helm/features/audit_log/presentation/widgets/audit_event_card.dart';
import 'package:helm/l10n/app_localizations.dart';

Widget _host(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuditLogScreen(),
      ),
    );

void main() {
  testWidgets('empty state shows empty copy', (tester) async {
    await tester.pumpWidget(_host([
      auditEventsProvider.overrideWith((ref) async => <AuditEvent>[]),
      auditIntegrityProvider.overrideWith(
        (ref) async =>
            const ChainVerification(isIntact: true, verifiedCount: 0),
      ),
    ]));
    await tester.pump();
    expect(find.byType(AuditEventCard), findsNothing);
  });

  testWidgets('loading state shows CircularProgressIndicator', (tester) async {
    final completer = Completer<List<AuditEvent>>();
    await tester.pumpWidget(_host([
      auditEventsProvider.overrideWith((ref) => completer.future),
      auditIntegrityProvider.overrideWith(
        (ref) async =>
            const ChainVerification(isIntact: true, verifiedCount: 0),
      ),
    ]));
    await tester.pump(); // single frame — future not yet resolved
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete([]); // clean up
  });

  testWidgets('error state shows error message widget', (tester) async {
    await tester.pumpWidget(_host([
      auditEventsProvider.overrideWith((ref) async => throw Exception('Hive unavailable')),
      auditIntegrityProvider.overrideWith(
        (ref) async =>
            const ChainVerification(isIntact: true, verifiedCount: 0),
      ),
    ]));
    await tester.pump(); // kick async provider
    await tester.pump(); // resolve future
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('renders grouped cards for events', (tester) async {
    final now = DateTime.now();
    // Pin today's event to noon — avoids midnight boundary flakiness
    final todayNoon = DateTime(now.year, now.month, now.day, 12);
    final events = [
      AuditEvent(
        id: 'a',
        timestamp: todayNoon,
        eventType: AuditEventType.created,
        entityType: AuditEntityType.income,
        entityId: 'e1',
        description: 'd1',
      ),
      AuditEvent(
        id: 'b',
        timestamp: now.subtract(const Duration(days: 10)),
        eventType: AuditEventType.updated,
        entityType: AuditEntityType.transaction,
        entityId: 'e2',
        description: 'd2',
      ),
    ];
    await tester.pumpWidget(_host([
      auditEventsProvider.overrideWith((ref) async => events),
      auditIntegrityProvider.overrideWith(
        (ref) async =>
            const ChainVerification(isIntact: true, verifiedCount: 0),
      ),
    ]));
    await tester.pump(); // kick async providers
    await tester.pump(); // resolve futures
    expect(find.byType(AuditEventCard), findsNWidgets(2));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
  });
}
