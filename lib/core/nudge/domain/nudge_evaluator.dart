// lib/core/nudge/domain/nudge_evaluator.dart
//
// Pure domain logic for the Nudge Evaluator Engine (Phase 3, Group 3B).
//
// Evaluates pipeline + S2S state against a set of ranked rules and returns
// the highest-priority applicable nudge decision.
//
// Rule priority order (first match wins):
//   1. Overdue pipeline entries → confirmOverdue
//   2. S2S at risk + no overdue → reviewFixedCosts (in-app only)
//   3. 3+ days no session → reEngagement
//   4. 7+ days consistent tracking, 0 overdue → quietAffirmation
//   5. Pipeline up to date + S2S safe → reliefSignal
//
// Zero Flutter imports — fully unit-testable.

import 'package:flutter/foundation.dart';
import 'package:helm/core/nudge/domain/nudge_decision.dart';
import 'package:helm/core/nudge/domain/nudge_types.dart';

/// Input context for a single nudge evaluation pass.
@immutable
class NudgeEvaluationContext {
  /// Number of overdue pipeline entries (expected date past today).
  final int overdueCount;

  /// Total pipeline entries.
  final int totalEntries;

  /// Current safe-to-spend assessment.
  final S2sState s2sState;

  /// Days since the user's last app session.
  final int daysSinceLastSession;

  /// Consecutive days with tracked data (at least one entry recorded).
  final int trackingStreak;

  /// ID of the oldest overdue entry, if any.
  final String? oldestOverdueEntryId;

  const NudgeEvaluationContext({
    this.overdueCount = 0,
    this.totalEntries = 0,
    this.s2sState = S2sState.noData,
    this.daysSinceLastSession = 0,
    this.trackingStreak = 0,
    this.oldestOverdueEntryId,
  });
}

/// Simplified S2S health state for evaluation purposes.
enum S2sState { safe, atRisk, noData }

/// Evaluates nudge conditions against the current pipeline and S2S state.
///
/// Rule set:
/// 1. Overdue pipeline entries → confirm oldest overdue entry (push)
/// 2. S2S at risk + 0 overdue → review fixed costs (in-app only — never push for at-risk)
/// 3. 3+ days no session → re-engagement (push, low priority)
/// 4. 7+ days consistent tracking + 0 overdue → quiet affirmation (quiet — no notification center)
/// 5. Pipeline up to date + S2S safe → relief signal (quiet — no notification center)
/// 6. No conditions met → returns null
class NudgeEvaluator {
  const NudgeEvaluator();

  /// Evaluate all rules against [context] and return the best match, or null.
  NudgeDecision? evaluate(NudgeEvaluationContext context) {
    if (context.overdueCount > 0) {
      return _confirmOverdue(context);
    }

    if (context.s2sState == S2sState.atRisk && context.overdueCount == 0) {
      return _reviewFixedCosts(context);
    }

    if (context.daysSinceLastSession > 3) {
      return _reEngagement(context);
    }

    if (context.trackingStreak >= 7 && context.overdueCount == 0) {
      return _quietAffirmation(context);
    }

    if (context.totalEntries > 0 &&
        context.overdueCount == 0 &&
        context.s2sState == S2sState.safe) {
      return _reliefSignal(context);
    }

    return null;
  }

  NudgeDecision _confirmOverdue(NudgeEvaluationContext context) {
    final hasMultiple = context.overdueCount > 1;
    return NudgeDecision(
      nudgeId: 'nudge-confirm-overdue-${DateTime.now().millisecondsSinceEpoch}',
      nudgeType: NudgeType.confirmOverdue,
      priority: NudgePriority.high,
      channel: NudgeChannel.push,
      title: hasMultiple
          ? '${context.overdueCount} payments past their expected date'
          : 'A payment from a client was expected',
      body: hasMultiple
          ? '${context.overdueCount} payments are past their expected date. Tap to review.'
          : 'A payment was expected. Confirm or update?',
      actionLabel: 'Review',
      actionRoute: '/pipeline',
      targetEntryId: context.oldestOverdueEntryId,
    );
  }

  NudgeDecision _reviewFixedCosts(NudgeEvaluationContext context) {
    return NudgeDecision(
      nudgeId: 'nudge-review-costs-${DateTime.now().millisecondsSinceEpoch}',
      nudgeType: NudgeType.reviewFixedCosts,
      priority: NudgePriority.high,
      channel: NudgeChannel.inAppOnly,
      title: 'Your safe-to-spend is tighter than usual',
      body: 'Review fixed costs?',
      actionLabel: 'Review',
      actionRoute: '/sts-settings',
    );
  }

  NudgeDecision _reEngagement(NudgeEvaluationContext context) {
    return NudgeDecision(
      nudgeId: 'nudge-reengage-${DateTime.now().millisecondsSinceEpoch}',
      nudgeType: NudgeType.reEngagement,
      priority: NudgePriority.low,
      channel: NudgeChannel.push,
      title: 'Haven\'t seen you in a few days',
      body: context.totalEntries > 0
          ? 'Your pipeline has ${context.totalEntries} updates.'
          : 'Tap to check your pipeline.',
      actionLabel: 'Open',
      actionRoute: '/home',
    );
  }

  NudgeDecision _quietAffirmation(NudgeEvaluationContext context) {
    return NudgeDecision(
      nudgeId: 'nudge-affirmation-${DateTime.now().millisecondsSinceEpoch}',
      nudgeType: NudgeType.quietAffirmation,
      priority: NudgePriority.low,
      channel: NudgeChannel.quiet,
      title: 'Pipeline up to date',
      body: '${context.trackingStreak} days tracked.',
      actionLabel: null,
      actionRoute: null,
    );
  }

  NudgeDecision _reliefSignal(NudgeEvaluationContext context) {
    return NudgeDecision(
      nudgeId: 'nudge-relief-${DateTime.now().millisecondsSinceEpoch}',
      nudgeType: NudgeType.reliefSignal,
      priority: NudgePriority.low,
      channel: NudgeChannel.quiet,
      title: 'Everything looks good',
      body: 'Safe-to-spend is comfortable. ${context.totalEntries} pipeline entries confirmed.',
      actionLabel: null,
      actionRoute: null,
    );
  }
}
