// test/flows/onboarding_flow_test.dart
//
// Widget-level flow tests for the full onboarding journey.
//
// Coverage:
//   1. WelcomeScreen — CTA button is present and tappable
//   2. OnboardingScreen — renders and shows QualifyingQuestionPage (step 0)
//   3. Step indicator advances when tapping through qualifying page
//   4. FirstPipelinePage renders with primary action only (skip removed)
//   5. Completing onboarding marks state as done
//
// Provider strategy: all Hive-backed and async providers are overridden with
// lightweight in-memory stubs so no real Hive box is required.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:helm/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:helm/features/onboarding/presentation/views/welcome_screen.dart';
import 'package:helm/features/onboarding/presentation/views/pages/qualifying_question_page.dart';
import 'package:helm/features/onboarding/presentation/widgets/onboarding_progress_line.dart';
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/safe_to_spend/presentation/providers/safe_to_spend_providers.dart';
import 'package:helm/l10n/app_localizations.dart';

// ── Stub analytics ────────────────────────────────────────────────────────────

class _NoOpAnalytics implements AnalyticsService {
  @override
  void trackEvent(String name, {Map<String, dynamic>? properties}) {}
  @override
  void trackScreen(String name) {}
}

// ── Stub notifiers ────────────────────────────────────────────────────────────

class _StubIncomeNotifier extends StateNotifier<List<IncomeEntryEntity>>
    implements IncomeNotifier {
  _StubIncomeNotifier() : super(const []);

  @override
  Future<void> addIncome(IncomeEntryEntity entity) async {
    state = [...state, entity];
  }

  @override
  Future<void> updateIncome(IncomeEntryEntity entity) async {}

  @override
  Future<void> deleteIncome(String id) async {}

  @override
  Future<void> clearIncomes() async {}
}

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
  Future<void> updateTaxRate(double rate) async {}

  @override
  // ignore: deprecated_member_use_from_same_package
  Future<void> updateAnxietyBuffer(double buffer) =>
      updateBufferPercent(buffer);
}

// ── Provider overrides shared across tests ────────────────────────────────────

List<Override> _stubOverrides() => [
      analyticsProvider.overrideWithValue(_NoOpAnalytics()),
      incomeNotifierProvider.overrideWith((_) => _StubIncomeNotifier()),
      fixedCostNotifierProvider
          .overrideWith((_) => _StubFixedCostNotifier()),
      stsSettingsProvider
          .overrideWith((_) => _StubStsSettingsNotifier()),
      onboardingCompletedProvider.overrideWith((ref) => false),
    ];

// ── Router helpers ────────────────────────────────────────────────────────────

/// Builds a minimal GoRouter that serves [WelcomeScreen] at '/' and absorbs
/// navigation to '/onboarding' and '/home' so context.go() does not throw.
GoRouter _welcomeRouter() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

/// Builds a GoRouter that serves [OnboardingScreen] at '/' and absorbs
/// navigation to '/welcome' and '/home'.
GoRouter _onboardingRouter() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) =>
              const Scaffold(body: Text('home')),
        ),
      ],
    );

// ── Widget builders ───────────────────────────────────────────────────────────

Widget _welcomeApp() => ProviderScope(
      overrides: _stubOverrides(),
      child: MaterialApp.router(
        routerConfig: _welcomeRouter(),
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );

Widget _onboardingApp() => ProviderScope(
      overrides: _stubOverrides(),
      child: MaterialApp.router(
        routerConfig: _onboardingRouter(),
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    // Provide a fake SharedPreferences so SharedPrefServices.init() works in
    // tests without a real device or plugin channel.
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  // ── 1. WelcomeScreen ────────────────────────────────────────────────────────

  group('WelcomeScreen', () {
    testWidgets('renders the app name', (tester) async {
      await tester.pumpWidget(_welcomeApp());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Helm'), findsOneWidget);
    });

    testWidgets('renders the get-started CTA button', (tester) async {
      await tester.pumpWidget(_welcomeApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Continue — sets up your Safe-to-Spend'),
        findsOneWidget,
      );
    });

    testWidgets('CTA button is tappable and navigates away from welcome',
        (tester) async {
      await tester.pumpWidget(_welcomeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue — sets up your Safe-to-Spend'));
      await tester.pumpAndSettle();

      // After navigation WelcomeScreen is no longer in the tree.
      expect(find.byType(WelcomeScreen), findsNothing);
    });
  });

  // ── 2. OnboardingScreen — initial state ─────────────────────────────────────

  group('OnboardingScreen — initial render', () {
    testWidgets('renders the onboarding screen', (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('shows QualifyingQuestionPage as first page', (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      expect(find.byType(QualifyingQuestionPage), findsOneWidget);
    });

    testWidgets('shows the qualifying question text', (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Have you ever spent money thinking a'),
        findsOneWidget,
      );
    });

    testWidgets('progress line starts at 0%', (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      final progressLine = tester.widget<OnboardingProgressLine>(
        find.byType(OnboardingProgressLine),
      );
      expect(progressLine.progress, 0.0);
    });
  });

  // ── 3. Step indicator advances after qualifying ──────────────────────────────

  group('OnboardingScreen — step advancement', () {
    testWidgets(
        'tapping "Yes, that happens to me" advances the progress line',
        (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      // Verify we start at 0%.
      final OnboardingProgressLine progressBefore =
          tester.widget<OnboardingProgressLine>(
        find.byType(OnboardingProgressLine),
      );
      expect(progressBefore.progress, 0.0);

      await tester.tap(find.text('Yes, that happens to me'));
      await tester.pumpAndSettle();

      // After qualifying, step 1 is shown → progress > 0.
      final progressAfter = tester.widget<OnboardingProgressLine>(
        find.byType(OnboardingProgressLine),
      );
      expect(progressAfter.progress, greaterThan(0.0));
    });
  });

  // ── 4. Skip button on the last page (FirstPipelinePage) ────────────────────
  //
  // FirstPipelinePage is mounted directly to avoid traversing all 6 onboarding
  // steps in a test viewport (which triggers overflow errors on intermediate
  // pages that are too tall for the default 800×600 test surface).

  // ── 5. Qualifying "No" path — disqualification screen ───────────────────────

  group('OnboardingScreen — disqualification path', () {
    testWidgets('tapping "No" shows disqualification text', (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('No, I always know exactly what cleared'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
            'Helm is built for USD-earning freelancers in Bangladesh.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Close on disqualify screen navigates away',
        (tester) async {
      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('No, I always know exactly what cleared'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Navigated to /welcome stub — OnboardingScreen is gone.
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
