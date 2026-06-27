// test/flows/e2e_critical_flows_test.dart
//
// E2E critical-flow widget tests for Phase 2 QA gate.
//
// Covered flows:
//   1. Fresh onboarding → dashboard renders S2S hero (HelmLedgerHero)
//   2. Add income entry (Expected status) → appears in income list
//   3. Income transition: Expected → Pending → Received
//   4. S2S value recalculates after income status change
//   5. PIN setup flow smoke test (renders + accepts 6 digits)
//   6. CSV export: share trigger fires
//   7. Audit log: shows events after income transitions
//
// Strategy:
//   - All Hive / SharedPreferences backed providers are overridden with
//     lightweight in-memory stubs so no real device or Hive box is required.
//   - GoRouter stubs absorb navigation so widgets under test don't throw.
//   - setUpAll initialises SharedPreferences mock once for the suite.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/analytics/domain/analytics_event_entity.dart';
import 'package:helm/core/analytics/domain/analytics_repository.dart';
import 'package:helm/core/analytics/domain/nudge_event_logger.dart';
import 'package:helm/core/nudge/data/repositories/nudge_repository.dart';
import 'package:helm/core/nudge/domain/nudge_evaluator.dart';
import 'package:helm/core/nudge/domain/nudge_log_entry_entity.dart';
import 'package:helm/core/nudge/presentation/providers/nudge_providers.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/core/widgets/ledger/helm_ledger_hero.dart';
import 'package:helm/features/auth/domain/entities/auth_state.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';
import 'package:helm/features/auth/presentation/views/pin_setup_screen.dart';
import 'package:helm/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:helm/features/export/presentation/providers/export_provider.dart';
import 'package:helm/features/export/presentation/views/export_screen.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/domain/repositories/income_repository.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:helm/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/safe_to_spend/domain/safe_to_spend_calculator.dart';
import 'package:helm/features/safe_to_spend/presentation/providers/safe_to_spend_providers.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localizations.dart';

// ── Shared localisation delegates ─────────────────────────────────────────────

const _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _locales = [Locale('en'), Locale('bn')];

// ── No-op analytics stub ──────────────────────────────────────────────────────

class _NoOpAnalytics implements AnalyticsService {
  @override
  void trackEvent(String name, {Map<String, dynamic>? properties}) {}
  @override
  void trackScreen(String name) {}
}

// ── In-memory IncomeRepository stub ──────────────────────────────────────────

class _MemoryIncomeRepository implements IncomeRepository {
  final List<IncomeEntryEntity> _entries;

  _MemoryIncomeRepository([List<IncomeEntryEntity>? seed])
      : _entries = seed != null ? List.of(seed) : [];

  @override
  Future<void> addIncome(IncomeEntryEntity entity) async =>
      _entries.add(entity);

  @override
  Future<void> clearIncomes() async => _entries.clear();

  @override
  Future<void> deleteIncome(String id) async =>
      _entries.removeWhere((e) => e.id == id);

  @override
  List<IncomeEntryEntity> getIncomes() => List.unmodifiable(_entries);

  @override
  Future<void> updateIncome(IncomeEntryEntity entity) async {
    final idx = _entries.indexWhere((e) => e.id == entity.id);
    if (idx >= 0) {
      _entries[idx] = entity;
    } else {
      _entries.add(entity);
    }
  }
}

// ── Stub state notifiers ──────────────────────────────────────────────────────

class _StubFixedCostNotifier extends StateNotifier<List<FixedCostEntry>>
    implements FixedCostNotifier {
  _StubFixedCostNotifier() : super(const []);

  @override
  Future<void> addFixedCost(FixedCostEntry entry) async {
    state = [...state, entry];
  }

  @override
  Future<void> updateFixedCost(FixedCostEntry entry) async {}

  @override
  Future<void> deleteFixedCost(String id) async {}
}

