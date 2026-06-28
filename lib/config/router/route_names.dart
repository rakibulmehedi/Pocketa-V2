// lib/config/router/route_names.dart
//
// Single source of truth for all route paths in Helm.
// Import this wherever a route path is needed — never hard-code strings.

abstract final class RouteNames {
  // ── startup ────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';

  // ── shell tabs (main app) ──────────────────────────────────────────────────
  // `dashboard` kept as alias for backward-compat; value matches `home`.
  static const String dashboard = '/home';
  static const String home = '/home';
  static const String pipeline = '/pipeline';
  static const String spend = '/spend';
  static const String trace = '/trace';
  static const String settings = '/settings';

  // ── transactions ────────────────────────────────────────────────────────────
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction/:id';

  // ── income ───────────────────────────────────────────────────────────────────
  static const String addIncome = '/add-income';
  static const String editIncome = '/edit-income/:id';

  // ── safe to spend ─────────────────────────────────────────────────────────────
  static const String stsSettings = '/sts-settings';

  // ── auth (D1 Trust Layer) ──────────────────────────────────────────────────
  static const String magicLink = '/magic-link';
  static const String pinSetup = '/pin-setup';
  static const String pinEntry = '/pin-entry';

  // ── audit log (D1.07) ─────────────────────────────────────────────────────
  static const String auditLog = '/audit-log';

  // ── history (M-13: alias for audit-log, surfaced in Settings / History) ───
  static const String history = '/history';

  // ── account management (D1.10) ────────────────────────────────────────────
  static const String deleteAccount = '/delete-account';

  // ── notifications (Phase 3) ─────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── export (D1.09) ────────────────────────────────────────────────────────
  static const String exportData = '/export-data';
}
