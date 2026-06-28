// test/features/spend/presentation/views/spend_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helm/core/widgets/helm_amount.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localizations.dart';

Widget _app(List<TransactionEntity> txns) => ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(
          (ref) => _StubNotifier(txns),
        ),
      ],
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
        home: const SpendScreen(),
      ),
    );

class _StubNotifier extends TransactionsNotifier {
  _StubNotifier(super.txns) : super.test();
}

TransactionEntity _tx(String id, double amt, TransactionType type) =>
    TransactionEntity(
      id: id,
      title: 'tx-$id',
      amount: amt,
      date: DateTime(2026, 6, 1),
      type: type,
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  testWidgets('shows only expense transactions, not income', (tester) async {
    await tester.pumpWidget(_app([
      _tx('1', 500, TransactionType.expense),
      _tx('2', 999, TransactionType.income),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('tx-1'), findsOneWidget);
    expect(find.text('tx-2'), findsNothing);
  });

  testWidgets('teaches in the empty state', (tester) async {
    await tester.pumpWidget(_app([]));
    await tester.pumpAndSettle();
    expect(find.text('Nothing spent yet'), findsOneWidget);
    expect(find.textContaining('Safe-to-Spend'), findsWidgets);
  });

  testWidgets('renders a summary total amount', (tester) async {
    await tester.pumpWidget(_app([
      _tx('1', 500, TransactionType.expense),
      _tx('2', 300, TransactionType.expense),
    ]));
    await tester.pumpAndSettle();
    // Summary HelmAmount shows the 800 total.
    expect(find.byType(HelmAmount), findsWidgets);
    expect(find.text('Spent this month · reduces Safe-to-Spend'),
        findsOneWidget);
  });

  testWidgets('does not render category chips/labels (doctrine guard)',
      (tester) async {
    await tester.pumpWidget(_app([
      TransactionEntity(
        id: '1',
        title: 'tx-1',
        amount: 500,
        date: DateTime(2026, 6, 1),
        type: TransactionType.expense,
        categoryId: 'Food',
      ),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsNothing);
  });
}
