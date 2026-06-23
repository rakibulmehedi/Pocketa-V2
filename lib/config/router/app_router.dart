// lib/config/router/app_router.dart
//
// Central GoRouter configuration for Helm.
//
// Guard logic:
//   - If onboarding is NOT completed → always redirect to /welcome
//   - If onboarding IS completed     → redirect / and /welcome to /home
//
// Shell structure (UX-1.07):
//   ShellRoute wraps the 3 primary tabs (Home, Pipeline, Spend).
//   Splash, Welcome, Onboarding, and modal routes live outside the shell.
//
// All route paths live in RouteNames — never duplicate strings here.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart'
    show authRefreshListenable, isSessionAuthenticated;
import 'package:helm/features/auth/presentation/views/magic_link_screen.dart';
import 'package:helm/features/auth/presentation/views/pin_entry_screen.dart';
import 'package:helm/features/auth/presentation/views/pin_setup_screen.dart';
import 'package:helm/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:helm/features/income/presentation/views/add_income_screen.dart';
import 'package:helm/features/income/presentation/views/pipeline_screen.dart';
import 'package:helm/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:helm/features/onboarding/presentation/views/welcome_screen.dart';
import 'package:helm/features/account/presentation/views/delete_account_screen.dart';
import 'package:helm/features/audit_log/presentation/views/audit_log_screen.dart';
import 'package:helm/features/export/presentation/views/export_screen.dart';
import 'package:helm/features/safe_to_spend/presentation/views/sts_settings_screen.dart';
import 'package:helm/features/splash/views/splash_screen.dart';
import 'package:helm/features/transactions/presentation/views/add_transaction_screen.dart';
import 'package:helm/core/nudge/presentation/screens/notification_center_screen.dart';

