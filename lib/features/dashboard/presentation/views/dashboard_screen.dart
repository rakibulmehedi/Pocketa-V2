// lib/features/dashboard/presentation/views/dashboard_screen.dart
//
// Paper Ledger reskin of the Dashboard Cockpit (UX-1.08).
//
// Signal Deck widgets replaced with Paper Ledger equivalents:
//   HelmSignalHero    → HelmLedgerHero
//   HelmDecisionDeck  → HelmNextEventCard
//   HelmSignalHorizon → removed (rail lives inside HelmLedgerHero)
//
// Violations removed:
//   - Income / Expense summary chip row (DASH-004)
//   - Recent Transactions list (DASH-004)
//   - Transaction filter chips
//   - Dev reset button in production (UX-1.11)
//
// D2.03 — analytics: stsViewed + dailyActiveSession on initState,
//          calculationBreakdownOpened on onTapTrace.

import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/nudge/presentation/providers/nudge_providers.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/utils/number_formatter.dart';
import 'package:helm/core/widgets/helm_calculation_trace.dart';
import 'package:helm/core/widgets/ledger/helm_ledger_hero.dart';
import 'package:helm/core/widgets/ledger/helm_next_event_card.dart';
import 'package:helm/core/widgets/ledger/ledger_state.dart';
import 'package:helm/features/dashboard/domain/affirmation.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/safe_to_spend/domain/entities/safe_to_spend_result.dart';
import 'package:helm/features/safe_to_spend/presentation/providers/safe_to_spend_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showStsHint = false;
  String? _affirmation;
  final _s2sStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _s2sStopwatch.start();
    // A3.2 — Show one-time S2S hint on first dashboard view.
    // Guard against uninitialized SharedPrefServices (e.g. widget tests).
    try {
      if (!SharedPrefServices.getStsHintShown()) {
        _showStsHint = true;
      }
    } on StateError {
      // Not initialized; default _showStsHint remains false.
    }
    // D2.03 — Fire session-open analytics events on every dashboard mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _s2sStopwatch.stop();

      // Guard against infrastructure not being initialized (e.g. widget tests).
      SafeToSpendResult stsResult;
      List<IncomeEntryEntity> incomeEntries;
      try {
        stsResult = ref.read(safeToSpendProvider);
        incomeEntries = ref.read(incomeNotifierProvider);
      } on Object {
        return; // Skip analytics when data infrastructure is unavailable.
      }

      final analytics = ref.read(analyticsProvider);

      // P4.4: time to S2S visible
      analytics.trackEvent(
        TransactionalEvents.timeToS2sVisible,
        properties: {
          EventProperties.durationMs: _s2sStopwatch.elapsedMilliseconds
              .toString(),
        },
      );
      analytics.trackEvent(TransactionalEvents.stsViewed);
      analytics.trackEvent(
        BoundaryEvents.dailyActiveSession,
        properties: {
          EventProperties.sessionDate: DateTime.now()
              .toIso8601String()
              .substring(0, 10),
        },
      );

      // P1.1: sts_at_risk_entered — fire once per session
      try {
        if (stsResult.rawSafeToSpend <= -stsResult.anxietyBuffer &&
            !SharedPrefServices.getEventFired(BoundaryEvents.stsAtRiskEntered)) {
          analytics.trackEvent(BoundaryEvents.stsAtRiskEntered);
          SharedPrefServices.setEventFired(BoundaryEvents.stsAtRiskEntered);
        }

        // P1.2: reserve_depleted — fire once per session
        if (stsResult.anxietyBuffer == 0 &&
            !SharedPrefServices.getEventFired(BoundaryEvents.reserveDepleted)) {
          analytics.trackEvent(BoundaryEvents.reserveDepleted);
          SharedPrefServices.setEventFired(BoundaryEvents.reserveDepleted);
        }
      } on StateError {
        // SharedPrefServices not initialized; skip event-fired checks.
      }

      // P2: Compute affirmation for trust strip
      _computeAffirmation();

      // P3: Run nudge evaluator on every session start
      _evaluateNudge(stsResult, incomeEntries);
    });
  }

  void _computeAffirmation() {
    final incomeEntries = ref.read(incomeNotifierProvider);
    final now = DateTime.now();
    final overdueCount = incomeEntries
        .where(
          (e) =>
              e.status == IncomeStatus.expected && e.expectedDate.isBefore(now),
        )
        .length;
    final sessionCount = SharedPrefServices.getSessionCount();
    SharedPrefServices.incrementSessionCount();

    final result = Affirmation.compute(
      overdueEntryCount: overdueCount,
      sessionCount: sessionCount,
    );
    setState(() {
      _affirmation = result.type != AffirmationType.none ? result.copy : null;
    });
  }

  void _evaluateNudge(
    SafeToSpendResult stsResult,
    List<IncomeEntryEntity> incomeEntries,
  ) {
    final now = DateTime.now();
    final overdueCount = incomeEntries
        .where(
          (e) =>
              e.status == IncomeStatus.expected && e.expectedDate.isBefore(now),
        )
        .length;
    final totalEntries = incomeEntries.length;

    // Determine S2S state
    final s2sState = switch (stsResult) {
      SafeToSpendResult(:final rawSafeToSpend, :final anxietyBuffer)
          when rawSafeToSpend <= -anxietyBuffer =>
        'atRisk',
      SafeToSpendResult(:final safeToSpend) when safeToSpend > 0 => 'safe',
      _ => 'noData',
    };

    // Find oldest overdue entry
    final overdueEntries = incomeEntries.where(
      (e) => e.status == IncomeStatus.expected && e.expectedDate.isBefore(now),
    );
    final String? oldestOverdueId = overdueEntries.isNotEmpty
        ? overdueEntries
              .reduce((a, b) => a.expectedDate.isBefore(b.expectedDate) ? a : b)
              .id
        : null;

    final sessionService = ref.read(nudgeSessionServiceProvider);
    unawaited(
      sessionService.evaluateAndLog(
        overdueCount: overdueCount,
        totalEntries: totalEntries,
        s2sState: s2sState,
        oldestOverdueEntryId: oldestOverdueId,
      ),
    );
  }

  void _dismissStsHint() {
    setState(() => _showStsHint = false);
    SharedPrefServices.setStsHintShown(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    // Guard against Hive/SharedPreferences not being open in test environments.
    SafeToSpendResult stsResult;
    List<IncomeEntryEntity> incomeEntries;
    try {
      stsResult = ref.watch(safeToSpendProvider);
      incomeEntries = ref.watch(incomeNotifierProvider);
    } on Object {
      stsResult = const SafeToSpendResult.zero();
      incomeEntries = const [];
    }

    final now = DateTime.now();
    final overdueCount = incomeEntries
        .where(
          (e) =>
              e.status == IncomeStatus.expected && e.expectedDate.isBefore(now),
        )
        .length;

    final deck = _buildNextEventAction(
      stsResult,
      overdueCount,
      incomeEntries.isEmpty,
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(
          context.l10n.appName,
          style: typography.headingMd.copyWith(
            color: colors.inkPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!SharedPrefServices.getGuestMode())
            IconButton(
              key: const ValueKey('dashboard-audit-link'),
              tooltip: context.l10n.viewAuditTrail,
              icon: const HelmIcon(LucideIcons.history, size: HelmIconSize.lg),
              onPressed: () => context.push(RouteNames.trace),
            ),
          IconButton(
            key: const ValueKey('dashboard-settings-gear'),
            tooltip: context.l10n.settings,
            icon: const HelmIcon(LucideIcons.settings, size: HelmIconSize.lg),
            onPressed: () => context.push(RouteNames.settings),
          ),
          // UX-1.11 — dev reset gated to debug builds only.
          if (kDebugMode)
            IconButton(
              tooltip: context.l10n.devResetOnboarding,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () async {
                // M-30: confirmation dialog prevents accidental resets.
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset all data?'),
                    content: const Text(
                      'This will delete all income, transactions, and settings. '
                      'Cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                await SharedPrefServices.setOnboardingCompleted(false);
                if (context.mounted) context.go(RouteNames.welcome);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: HelmSpacing.s4,
            bottom: 100, // FAB + bottom nav clearance
          ),
          child: Column(
            children: [
              // A3.2 — One-time S2S hint
              if (_showStsHint)
                Padding(
                  padding: const EdgeInsets.only(
                    left: HelmSpacing.screenEdge,
                    right: HelmSpacing.screenEdge,
                    bottom: HelmSpacing.s3,
                  ),
                  child: GestureDetector(
                    onTap: _dismissStsHint,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 18,
                            color: colors.interactive,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.l10n.tapToSeeMath,
                              style: typography.bodySm.copyWith(
                                color: colors.interactive,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colors.inkTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HelmSpacing.screenEdge,
                ),
                child: Column(
                  children: [
                    HelmLedgerHero(
                      safeToSpend: stsResult.safeToSpend,
                      state: _ledgerState(stsResult),
                      runwayLabel: _affirmation ?? _runwayLabel(stsResult),
                      showUnavailable: _showUnavailableAmount(stsResult),
                      committedValue: _compactBdtValue(stsResult.fixedCostsDue),
                      reserveValue: _compactBdtValue(stsResult.anxietyBuffer),
                      pendingValue: _compactBdtValue(stsResult.pendingIncome),
                      onTapTrace: () => _openCalculationTrace(stsResult),
                    ),
                    const SizedBox(height: HelmSpacing.s4),
                    HelmNextEventCard(
                      eventLabel: deck.eventLabel,
                      eventTitle: deck.eventTitle,
                      actionLabel: deck.actionLabel,
                      onTrace: () => _openCalculationTrace(stsResult),
                      onAction: () => context.push(deck.routePath),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCalculationTrace(SafeToSpendResult stsResult) {
    ref
        .read(analyticsProvider)
        .trackEvent(TransactionalEvents.calculationBreakdownOpened);
    HelmCalculationTrace.show(context, stsResult);
  }

  LedgerState _ledgerState(SafeToSpendResult result) {
    if (result.rawSafeToSpend > 0) return LedgerState.safe;
    if (result.rawSafeToSpend > -result.anxietyBuffer) return LedgerState.tight;
    return LedgerState.atRisk;
  }

  String _runwayLabel(SafeToSpendResult result) {
    if (result.error != null) return 'Calculation needs review';
    if (result.rawSafeToSpend <= -result.anxietyBuffer) {
      return 'Review commitments before spending';
    }
    if (result.rawSafeToSpend <= 0) return 'Buffer pressure detected';
    return 'Current commitments covered';
  }

  bool _showUnavailableAmount(SafeToSpendResult result) {
    return result.error != null ||
        (result.safeToSpend == 0 && result.totalReceivedIncomeBdt == 0);
  }

  String _compactBdtValue(double amount) =>
      NumberFormatter.formatBDTCompact(amount).replaceFirst('tk ', '৳');

  _NextEventAction _buildNextEventAction(
    SafeToSpendResult stsResult,
    int overdueCount,
    bool isPipelineEmpty,
  ) {
    if (isPipelineEmpty) {
      return const _NextEventAction(
        eventLabel: 'NEXT STEP',
        eventTitle: 'Add your first expected payment',
        actionLabel: 'ADD PAYMENT',
        routePath: RouteNames.addIncome,
      );
    }
    if (overdueCount > 0) {
      return _NextEventAction(
        eventLabel: 'NEEDS ATTENTION',
        eventTitle: overdueCount == 1
            ? '1 payment overdue'
            : '$overdueCount payments overdue',
        actionLabel: 'REVIEW FLOW',
        routePath: RouteNames.pipeline,
      );
    }
    if (stsResult.rawSafeToSpend <= 0) {
      return const _NextEventAction(
        eventLabel: 'RESERVE MODE',
        eventTitle: 'Safe-to-Spend needs review',
        actionLabel: 'REVIEW COMMITMENTS',
        routePath: RouteNames.stsSettings,
      );
    }

    return const _NextEventAction(
      eventLabel: 'NEXT EVENT',
      eventTitle: 'Pipeline up to date',
      actionLabel: 'REVIEW FLOW',
      routePath: RouteNames.pipeline,
    );
  }
}

class _NextEventAction {
  const _NextEventAction({
    required this.eventLabel,
    required this.eventTitle,
    required this.actionLabel,
    required this.routePath,
  });

  final String eventLabel;
  final String eventTitle;
  final String actionLabel;
  final String routePath;
}
