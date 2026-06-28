// lib/features/safe_to_spend/data/datasources/sts_settings_data_source.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/features/audit_log/data/datasources/audit_local_data_source.dart';
import 'package:helm/features/audit_log/domain/entities/audit_event.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';

abstract class StsSettingsDataSource {
  Future<StsSettings?> loadSettings();
  Future<void> saveSettings(StsSettings settings);

  /// Backwards-compatible accessors for callers that read one value at a time.
  Future<double?> getTaxRate();
  Future<void> saveTaxRate(double rate);
  Future<double?> getBufferPercent();
  Future<void> saveBufferPercent(double percent);
}

class StsSettingsDataSourceImpl implements StsSettingsDataSource {
  /// Single atomic key for the entire settings object.
  static const _settingsKey = 'stsSettings_v2';

  /// Legacy keys kept for migration only.
  static const _taxRateKey = 'stsSettings_taxRate';
  static const _bufferPercentKey = 'stsSettings_bufferPercent';
  static const _legacyBufferKey = 'stsSettings_anxietyBuffer';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<StsSettings?> loadSettings() async {
    final prefs = await _prefs;

    // Prefer the atomic v2 blob.
    final jsonStr = prefs.getString(_settingsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return StsSettings(
          taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.10,
          bufferPercent: (map['bufferPercent'] as num?)?.toDouble() ?? 15.0,
        );
      } on Exception {
        // Fall through to legacy migration.
      }
    }

    // Migrate from legacy separate keys.
    final taxRate = prefs.getDouble(_taxRateKey);
    final bufferPercent = await _migrateBufferPercent(prefs);
    if (taxRate == null && bufferPercent == null) return null;

    final migrated = StsSettings(
      taxRate: taxRate ?? 0.10,
      bufferPercent: bufferPercent ?? 15.0,
    );
    await saveSettings(migrated);
    return migrated;
  }

  @override
  Future<void> saveSettings(StsSettings settings) async {
    final prefs = await _prefs;
    final jsonStr = jsonEncode({
      'taxRate': settings.taxRate,
      'bufferPercent': settings.bufferPercent,
    });
    await prefs.setString(_settingsKey, jsonStr);
  }

  @override
  Future<double?> getTaxRate() async {
    final settings = await loadSettings();
    return settings?.taxRate;
  }

  @override
  Future<void> saveTaxRate(double rate) async {
    final current = await loadSettings() ??
        StsSettings(taxRate: 0.10, bufferPercent: 15.0);
    final previous = jsonEncode({
      'taxRate': current.taxRate,
      'bufferPercent': current.bufferPercent,
    });
    await saveSettings(current.copyWith(taxRate: rate));
    await _audit(
      entityId: 'sts_tax_rate',
      previousValue: previous,
      newValue: jsonEncode({
        'taxRate': rate,
        'bufferPercent': current.bufferPercent,
      }),
      description: 'STS tax rate updated: $rate',
    );
  }

  @override
  Future<double?> getBufferPercent() async {
    final settings = await loadSettings();
    return settings?.bufferPercent;
  }

  @override
  Future<void> saveBufferPercent(double percent) async {
    final current = await loadSettings() ??
        StsSettings(taxRate: 0.10, bufferPercent: 15.0);
    final previous = jsonEncode({
      'taxRate': current.taxRate,
      'bufferPercent': current.bufferPercent,
    });
    await saveSettings(current.copyWith(bufferPercent: percent));
    await _audit(
      entityId: 'sts_buffer_percent',
      previousValue: previous,
      newValue: jsonEncode({
        'taxRate': current.taxRate,
        'bufferPercent': percent,
      }),
      description: 'STS buffer percent updated: $percent%',
    );
  }

  Future<double?> _migrateBufferPercent(SharedPreferences prefs) async {
    final newVal = prefs.getDouble(_bufferPercentKey);
    if (newVal != null) return newVal;

    final oldVal = prefs.getDouble(_legacyBufferKey);
    if (oldVal != null) {
      // H-11: Never silently discard user data.
      // If the stored value is within 0–100, it's already a percentage.
      // If it exceeds 100, it was stored as an absolute BDT amount — convert
      // it to an estimated percentage clamped to the valid range (5–30).
      final double migrated;
      if (oldVal >= 0.0 && oldVal <= 100.0) {
        migrated = oldVal;
      } else {
        // Absolute BDT value: estimate as a percentage of a baseline balance.
        migrated = (oldVal / 50000.0 * 100).clamp(5.0, 30.0);
        if (kDebugMode) {
          debugPrint(
            '[StsSettings] buffer migrated from absolute BDT to %: '
            '${oldVal.toStringAsFixed(0)} BDT → ${migrated.toStringAsFixed(1)}%',
          );
        }
      }
      await prefs.setDouble(_bufferPercentKey, migrated);
      await prefs.setDouble('${_legacyBufferKey}_backup_bdt', oldVal);
      await prefs.remove(_legacyBufferKey);
      return migrated;
    }

    return null;
  }

  Future<void> _audit({
    required String entityId,
    required String previousValue,
    required String newValue,
    required String description,
  }) async {
    try {
      // Skip audit logging when the audit box is not open (e.g., unit tests
      // that only initialize SharedPreferences).
      if (!Hive.isBoxOpen(AppBoxNames.auditEventsBox)) return;
      final auditDs = AuditLocalDataSourceImpl();
      await auditDs.addEvent(AuditEvent(
        id: IdGenerator.uniqueId(),
        timestamp: DateTime.now(),
        eventType: AuditEventType.updated,
        entityType: AuditEntityType.stsSettings,
        entityId: entityId,
        previousValue: previousValue,
        newValue: newValue,
        description: InputValidator.sanitizeText(description),
      ));
    } on Exception {
      // Audit failure is non-fatal — do not propagate
    }
  }
}
