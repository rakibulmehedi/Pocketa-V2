// test/features/income/presentation/income_paper_ledger_test.dart
//
// Paper Ledger reskin — Task 16 verification: light + dark smoke tests
// for the income/pipeline screens.
//
// incomeNotifierProvider is overridden with a fake in-memory repository
// so these tests have zero Hive dependency.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/domain/repositories/income_repository.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/income/presentation/views/pipeline_screen.dart';
import 'package:helm/l10n/app_localizations.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeIncomeRepository implements IncomeRepository {
  @override
  Future<void> addIncome(IncomeEntryEntity entity) async {}

  @override
  Future<void> clearIncomes() async {}

  @override
  Future<void> deleteIncome(String id) async {}

  @override
  List<IncomeEntryEntity> getIncomes() => [];

  @override
  Future<void> updateIncome(IncomeEntryEntity entity) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

List<Override> get _overrides => [
      incomeNotifierProvider
          .overrideWith((ref) => IncomeNotifier(_FakeIncomeRepository())),
    ];

Widget _app(ThemeData theme) => ProviderScope(
      overrides: _overrides,
      child: MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PipelineScreen(),
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  testWidgets('PipelineScreen renders in light mode without error',
      (tester) async {
    await tester.pumpWidget(_app(AppTheme.light));
    await tester.pump();
    expect(find.byType(PipelineScreen), findsOneWidget);
  });

  testWidgets('PipelineScreen renders in dark mode without error',
      (tester) async {
    await tester.pumpWidget(_app(AppTheme.dark));
    await tester.pump();
    expect(find.byType(PipelineScreen), findsOneWidget);
  });

  testWidgets('PipelineScreen shows empty-state icon in light mode',
      (tester) async {
    await tester.pumpWidget(_app(AppTheme.light));
    await tester.pump();
    // Empty pipeline → _EmptyPipelineView shows inbox icon
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('PipelineScreen shows empty-state icon in dark mode',
      (tester) async {
    await tester.pumpWidget(_app(AppTheme.dark));
    await tester.pump();
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });
}
