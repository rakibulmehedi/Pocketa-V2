// test/golden/spend_golden_test.dart
//
// Golden tests for SpendScreen — paper-ledger-reskin.
// Generate: fvm flutter test test/golden/spend_golden_test.dart --update-goldens --tags golden
// Verify:   fvm flutter test test/golden/spend_golden_test.dart --tags golden
//
// Tagged 'golden' so CI can exclude them (macOS baselines differ from Linux rendering):
//   flutter test --exclude-tags golden
//
// Stability note: empty state contains no dates, and the populated state uses
// fixed dates (2026-06-01, 2026-06-03), so both baselines are deterministic.

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TransactionEntity> _seed() => [
      TransactionEntity(
          id: '1',
          title: 'Office rent',
          amount: 12000,
          date: DateTime(2026, 6, 1),
          type: TransactionType.expense),
      TransactionEntity(
          id: '2',
          title: 'Internet',
          amount: 1500,
          date: DateTime(2026, 6, 3),
          type: TransactionType.expense),
    ];

Widget _app(ThemeData theme, List<TransactionEntity> txns) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/spend',
        // ignore: avoid_unused_parameters
        builder: (context, state) => const SpendScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        // ignore: avoid_unused_parameters
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
    initialLocation: '/spend',
  );

  return ProviderScope(
    overrides: [
      transactionsProvider
          .overrideWith((ref) => TransactionsNotifier.test(txns)),
    ],
    child: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp.router(
        theme: theme,
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  testWidgets('spend populated light golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.light, _seed()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SpendScreen),
        matchesGoldenFile('goldens/spend_light.png'));
  });

  testWidgets('spend empty dark golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.dark, const []));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SpendScreen),
        matchesGoldenFile('goldens/spend_empty_dark.png'));
  });
}
