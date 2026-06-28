// test/core/nudge/domain/nudge_evaluator_test.dart
//
// Tests for the NudgeEvaluator rules engine (Phase 3, Group 3B).
// Pure Dart — no Flutter dependencies. 13+ tests covering all rule conditions.

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/nudge/domain/nudge_evaluator.dart';
import 'package:helm/core/nudge/domain/nudge_types.dart';

void main() {
  group('NudgeEvaluator — Rule priority', () {
    final evaluator = const NudgeEvaluator();

    test('overdue entries → confirmOverdue nudge (highest priority)', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 3,
        oldestOverdueEntryId: 'entry-1',
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.confirmOverdue));
      expect(result.priority, equals(NudgePriority.high));
      expect(result.channel, equals(NudgeChannel.push));
      expect(result.targetEntryId, equals('entry-1'));
    });

    test('overdue wins over S2S atRisk when both present', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 1,
        s2sState: S2sState.atRisk,
        daysSinceLastSession: 5,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.confirmOverdue));
      expect(result.priority, equals(NudgePriority.high));
    });

    test('S2S atRisk + 0 overdue → reviewFixedCosts (in-app only)', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        s2sState: S2sState.atRisk,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.reviewFixedCosts));
      expect(result.priority, equals(NudgePriority.high));
      expect(result.channel, equals(NudgeChannel.inAppOnly));
      expect(result.actionRoute, equals('/sts-settings'));
    });

    test('3+ days no session + 0 overdue + not atRisk → reEngagement', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        s2sState: S2sState.safe,
        daysSinceLastSession: 4,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.reEngagement));
      expect(result.priority, equals(NudgePriority.low));
      expect(result.channel, equals(NudgeChannel.push));
    });

    test('3+ days + S2S atRisk → still atRisk wins (rule 2 beats rule 3)', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        s2sState: S2sState.atRisk,
        daysSinceLastSession: 5,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.reviewFixedCosts));
    });

    test('7+ days tracking + 0 overdue → quietAffirmation (quiet channel)', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        trackingStreak: 7,
        s2sState: S2sState.safe,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.quietAffirmation));
      expect(result.channel, equals(NudgeChannel.quiet));
      expect(result.actionLabel, isNull);
    });

    test('14+ days tracking + 0 overdue → still quietAffirmation', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        trackingStreak: 14,
        s2sState: S2sState.safe,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.quietAffirmation));
      expect(result.channel, equals(NudgeChannel.quiet));
    });

    test(
        'pipeline up to date + S2S safe + 0 trackingStreak → reliefSignal',
        () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        totalEntries: 5,
        s2sState: S2sState.safe,
        trackingStreak: 0,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.reliefSignal));
      expect(result.channel, equals(NudgeChannel.quiet));
    });

    test('reliefSignal requires totalEntries > 0', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        totalEntries: 0,
        s2sState: S2sState.safe,
      ));

      expect(result, isNull);
    });

    test('no conditions met → null', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        totalEntries: 0,
        daysSinceLastSession: 0,
        trackingStreak: 0,
      ));

      expect(result, isNull);
    });

    test('1 overdue → single-entry copy', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 1,
        oldestOverdueEntryId: 'entry-1',
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.confirmOverdue));
      expect(result.title, contains('a client was expected'));
      expect(result.body, contains('Confirm or update'));
    });

    test('2+ overdue → multi-entry copy', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 2,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.confirmOverdue));
      expect(result.title, contains('past their expected date'));
      expect(result.body, contains('past their expected date'));
    });

    test('reEngagement shows entry count when totalEntries > 0', () {
      final result = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        totalEntries: 3,
        daysSinceLastSession: 5,
        s2sState: S2sState.safe,
      ));

      expect(result, isNotNull);
      expect(result!.nudgeType, equals(NudgeType.reEngagement));
      expect(result.body, contains('3 updates'));
    });

    test('NudgeDecision isPushable and isDisplayable correct', () {
      final pushable = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 1,
      ));
      expect(pushable!.isPushable, isTrue);
      expect(pushable.isDisplayable, isTrue);

      final inApp = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        s2sState: S2sState.atRisk,
      ));
      expect(inApp!.isPushable, isFalse);
      expect(inApp.isDisplayable, isTrue);

      final quiet = evaluator.evaluate(const NudgeEvaluationContext(
        overdueCount: 0,
        trackingStreak: 7,
        s2sState: S2sState.safe,
      ));
      expect(quiet!.isPushable, isFalse);
      expect(quiet.isDisplayable, isFalse);
    });
  });
}
