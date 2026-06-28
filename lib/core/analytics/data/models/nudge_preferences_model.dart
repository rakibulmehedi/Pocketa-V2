// lib/core/analytics/data/models/nudge_preferences_model.dart
//
// Hive model representing serialized nudge delivery preferences.

import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:helm/core/analytics/domain/nudge_preferences_entity.dart';

part 'nudge_preferences_model.g.dart';

@HiveType(typeId: 7)
class NudgePreferencesModel extends HiveObject {
  @HiveField(0)
  final String cadenceName;

  @HiveField(1)
  final int checkInHour;

  @HiveField(2)
  final int checkInMinute;

  @HiveField(3)
  final bool pushEnabled;

  @HiveField(4)
  final bool inAppEnabled;

  @HiveField(5)
  final bool quietAffirmationsEnabled;

  NudgePreferencesModel({
    required this.cadenceName,
    required this.checkInHour,
    required this.checkInMinute,
    required this.pushEnabled,
    required this.inAppEnabled,
    required this.quietAffirmationsEnabled,
  });

  NudgePreferencesEntity toEntity() => NudgePreferencesEntity(
        cadence: Cadence.values.firstWhere(
          (e) => e.name == cadenceName,
          // L-11: fall back to weekly (opt-in default) when stored value is unrecognised.
          orElse: () => Cadence.weekly,
        ),
        checkInTime: TimeOfDay(hour: checkInHour, minute: checkInMinute),
        pushEnabled: pushEnabled,
        inAppEnabled: inAppEnabled,
        quietAffirmationsEnabled: quietAffirmationsEnabled,
      );

  factory NudgePreferencesModel.fromEntity(NudgePreferencesEntity entity) =>
      NudgePreferencesModel(
        cadenceName: entity.cadence.name,
        checkInHour: entity.checkInTime.hour,
        checkInMinute: entity.checkInTime.minute,
        pushEnabled: entity.pushEnabled,
        inAppEnabled: entity.inAppEnabled,
        quietAffirmationsEnabled: entity.quietAffirmationsEnabled,
      );
}