/// The single [GoRouter] instance used by [MaterialApp.router].
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  redirect: _globalRedirect,
  refreshListenable: authRefreshListenable,
  routes: [
    // ── Pre-shell routes (no bottom navigation) ───────────────────────────────
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Shell: 3-tab main app (UX-1.07) ──────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) =>
          _AppShell(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.pipeline,
          name: 'pipeline',
          builder: (context, state) => const PipelineScreen(),
        ),
        GoRoute(
          path: RouteNames.spend,
          name: 'spend',
          builder: (context, state) => const SpendScreen(),
        ),
      ],
    ),

    // ── Modal / overlay routes (no bottom navigation) ─────────────────────────
    GoRoute(
      path: RouteNames.addTransaction,
      name: 'addTransaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: RouteNames.editTransaction,
      name: 'editTransaction',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final safeId = InputValidator.isValidId(id) ? id : null;
        return AddTransactionScreen(transactionId: safeId);
      },
    ),
    GoRoute(
      path: RouteNames.addIncome,
      name: 'addIncome',
      builder: (context, state) => const AddIncomeScreen(),
    ),
    GoRoute(
      path: RouteNames.editIncome,
      name: 'editIncome',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (!InputValidator.isValidId(id)) return const AddIncomeScreen();
        return AddIncomeScreen(incomeId: id);
      },
    ),
    GoRoute(
      path: RouteNames.stsSettings,
      name: 'stsSettings',
      builder: (context, state) => const StsSettingsScreen(),
    ),
    // /settings is the canonical push-overlay alias for /sts-settings.
    // Kept separate so existing callers (Dashboard gear, notification centre,
    // next-best-action card) and future deep-links all resolve correctly.
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => const StsSettingsScreen(),
    ),

    // ── Auth routes (D1 Trust Layer) ──────────────────────────────────────────
    GoRoute(
      path: RouteNames.magicLink,
      name: 'magicLink',
      builder: (context, state) {
        return MagicLinkScreen(
          onAuthenticated: () async {
            await SharedPrefServices.setMagicLinkAuthCompleted(true);
            // Cross-validate: mirror flag into Hive authBox so the magic-link
            // gate can confirm the flag was not set by spoofing SharedPrefs.
            if (Hive.isBoxOpen(AppBoxNames.authBox)) {
              await Hive.box<dynamic>(AppBoxNames.authBox).put('magic_link_verified', true);
            }
            if (context.mounted) context.go(RouteNames.home);
          },
          onGuest: () async {
            await SharedPrefServices.setMagicLinkAuthCompleted(true);
            await SharedPrefServices.setGuestMode(true);
            if (Hive.isBoxOpen(AppBoxNames.authBox)) {
              await Hive.box<dynamic>(AppBoxNames.authBox).put('magic_link_verified', true);
            }
            if (context.mounted) context.go(RouteNames.home);
          },
        );
      },
    ),
    GoRoute(
      path: RouteNames.pinSetup,
      name: 'pinSetup',
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: RouteNames.pinEntry,
      name: 'pinEntry',
      builder: (context, state) => const PinEntryScreen(),
    ),

    // ── Audit log (D1.07) ─────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.auditLog,
      name: 'auditLog',
      builder: (context, state) => const AuditLogScreen(),
    ),
    // /trace is the canonical push-overlay alias for /audit-log.
    // _identityRoutes guest-gating uses RouteNames.trace, so this must stay
    // registered as a standalone route.
    GoRoute(
      path: RouteNames.trace,
      name: 'trace',
      builder: (context, state) => const AuditLogScreen(),
    ),
    // /history (M-13): Settings + History AppBar actions use this path.
    // Resolves to AuditLogScreen, same as /audit-log and /trace.
    GoRoute(
      path: RouteNames.history,
      name: 'history',
      builder: (context, state) => const AuditLogScreen(),
    ),

    // ── Account management (D1.10) ────────────────────────────────────────────
    GoRoute(
      path: RouteNames.deleteAccount,
      name: 'deleteAccount',
      builder: (context, state) => const DeleteAccountScreen(),
    ),

    // ── Export (D1.09) ────────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.exportData,
      name: 'exportData',
      builder: (context, state) => const ExportScreen(),
    ),

    // ── Notifications (Phase 3) ───────────────────────────────────────────────
    GoRoute(
      path: RouteNames.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Shell scaffold: persistent bottom navigation (UX-1.07)
// ---------------------------------------------------------------------------

class _TabItem {
  const _TabItem({
    required this.path,
    required this.icon,
    required this.label,
    required this.tooltip,
  });
  final String path;
  final IconData icon;
  final String label;
  final String tooltip;
}

const List<_TabItem> _tabs = [
  _TabItem(
    path: RouteNames.home,
    icon: Icons.home_rounded,
    label: 'Home',
    tooltip: 'Safe-to-Spend',
  ),
  _TabItem(
    path: RouteNames.pipeline,
    icon: Icons.account_balance_wallet_rounded,
    label: 'Pipeline',
    tooltip: 'Income pipeline',
  ),
  _TabItem(
    path: RouteNames.spend,
    icon: Icons.wallet_rounded,
    label: 'Spend',
    tooltip: 'Money spent',
  ),
];

/// Test-only accessor for the bottom-nav tab labels.
List<String> get debugAppShellTabLabels =>
    _tabs.map((t) => t.label).toList(growable: false);

class _AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _AppShell({required this.location, required this.child});

  int get _currentIndex {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;
    final l10n = context.l10n;

    // Localized label / tooltip pairs — same order as _tabs.
    final tabLabels = [l10n.tabHome, l10n.tabPipeline, l10n.tabSpend];
    final tabTips = [l10n.tabHomeTip, l10n.tabPipelineTip, l10n.tabSpendTip];

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        selectedItemColor: colors.interactive,
        unselectedItemColor: colors.inkTertiary,
        backgroundColor: colors.surface,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: typography.labelSm,
        unselectedLabelStyle: typography.labelSm,
        elevation: 0,
        items: List.generate(
          _tabs.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(_tabs[i].icon),
            label: tabLabels[i],
            tooltip: tabTips[i],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Global redirect
// ---------------------------------------------------------------------------

/// Public routes that do not require an authenticated session.
/// Must match the set in [auth_provider.dart].
const Set<String> _publicRoutes = {
  RouteNames.splash,
  RouteNames.welcome,
  RouteNames.onboarding,
  RouteNames.magicLink,
  RouteNames.pinSetup,
  RouteNames.pinEntry,
};

/// Routes that require an email-verified identity (not available to guests).
/// Guests verified via PIN but skipped magic-link identity verification.
const Set<String> _identityRoutes = {
  RouteNames.auditLog,
  RouteNames.trace,
  RouteNames.deleteAccount,
};

/// Called before every navigation. Returns null to allow, or a path to redirect.
///
/// This redirect is intentionally **fail-closed**:
///   - Public routes are whitelisted explicitly.
///   - All other routes require Magic Link complete → onboarding complete →
///     PIN set up + an active authenticated session.
///   - If auth state cannot be determined, the user is redirected to PIN entry.
String? _globalRedirect(BuildContext context, GoRouterState state) {
  final String currentPath = state.matchedLocation;

  // ── Magic Link gate ───────────────────────────────────────────────────────
  // Identity verification (or explicit guest opt-in) must complete before
  // the app allows data entry. The SharedPrefs flag is cross-validated
  // against the Hive authBox to resist spoofing via SharedPrefs backup-restore.
  final bool magicLinkDone = SharedPrefServices.getMagicLinkAuthCompleted();
  if (!magicLinkDone) {
    // Not verified yet — send to magic-link, or stay there (early return
    // prevents the onboarding gate below from redirecting away from /magic-link).
    return currentPath == RouteNames.magicLink ? null : RouteNames.magicLink;
  }
  // Cross-validate: if the Hive box is open and lacks the mirrored flag,
  // the SharedPrefs flag may have been spoofed — re-run verification.
  // If the box is not open (startup race before Hive init), allow through.
  if (Hive.isBoxOpen(AppBoxNames.authBox)) {
    final box = Hive.box<dynamic>(AppBoxNames.authBox);
    final bool hiveVerified = box.get('magic_link_verified', defaultValue: false) == true;
    if (!hiveVerified) {
      return currentPath == RouteNames.magicLink ? null : RouteNames.magicLink;
    }
  }
  // Identity verified — don't allow re-entry into the magic-link flow.
  if (currentPath == RouteNames.magicLink) return RouteNames.home;

  // ── Onboarding gate ───────────────────────────────────────────────────────
  final bool onboardingDone = SharedPrefServices.getOnboardingCompleted();
  if (!onboardingDone) {
    final bool isPreOnboardingPath =
        currentPath == RouteNames.splash ||
        currentPath == RouteNames.welcome ||
        currentPath == RouteNames.onboarding;

    if (!isPreOnboardingPath) return RouteNames.welcome;
    return null;
  }

  // Onboarding done: splash/welcome/onboarding have nothing useful to show.
  if (currentPath == RouteNames.splash ||
      currentPath == RouteNames.welcome ||
      currentPath == RouteNames.onboarding) {
    return RouteNames.home;
  }

  // ── PIN gate (fail-closed) ────────────────────────────────────────────────
  // Public routes are allowed through. Everything else needs PIN + session.
  if (_publicRoutes.contains(currentPath)) {
    return null;
  }

  final bool authBoxOpen = Hive.isBoxOpen(AppBoxNames.authBox);
  if (!authBoxOpen) {
    // Cannot determine auth state — treat as locked and force PIN entry.
    return RouteNames.pinEntry;
  }

  final box = Hive.box<dynamic>(AppBoxNames.authBox);
  final bool pinIsSetUp = box.get('pin_is_setup', defaultValue: false) == true;
  if (!pinIsSetUp) {
    return RouteNames.pinSetup;
  }

  // PIN is set up but session not authenticated — force PIN entry.
  if (!isSessionAuthenticated) {
    return RouteNames.pinEntry;
  }

  // ── Guest route restrictions ──────────────────────────────────────────────
  // Guests skipped email identity verification — block identity-specific routes.
  if (SharedPrefServices.getGuestMode() && _identityRoutes.contains(currentPath)) {
    return RouteNames.home;
  }

  return null;
}