class _StubStsSettingsNotifier extends StateNotifier<StsSettings>
    implements StsSettingsNotifier {
  _StubStsSettingsNotifier() : super(const StsSettings());

  @override
  Future<void> updateBufferPercent(double percent) async {
    state = state.copyWith(bufferPercent: percent);
  }

  @override
  Future<void> updateTaxRate(double rate) async {
    state = state.copyWith(taxRate: rate);
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  Future<void> updateAnxietyBuffer(double buffer) =>
      updateBufferPercent(buffer);
}

// ── No-op NudgeRepository stub ───────────────────────────────────────────────
// Implements the abstract NudgeRepository with no-ops so no Hive box is needed.

class _NoOpNudgeRepository implements NudgeRepository {
  @override
  Future<void> save(NudgeLogEntryEntity entry) async {}

  @override
  List<NudgeLogEntryEntity> getAll() => const [];

  @override
  int countUnread() => 0;

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markActioned(String id) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

// ── Stub NudgeListNotifier ────────────────────────────────────────────────────
// Extends NudgeListNotifier with a no-op repository so no Hive box is opened
// when DashboardScreen is rendered in widget tests.

class _StubNudgeListNotifier extends NudgeListNotifier {
  _StubNudgeListNotifier() : super(_NoOpNudgeRepository());
}

// ── No-op AnalyticsRepository stub ───────────────────────────────────────────

class _NoOpAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<void> save(AnalyticsEventEntity event) async {}

  @override
  Future<List<AnalyticsEventEntity>> getEventsSince(DateTime since) async =>
      [];

  @override
  Future<int> getEventCount(String eventName) async => 0;

  @override
  Future<AnalyticsEventEntity?> getLastEventOf(String eventName) async => null;
}

// ── Fake AuthNotifier (PIN setup) ─────────────────────────────────────────────

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier()
      : super();

  @override
  AuthState build() =>
      const AuthState(status: AuthStatus.setupRequired);

  @override
  Future<bool> authenticate(String pin) async => false;

  @override
  Future<void> setupPin(String pin) async {
    state = const AuthState(status: AuthStatus.authenticated);
  }
}

// ── Fake ExportNotifier ───────────────────────────────────────────────────────

class _FakeExportNotifier extends ExportNotifier {
  bool exportCalled = false;

  @override
  Future<void> export() async {
    exportCalled = true;
    state = ExportStatus.success;
  }
}

// ── GoRouter helpers ──────────────────────────────────────────────────────────

GoRouter _minimalRouter(Widget home, {List<GoRoute> extras = const []}) =>
    GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/welcome',
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
        ...extras,
      ],
    );

// ── Shared MaterialApp.router builder ─────────────────────────────────────────

Widget _app(
  Widget home, {
  List<Override> overrides = const [],
  List<GoRoute> extraRoutes = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: _minimalRouter(home, extras: extraRoutes),
      theme: AppTheme.light,
      locale: const Locale('en'),
      supportedLocales: _locales,
      localizationsDelegates: _delegates,
    ),
  );
}

// ── Helper: build a bare income entry ────────────────────────────────────────

IncomeEntryEntity _makeIncome({
  required String id,
  required IncomeStatus status,
  double amount = 10000.0,
  String currency = 'BDT',
  double? fxRate,
  DateTime? expectedDate,
  DateTime? receivedDate,
}) {
  final now = DateTime.now();
  return IncomeEntryEntity(
    id: id,
    clientName: 'Test Client',
    projectName: 'Test Project',
    amount: amount,
    currency: currency,
    status: status,
    expectedDate: expectedDate ?? now.add(const Duration(days: 7)),
    receivedDate: receivedDate,
    createdAt: now,
    updatedAt: now,
    fxRate: fxRate,
  );
}

