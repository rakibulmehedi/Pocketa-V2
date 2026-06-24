// lib/core/analytics/domain/nudge_preferences_entity.dart
//
// Pure domain representation of nudge/notification delivery preferences.

import 'package:flutter/material.dart';

enum Cadence {
  daily,
  weekly,
  silent,
}

@immutable
class NudgePreferencesEntity {
  final Cadence cadence;
  final TimeOfDay checkInTime;
  final bool pushEnabled;
  final bool inAppEnabled;
  final bool quietAffirmationsEnabled;

  const NudgePreferencesEntity({
    required this.cadence,
    required this.checkInTime,
    required this.pushEnabled,
    required this.inAppEnabled,
    required this.quietAffirmationsEnabled,
  });

  factory NudgePreferencesEntity.defaults() {
    // L-11: default to weekly so users opt-in to daily notifications.
    return const NudgePreferencesEntity(
      cadence: Cadence.weekly,
      checkInTime: TimeOfDay(hour: 9, minute: 0),
      pushEnabled: true,
      inAppEnabled: true,
      quietAffirmationsEnabled: true,
    );
  }

  NudgePreferencesEntity copyWith({
    Cadence? cadence,
    TimeOfDay? checkInTime,
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? quietAffirmationsEnabled,
  }) {
    return NudgePreferencesEntity(
      cadence: cadence ?? this.cadence,
      checkInTime: checkInTime ?? this.checkInTime,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      quietAffirmationsEnabled: quietAffirmationsEnabled ?? this.quietAffirmationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NudgePreferencesEntity &&
          runtimeType == other.runtimeType &&
          cadence == other.cadence &&
          checkInTime == other.checkInTime &&
          pushEnabled == other.pushEnabled &&
          inAppEnabled == other.inAppEnabled &&
          quietAffirmationsEnabled == other.quietAffirmationsEnabled;

  @override
  int get hashCode =>
      cadence.hashCode ^
      checkInTime.hashCode ^
      pushEnabled.hashCode ^
      inAppEnabled.hashCode ^
      quietAffirmationsEnabled.hashCode;
}
