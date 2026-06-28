// test/core/analytics/analytics_session_test.dart
//
// Security/correctness regression test for L-7:
// trackDailySession (BoundaryEvents.dailyActiveSession) must be idempotent —
// firing the event multiple times on the same calendar day must result in
// exactly one repository write, not multiple.
//
// Without the static _trackingSession lock in LocalAnalyticsService, two
// concurrent calls could both pass the "lastDate != todayStr" check before
// either writes the new date, resulting in duplicate DAU records.

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/domain/analytics_event_entity.dart';
import 'package:helm/core/analytics/domain/analytics_repository.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Fake repository ─────────────────────────────────────────────────────────

class _FakeAnalyticsRepository implements AnalyticsRepository {
  final List<AnalyticsEventEntity> savedEvents = [];

  @override
  Future<void> save(AnalyticsEventEntity event) async {
    savedEvents.add(event);
  }

  @override
  Future<List<AnalyticsEventEntity>> getEventsSince(DateTime since) async {
    return savedEvents.where((e) => e.timestamp.isAfter(since)).toList();
  }

  @override
  Future<int> getEventCount(String eventName) async {
    return savedEvents.where((e) => e.eventName == eventName).length;
  }

  @override
  Future<AnalyticsEventEntity?> getLastEventOf(String eventName) async {
    final matching =
        savedEvents.where((e) => e.eventName == eventName).toList();
    if (matching.isEmpty) return null;
    matching.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matching.first;
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeAnalyticsRepository fakeRepo;
  late LocalAnalyticsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
    fakeRepo = _FakeAnalyticsRepository();
    service = LocalAnalyticsService(repository: fakeRepo);
  });

  group('L-7: trackDailySession idempotency', () {
    test(
      'first daily_active_session call on a fresh day writes exactly one event',
      () {
        service.trackEvent(BoundaryEvents.dailyActiveSession);

        final sessionEvents = fakeRepo.savedEvents
            .where((e) => e.eventName == BoundaryEvents.dailyActiveSession)
            .toList();
        expect(sessionEvents.length, equals(1));
      },
    );

    test(
      'calling daily_active_session twice on the same day writes only one event',
      () {
        service.trackEvent(BoundaryEvents.dailyActiveSession);
        service.trackEvent(BoundaryEvents.dailyActiveSession);

        final sessionEvents = fakeRepo.savedEvents
            .where((e) => e.eventName == BoundaryEvents.dailyActiveSession)
            .toList();
        expect(sessionEvents.length, equals(1),
            reason:
                'Duplicate daily_active_session calls on the same calendar day '
                'must be deduplicated (L-7 idempotency requirement).');
      },
    );

    test(
      'calling daily_active_session 10 times on the same day writes only one event',
      () {
        for (var i = 0; i < 10; i++) {
          service.trackEvent(BoundaryEvents.dailyActiveSession);
        }

        final sessionEvents = fakeRepo.savedEvents
            .where((e) => e.eventName == BoundaryEvents.dailyActiveSession)
            .toList();
        expect(sessionEvents.length, equals(1),
            reason:
                'No matter how many times the session event is triggered in '
                'a single day, exactly one write must reach the repository.');
      },
    );

    test(
      'session fires again on a new calendar day after prior dedup',
      () async {
        // Record first session for today.
        service.trackEvent(BoundaryEvents.dailyActiveSession);
        expect(fakeRepo.savedEvents.length, equals(1));

        // Advance the stored date to yesterday, simulating a new day.
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .substring(0, 10);
        await SharedPrefServices.setLastSessionDate(yesterday);

        // Fire again on the new day.
        service.trackEvent(BoundaryEvents.dailyActiveSession);

        final sessionEvents = fakeRepo.savedEvents
            .where((e) => e.eventName == BoundaryEvents.dailyActiveSession)
            .toList();
        expect(sessionEvents.length, equals(2),
            reason:
                'The session event must fire once per unique calendar day.');
      },
    );

    test(
      'non-session events are NOT deduplicated',
      () {
        service.trackEvent('custom_event');
        service.trackEvent('custom_event');
        service.trackEvent('custom_event');

        final customEvents =
            fakeRepo.savedEvents.where((e) => e.eventName == 'custom_event').toList();
        expect(customEvents.length, equals(3),
            reason:
                'The deduplication logic applies only to daily_active_session '
                '— all other events must pass through without filtering.');
      },
    );

    test(
      'last_session_date is written to SharedPreferences after first session',
      () {
        service.trackEvent(BoundaryEvents.dailyActiveSession);

        final todayStr =
            DateTime.now().toIso8601String().substring(0, 10);
        expect(SharedPrefServices.getLastSessionDate(), equals(todayStr));
      },
    );

    test(
      'last_session_date is NOT overwritten on duplicate same-day calls',
      () async {
        service.trackEvent(BoundaryEvents.dailyActiveSession);
        final firstDate = SharedPrefServices.getLastSessionDate();

        // Call again on the same day.
        service.trackEvent(BoundaryEvents.dailyActiveSession);
        final secondDate = SharedPrefServices.getLastSessionDate();

        expect(secondDate, equals(firstDate),
            reason:
                'The session date must not be reset by duplicate calls on '
                'the same day.');
      },
    );
  });
}
