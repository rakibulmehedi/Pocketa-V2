// test/features/onboarding/onboarding_guard_test.dart
//
// Security regression test for H-21:
// OnboardingScreen must redirect to /home when the onboardingComplete
// SharedPreferences flag is already true. Without this guard, a user (or
// an attacker with physical access) could re-run onboarding and overwrite
// all STS settings, fixed costs, and liquid balance.

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
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/safe_to_spend/presentation/providers/safe_to_spend_providers.dart';
import 'package:helm/l10n/app_localizations.dart';

// ── Stub analytics ─────────────────────────────────────────────────────────────

class _NoOpAnalytics implements AnalyticsService {
  @override
  void trackEvent(String name, {Map<String, dynamic>? properties}) {}
  @override
  void trackScreen(String name) {}
}

// ── Stub notifiers ─────────────────────────────────────────────────────────────

class _StubIncomeNotifier extends StateNotifier<List<IncomeEntryEntity>>
    implements IncomeNotifier {
  _StubIncomeNotifier() : super(const []);
  @override
  Future<void> addIncome(IncomeEntryEntity entity) async {}
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
  Future<void> addFixedCost(FixedCostEntry entry) async {}
  @override
  Future<void> updateFixedCost(FixedCostEntry entry) async {}
  @override
  Future<void> deleteFixedCost(String id) async {}
}

class _StubStsSettingsNotifier extends StateNotifier<StsSettings>
    implements StsSettingsNotifier {
  _StubStsSettingsNotifier() : super(const StsSettings());
  @override
  Future<void> updateBufferPercent(double percent) async {}
  @override
  Future<void> updateTaxRate(double rate) async {}
  @override
  // ignore: deprecated_member_use_from_same_package
  Future<void> updateAnxietyBuffer(double buffer) async {}
}

// ── Helpers ────────────────────────────────────────────────────────────────────

/// Builds a router that places [OnboardingScreen] at '/' and captures
/// navigation to '/home' and '/welcome' via stub Scaffold widgets.
GoRouter _guardRouter() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Text('home_reached')),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) =>
              const Scaffold(body: Text('welcome_reached')),
        ),
      ],
    );

List<Override> _overrides({required bool onboardingDone}) => [
      analyticsProvider.overrideWithValue(_NoOpAnalytics()),
      incomeNotifierProvider.overrideWith((_) => _StubIncomeNotifier()),
      fixedCostNotifierProvider
          .overrideWith((_) => _StubFixedCostNotifier()),
      stsSettingsProvider
          .overrideWith((_) => _StubStsSettingsNotifier()),
      onboardingCompletedProvider.overrideWith((_) => onboardingDone),
    ];

Widget _buildApp({required bool onboardingDone}) => ProviderScope(
      overrides: _overrides(onboardingDone: onboardingDone),
      child: MaterialApp.router(
        routerConfig: _guardRouter(),
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

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  group('H-21: OnboardingScreen guard — already-completed redirect', () {
    testWidgets(
      'redirects to /home when onboarding is already complete',
      (tester) async {
        // Prime SharedPreferences with completed = true.
        await SharedPrefServices.setOnboardingCompleted(true);

        await tester.pumpWidget(_buildApp(onboardingDone: true));
        // One pump triggers the build; pumpAndSettle waits for
        // addPostFrameCallback + GoRouter navigation to settle.
        await tester.pumpAndSettle();

        // The stub home page must be in the tree.
        expect(find.text('home_reached'), findsOneWidget);
        // The OnboardingScreen itself must no longer be visible.
        expect(find.byType(OnboardingScreen), findsNothing);
      },
    );

    testWidgets(
      'does NOT redirect when onboarding is not yet complete',
      (tester) async {
        await SharedPrefServices.setOnboardingCompleted(false);

        await tester.pumpWidget(_buildApp(onboardingDone: false));
        await tester.pumpAndSettle();

        // OnboardingScreen should still be shown.
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.text('home_reached'), findsNothing);
      },
    );
  });
}
