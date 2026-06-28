// lib/features/safe_to_spend/data/repositories/sts_settings_repository_impl.dart

import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/features/audit_log/data/datasources/audit_local_data_source.dart';
import 'package:helm/features/audit_log/domain/entities/audit_event.dart';
import 'package:helm/features/safe_to_spend/data/datasources/sts_settings_data_source.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/safe_to_spend/domain/repositories/sts_settings_repository.dart';

class StsSettingsRepositoryImpl implements StsSettingsRepository {
  final StsSettingsDataSource _dataSource;
  final AuditLocalDataSource? _auditDataSource;

  StsSettingsRepositoryImpl({
    required StsSettingsDataSource dataSource,
    AuditLocalDataSource? auditDataSource,
  })  : _dataSource = dataSource,
        _auditDataSource = auditDataSource;

  AuditLocalDataSource get _audit => _auditDataSource ?? AuditLocalDataSourceImpl();

  @override
  Future<StsSettings> getSettings() async {
    final settings = await _dataSource.loadSettings();
    if (settings != null) return settings;

    // M-29: defaults are only applied when no persisted settings exist.
    // Audit the fallback so a load error cannot silently mask corruption.
    const defaults = StsSettings(taxRate: 0.10, bufferPercent: 15.0);
    try {
      await _audit.addEvent(AuditEvent(
        id: IdGenerator.uniqueId(),
        timestamp: DateTime.now(),
        eventType: AuditEventType.created,
        entityType: AuditEntityType.stsSettings,
        entityId: 'default',
        previousValue: null,
        newValue: defaults.toString(),
        description: InputValidator.sanitizeText(
          'Applied default STS settings because no persisted settings were found',
        ),
      ));
    } on Exception catch (_) {
      // Audit failure is non-fatal — do not corrupt the return value.
    }
    return defaults;
  }

  @override
  Future<void> saveSettings(StsSettings settings) async {
    // H-26: atomic write via single JSON blob — no partial-write risk.
    // StsSettingsDataSourceImpl encodes the full settings object into one
    // SharedPreferences key (_settingsKey) in a single prefs.setString call.
    await _dataSource.saveSettings(settings);
  }
}