// ── Suite setup ───────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 1 — Fresh onboarding → dashboard renders S2S hero
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 1 — Onboarding gate → Dashboard S2S hero', () {
    testWidgets(
        'onboarding NOT complete → OnboardingScreen renders',
        (tester) async {
      final repo = _MemoryIncomeRepository();

      await tester.pumpWidget(
        _app(
          const OnboardingScreen(),
          overrides: [
            analyticsProvider.overrideWithValue(_NoOpAnalytics()),
            incomeRepositoryProvider.overrideWithValue(repo),
            onboardingCompletedProvider.overrideWith((ref) => false),
            fixedCostNotifierProvider
                .overrideWith((_) => _StubFixedCostNotifier()),
            stsSettingsProvider
                .overrideWith((_) => _StubStsSettingsNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets(
        'onboarding complete → DashboardScreen renders with HelmLedgerHero',
        (tester) async {
      final repo = _MemoryIncomeRepository();
      final stubNudgeLog = _StubNudgeListNotifier();
      final stubNudgeSession = NudgeSessionService(
        evaluator: const NudgeEvaluator(),
        nudgeLog: stubNudgeLog,
        eventLogger: NudgeEventLogger(
          repository: _NoOpAnalyticsRepository(),
        ),
        analytics: _NoOpAnalytics(),
      );

      await tester.pumpWidget(
        _app(
          const DashboardScreen(),
          overrides: [
            analyticsProvider.overrideWithValue(_NoOpAnalytics()),
            incomeRepositoryProvider.overrideWithValue(repo),
            onboardingCompletedProvider.overrideWith((ref) => true),
            fixedCostNotifierProvider
                .overrideWith((_) => _StubFixedCostNotifier()),
            stsSettingsProvider
                .overrideWith((_) => _StubStsSettingsNotifier()),
            // Prevent TransactionLocalDataSourceImpl from opening a Hive box.
            transactionsProvider
                .overrideWith((_) => TransactionsNotifier.test([])),
            // Prevent NudgeDataSourceImpl from trying to open a Hive box.
            nudgeListProvider.overrideWith((_) => stubNudgeLog),
            nudgeSessionServiceProvider.overrideWithValue(stubNudgeSession),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(HelmLedgerHero), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 2 — Add income entry (Expected status) → appears in list
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 2 — Add income entry → appears in provider state', () {
    test('adding an Expected income entry via notifier reflects in state',
        () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [
          incomeRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      expect(container.read(incomeNotifierProvider), isEmpty);

      final id = IdGenerator.uniqueId();
      final entry = _makeIncome(id: id, status: IncomeStatus.expected);
      await notifier.addIncome(entry);

      final state = container.read(incomeNotifierProvider);
      expect(state.length, 1);
      expect(state.first.id, id);
      expect(state.first.clientName, 'Test Client');
      expect(state.first.status, IncomeStatus.expected);
    });

    test('adding multiple entries preserves order and count', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id1 = IdGenerator.uniqueId();
      final id2 = IdGenerator.uniqueId();

      await notifier.addIncome(
        _makeIncome(id: id1, status: IncomeStatus.expected, amount: 5000),
      );
      await notifier.addIncome(
        _makeIncome(id: id2, status: IncomeStatus.expected, amount: 8000),
      );

      final state = container.read(incomeNotifierProvider);
      expect(state.length, 2);
      expect(state.any((e) => e.id == id1), isTrue);
      expect(state.any((e) => e.id == id2), isTrue);
    });

    test('duplicate-id addIncome is silently ignored', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final entry = _makeIncome(id: id, status: IncomeStatus.expected);

      await notifier.addIncome(entry);
      await notifier.addIncome(entry); // duplicate — must be ignored

      expect(container.read(incomeNotifierProvider).length, 1);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 3 — Income transition: Expected → Pending → Received
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 3 — Income status machine: Expected → Pending → Received', () {
    test('Expected → Pending transition updates notifier state', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final entry = _makeIncome(id: id, status: IncomeStatus.expected);
      await notifier.addIncome(entry);

      expect(container.read(incomeNotifierProvider).first.status,
          IncomeStatus.expected);

      // Transition: expected → pending
      await notifier.updateIncome(
        entry.copyWith(
          status: IncomeStatus.pending,
          updatedAt: DateTime.now(),
        ),
      );

      expect(container.read(incomeNotifierProvider).first.status,
          IncomeStatus.pending);
    });

    test('Pending → Received transition updates notifier state', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final now = DateTime.now();

      // Start at pending
      final entry = _makeIncome(id: id, status: IncomeStatus.pending);
      await notifier.addIncome(entry);

      // Transition: pending → received
      await notifier.updateIncome(
        entry.copyWith(
          status: IncomeStatus.received,
          receivedDate: now,
          updatedAt: now,
        ),
      );

      final finalState = container.read(incomeNotifierProvider).first;
      expect(finalState.status, IncomeStatus.received);
      expect(finalState.receivedDate, isNotNull);
    });

    test('Full Expected → Pending → Received pipeline completes', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final now = DateTime.now();

      final entry = _makeIncome(id: id, status: IncomeStatus.expected);
      await notifier.addIncome(entry);
      expect(container.read(incomeNotifierProvider).first.status,
          IncomeStatus.expected);

      final pendingEntry =
          entry.copyWith(status: IncomeStatus.pending, updatedAt: now);
      await notifier.updateIncome(pendingEntry);
      expect(container.read(incomeNotifierProvider).first.status,
          IncomeStatus.pending);

      final receivedEntry = pendingEntry.copyWith(
        status: IncomeStatus.received,
        receivedDate: now,
        updatedAt: now,
      );
      await notifier.updateIncome(receivedEntry);

      final finalEntry = container.read(incomeNotifierProvider).first;
      expect(finalEntry.status, IncomeStatus.received);
      expect(finalEntry.receivedDate, isNotNull);
    });

    test('Received → Expected is forbidden and throws ArgumentError', () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final now = DateTime.now();

      final receivedEntry = _makeIncome(
        id: id,
        status: IncomeStatus.received,
        receivedDate: now,
      );
      await notifier.addIncome(receivedEntry);

      expect(
        () => notifier.updateIncome(
          receivedEntry.copyWith(
            status: IncomeStatus.expected,
            updatedAt: now,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 4 — S2S value recalculates after income status change
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 4 — SafeToSpendCalculator reflects income status changes', () {
    test('Expected income is NOT counted in S2S (totalReceivedIncomeBdt = 0)',
        () {
      final now = DateTime.now();
      final entry = _makeIncome(
        id: IdGenerator.uniqueId(),
        status: IncomeStatus.expected,
        amount: 10000,
        currency: 'BDT',
      );

      final result = SafeToSpendCalculator.calculate(
        incomeEntries: [entry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );

      expect(result.totalReceivedIncomeBdt, 0.0);
      expect(result.expectedIncome, 10000.0);
      expect(result.safeToSpend, 0.0);
    });

    test('Received BDT income IS counted and produces positive S2S', () {
      final now = DateTime.now();
      final entry = _makeIncome(
        id: IdGenerator.uniqueId(),
        status: IncomeStatus.received,
        amount: 10000,
        currency: 'BDT',
        receivedDate: now,
      );

      final result = SafeToSpendCalculator.calculate(
        incomeEntries: [entry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );

      expect(result.totalReceivedIncomeBdt, 10000.0);
      expect(result.expectedIncome, 0.0);
      expect(result.safeToSpend, greaterThan(0.0));
    });

    test('Marking Expected as Received increases S2S from 0 to positive', () {
      final now = DateTime.now();
      final id = IdGenerator.uniqueId();

      final expectedEntry = _makeIncome(
        id: id,
        status: IncomeStatus.expected,
        amount: 10000,
        currency: 'BDT',
      );

      final resultBefore = SafeToSpendCalculator.calculate(
        incomeEntries: [expectedEntry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );
      expect(resultBefore.safeToSpend, 0.0);

      final receivedEntry = expectedEntry.copyWith(
        status: IncomeStatus.received,
        receivedDate: now,
        updatedAt: now,
      );

      final resultAfter = SafeToSpendCalculator.calculate(
        incomeEntries: [receivedEntry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );
      expect(resultAfter.safeToSpend, greaterThan(0.0));
      expect(resultAfter.totalReceivedIncomeBdt, 10000.0);
    });

    test('Pending income appears in pendingIncome field, not S2S', () {
      final now = DateTime.now();
      final entry = _makeIncome(
        id: IdGenerator.uniqueId(),
        status: IncomeStatus.pending,
        amount: 5000,
        currency: 'BDT',
      );

      final result = SafeToSpendCalculator.calculate(
        incomeEntries: [entry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );

      expect(result.pendingIncome, 5000.0);
      expect(result.totalReceivedIncomeBdt, 0.0);
      expect(result.safeToSpend, 0.0);
    });

    test('USD received income without FX rate is excluded from S2S', () {
      final now = DateTime.now();
      final entry = _makeIncome(
        id: IdGenerator.uniqueId(),
        status: IncomeStatus.received,
        amount: 100,
        currency: 'USD',
        fxRate: null, // no FX rate → excluded
        receivedDate: now,
      );

      final result = SafeToSpendCalculator.calculate(
        incomeEntries: [entry],
        transactions: [],
        settings: const StsSettings(),
        fixedCosts: [],
        now: now,
      );

      expect(result.totalReceivedIncomeBdt, 0.0);
      expect(result.excludedUsdIncome, 100.0);
      expect(result.excludedUsdEntryCount, 1);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 5 — PIN setup flow: smoke test
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 5 — PIN setup: renders and accepts 6 digits', () {
    Widget buildPinSetupApp() {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const PinSetupScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier()),
          analyticsProvider.overrideWithValue(_NoOpAnalytics()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('en'),
          supportedLocales: _locales,
          localizationsDelegates: _delegates,
        ),
      );
    }

    testWidgets('PinSetupScreen renders with create-PIN title', (tester) async {
      await tester.pumpWidget(buildPinSetupApp());
      await tester.pumpAndSettle();

      expect(find.text('Create your PIN'), findsOneWidget);
    });

    testWidgets('PinSetupScreen shows numpad digits 0-9', (tester) async {
      await tester.pumpWidget(buildPinSetupApp());
      await tester.pumpAndSettle();

      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(find.text(d), findsOneWidget);
      }
    });

    testWidgets('entering 6 digits transitions to confirm step', (tester) async {
      await tester.pumpWidget(buildPinSetupApp());
      await tester.pumpAndSettle();

      // Tap digits 1-6
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(d).first);
        await tester.pump();
      }
      await tester.pump();

      // After 6 digits, screen should ask for PIN confirmation
      expect(find.text('Confirm your PIN'), findsOneWidget);
    });

    testWidgets('mismatched confirm PIN shows error message', (tester) async {
      await tester.pumpWidget(buildPinSetupApp());
      await tester.pumpAndSettle();

      // Enter first PIN: 123456
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(d).first);
        await tester.pump();
      }
      await tester.pump();

      // Enter confirm PIN: 654321 (mismatch)
      for (final d in ['6', '5', '4', '3', '2', '1']) {
        await tester.tap(find.text(d).first);
        await tester.pump();
      }
      await tester.pump();

      expect(find.text("PINs don't match. Try again."), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 6 — CSV export: share trigger fires
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 6 — CSV export: ExportScreen renders and export button present',
      () {
    Widget buildExportApp({_FakeExportNotifier? fakeNotifier}) {
      final notifier = fakeNotifier ?? _FakeExportNotifier();
      return ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(_NoOpAnalytics()),
          exportProvider.overrideWith((_) => notifier),
        ],
        child: MaterialApp.router(
          routerConfig: _minimalRouter(const ExportScreen()),
          theme: AppTheme.light,
          locale: const Locale('en'),
          supportedLocales: _locales,
          localizationsDelegates: _delegates,
        ),
      );
    }

    testWidgets('ExportScreen renders export button', (tester) async {
      await tester.pumpWidget(buildExportApp());
      await tester.pumpAndSettle();

      expect(find.byType(ExportScreen), findsOneWidget);
      // The export button contains a localised label; check for ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tapping export button calls notifier.export()', (tester) async {
      final fakeNotifier = _FakeExportNotifier();

      await tester.pumpWidget(buildExportApp(fakeNotifier: fakeNotifier));
      await tester.pumpAndSettle();

      // The export button may be below the default test-viewport fold (800×600).
      // Scroll it into view before tapping so the hit-test lands correctly.
      final buttonFinder = find.byType(ElevatedButton).first;
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump();

      expect(fakeNotifier.exportCalled, isTrue);
    });

    testWidgets(
        'ExportScreen shows export content items (income, transactions)',
        (tester) async {
      await tester.pumpWidget(buildExportApp());
      await tester.pumpAndSettle();

      // Check that check-circle icons are present (one per export item)
      expect(
        find.byIcon(Icons.check_circle_outline),
        findsWidgets,
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // FLOW 7 — Audit log: income transitions produce audit-linkable events
  // ────────────────────────────────────────────────────────────────────────────

  group('Flow 7 — Audit log: income mutations are traceable via repository',
      () {
    // The AuditLocalDataSourceImpl requires an open Hive box (infrastructure).
    // In widget tests we avoid real Hive entirely.  Instead, we verify the
    // income state machine at the domain layer — the audit chain is tested
    // separately in test/core and test/features/audit_log.
    //
    // Here we confirm that:
    //   a) adding income → entry appears in notifier state (auditable event)
    //   b) after status transitions, the state mirrors repository expectations
    //      that the audit system would observe.

    test(
        'after addIncome, state has 1 entry with created-equivalent data',
        () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final entry = _makeIncome(id: id, status: IncomeStatus.expected);

      await notifier.addIncome(entry);

      final state = container.read(incomeNotifierProvider);
      // An audit log INCOME_ADDED event would record these fields:
      expect(state.length, 1);
      expect(state.first.id, id);
      expect(state.first.clientName, 'Test Client');
      expect(state.first.status, IncomeStatus.expected);
    });

    test(
        'after status transition to Received, state reflects new status '
        'that audit system would record as a confirmed event',
        () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final now = DateTime.now();

      final entry = _makeIncome(id: id, status: IncomeStatus.expected);
      await notifier.addIncome(entry);

      // expected → pending
      await notifier.updateIncome(
        entry.copyWith(status: IncomeStatus.pending, updatedAt: now),
      );

      // pending → received (this is what audit event type 'confirmed' maps to)
      await notifier.updateIncome(
        entry.copyWith(
          status: IncomeStatus.received,
          receivedDate: now,
          updatedAt: now,
        ),
      );

      final finalState = container.read(incomeNotifierProvider).first;

      // The audit record for this would be AuditEventType.confirmed,
      // AuditEntityType.income, entityId = id.
      expect(finalState.id, id);
      expect(finalState.status, IncomeStatus.received);
      expect(finalState.receivedDate, isNotNull);
    });

    test(
        'deleteIncome removes entry from state — audit would record deleted event',
        () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final id = IdGenerator.uniqueId();
      final entry = _makeIncome(id: id, status: IncomeStatus.expected);

      await notifier.addIncome(entry);
      expect(container.read(incomeNotifierProvider).length, 1);

      await notifier.deleteIncome(id);

      // After deletion, the audit system would have recorded a deleted event.
      expect(container.read(incomeNotifierProvider), isEmpty);
    });

    test(
        'multiple income entries track independently — audit log would have '
        'distinct events per entity ID',
        () async {
      final repo = _MemoryIncomeRepository();
      final container = ProviderContainer(
        overrides: [incomeRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(incomeNotifierProvider.notifier);
      final now = DateTime.now();

      final id1 = IdGenerator.uniqueId();
      final id2 = IdGenerator.uniqueId();

      await notifier.addIncome(
          _makeIncome(id: id1, status: IncomeStatus.expected));
      await notifier.addIncome(
          _makeIncome(id: id2, status: IncomeStatus.expected));

      // Transition only id1 to received
      await notifier.updateIncome(
        _makeIncome(
          id: id1,
          status: IncomeStatus.received,
          receivedDate: now,
        ).copyWith(updatedAt: now),
      );

      final state = container.read(incomeNotifierProvider);
      expect(state.length, 2);

      final entry1 = state.firstWhere((e) => e.id == id1);
      final entry2 = state.firstWhere((e) => e.id == id2);

      // id1 → audit: confirmed event
      expect(entry1.status, IncomeStatus.received);
      // id2 → still expected; audit: created event only
      expect(entry2.status, IncomeStatus.expected);
    });
  });
}
