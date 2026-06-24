// lib/core/analytics/analytics_service.dart
//
// Instrumentation for Helm with local memory/Hive event persistence.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/analytics/domain/analytics_event_entity.dart';
import 'package:helm/core/analytics/domain/analytics_repository.dart';
import 'package:helm/core/analytics/domain/nudge_preferences_entity.dart';
import 'package:helm/core/analytics/data/models/nudge_preferences_model.dart';
import 'package:helm/core/analytics/data/datasources/analytics_local_data_source.dart';
import 'package:helm/core/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';

/// Abstract contract for analytics instrumentation.
abstract class AnalyticsService {
  /// Record a named event with optional structured properties.
  void trackEvent(String name, {Map<String, dynamic>? properties});

  /// Record a screen-view transition.
  void trackScreen(String name);
}

/// Persistent implementation that writes events to console AND Hive persistence.
class LocalAnalyticsService implements AnalyticsService {
  final AnalyticsRepository _repository;

  // L-7: static lock flag to prevent concurrent double-writes to dailyActiveSession.
  static bool _trackingSession = false;

  const LocalAnalyticsService({
    required AnalyticsRepository repository,
  }) : _repository = repository;

  @override
  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    // Session deduplication: daily_active_session fires only once per calendar day.
    if (name == BoundaryEvents.dailyActiveSession) {
      if (_trackingSession) return;
      _trackingSession = true;
      try {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final lastDate = SharedPrefServices.getLastSessionDate();
        if (lastDate == todayStr) {
          return; // Deduplicate
        }
        SharedPrefServices.setLastSessionDate(todayStr);
      } finally {
        _trackingSession = false;
      }
    }

    final propsMap = properties?.map((k, v) => MapEntry(k, v.toString())) ??
        <String, String>{};

    if (kDebugMode) {
      final propsStr =
          propsMap.isNotEmpty ? ' | $propsMap' : '';
      debugPrint('[BETA_EVENT] $name$propsStr');
    }

    // L-8: trackEvent is void (synchronous interface); repository.save is
    // fire-and-forget. Analytics loss on failure is acceptable for MVP.
    // ignore: unawaited_futures
    _repository.save(AnalyticsEventEntity(
      eventName: name,
      timestamp: DateTime.now().toUtc(),
      properties: propsMap,
    ));
  }

  @override
  void trackScreen(String name) {
    if (kDebugMode) {
      debugPrint('[BETA_EVENT] screen_view | {screen: $name}');
    }

    // L-8: fire-and-forget — same rationale as trackEvent above.
    // ignore: unawaited_futures
    _repository.save(AnalyticsEventEntity(
      eventName: 'screen_view',
      timestamp: DateTime.now().toUtc(),
      properties: {'screen': name},
    ));
  }
}

/// Riverpod provider exposing [AnalyticsLocalDataSource].
final analyticsLocalDataSourceProvider = Provider<AnalyticsLocalDataSource>(
  (ref) => AnalyticsLocalDataSourceImpl(),
);

/// Riverpod provider exposing [AnalyticsRepository].
final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(
    localDataSource: ref.read(analyticsLocalDataSourceProvider),
  ),
);

/// Riverpod provider exposing [AnalyticsService].
final analyticsProvider = Provider<AnalyticsService>(
  (ref) => LocalAnalyticsService(
    repository: ref.read(analyticsRepositoryProvider),
  ),
);

/// Riverpod StateNotifier for managing nudge delivery preferences.
class NudgePreferencesNotifier extends StateNotifier<NudgePreferencesEntity> {
  NudgePreferencesNotifier() : super(NudgePreferencesEntity.defaults()) {
    _loadPreferences();
  }

  Box<NudgePreferencesModel> get _box =>
      Hive.box<NudgePreferencesModel>(AppBoxNames.nudgePreferencesBox);

  void _loadPreferences() {
    if (_box.isNotEmpty) {
      final model = _box.values.first;
      state = model.toEntity();
    }
  }

  Future<void> updatePreferences(NudgePreferencesEntity newPrefs) async {
    final model = NudgePreferencesModel.fromEntity(newPrefs);
    await _box.clear();
    await _box.add(model);
    state = newPrefs;
  }
}

/// Riverpod provider exposing [NudgePreferencesNotifier] and its state.
final nudgePreferencesProvider =
    StateNotifierProvider<NudgePreferencesNotifier, NudgePreferencesEntity>(
  (ref) => NudgePreferencesNotifier(),
);
