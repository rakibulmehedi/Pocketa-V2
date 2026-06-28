// lib/core/local_storage/hive_service.dart
//
// Centralised Hive bootstrap for Helm with at-rest encryption.
//
// How to add a new model in Phase 1+:
//   1. Annotate the model with @HiveType(typeId: N)
//   2. Run: flutter pub run build_runner build --delete-conflicting-outputs
//   3. Register the generated adapter below in _registerAdapters()
//   4. Open its box in _openBoxes() using AppBoxNames.<boxName>
//
// NEVER open a box or register an adapter outside of this file.

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/security/secure_key_manager.dart';
import 'package:helm/features/transactions/data/models/transaction_model.dart';
import 'package:helm/features/transactions/data/adapters/transaction_type_adapter.dart';
import 'package:helm/features/income/data/models/income_model.dart';
import 'package:helm/features/safe_to_spend/data/models/fixed_cost_model.dart';
import 'package:helm/features/audit_log/data/models/audit_event_model.dart';
import 'package:helm/core/analytics/models/analytics_event_model.dart';
import 'package:helm/core/analytics/data/models/nudge_preferences_model.dart';
import 'package:helm/core/nudge/data/models/nudge_log_entry_model.dart';
import 'package:helm/features/auth/data/models/session_model.dart';
import 'package:helm/hive_registrar.g.dart';

/// Exception thrown when Hive initialization encounters an unrecoverable error.
class HiveServiceException implements Exception {
  const HiveServiceException(this.message);
  final String message;

  @override
  String toString() => 'HiveServiceException: $message';
}

class HiveService {
  HiveService._(); // prevent instantiation

  static HiveCipher? _cipher;

  static const _backupExclusionChannel = MethodChannel(
    'com.safetospends.helm/backup',
  );

  /// Initialises Hive and registers all adapters + opens all boxes.
  /// Must be called in main() before runApp().
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory(path.join(dir.path, 'hive'));

    await _migrateHiveBoxesIfNeeded(dir, hiveDir);
    await hiveDir.create(recursive: true);
    await _excludeFromBackup(hiveDir.path);

    await Hive.initFlutter(hiveDir.path);

    _cipher = await _createCipher();

    _registerAdapters();
    await _openBoxes();
  }

  /// Moves Hive box files from the legacy Documents root into a dedicated
  /// `hive/` subdirectory so the entire directory can be excluded from cloud
  /// backup without affecting other files.
  static Future<void> _migrateHiveBoxesIfNeeded(
    Directory oldDir,
    Directory newDir,
  ) async {
    if (!oldDir.existsSync()) return;
    await newDir.create(recursive: true);

    final boxNames = [
      AppBoxNames.transactions,
      AppBoxNames.categories,
      AppBoxNames.incomeBox,
      AppBoxNames.fixedCostsBox,
      AppBoxNames.authBox,
      AppBoxNames.auditEventsBox,
      AppBoxNames.analyticsEventsBox,
      AppBoxNames.nudgePreferencesBox,
      AppBoxNames.nudgeLogBox,
      AppBoxNames.sessionBox,
    ];

    for (final name in boxNames) {
      for (final ext in ['.hive', '.hive.lock']) {
        final oldFile = File(path.join(oldDir.path, '$name$ext'));
        final newFile = File(path.join(newDir.path, '$name$ext'));
        if (oldFile.existsSync() && !newFile.existsSync()) {
          try {
            await oldFile.rename(newFile.path);
          } on Exception catch (e, st) {
            developer.log(
              'Failed to migrate Hive box file ${oldFile.path}: $e',
              name: 'HiveService',
              error: e,
              stackTrace: st,
            );
          }
        }
      }
    }
  }

  /// Asks the native side to exclude [path] from iCloud / Google backups.
  static Future<void> _excludeFromBackup(String filePath) async {
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        await _backupExclusionChannel.invokeMethod('excludeFromBackup', {
          'path': filePath,
        });
      } on Exception catch (e, st) {
        developer.log(
          'Failed to exclude $filePath from backups: $e',
          name: 'HiveService',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Future<HiveCipher> _createCipher() async {
    final key = await SecureKeyManager().getOrCreateHiveKey();
    return HiveAesCipher(key);
  }

  /// Register all Hive TypeAdapters here.
  static void _registerAdapters() {
    // Generated adapters (hive_ce_generator).
    Hive.registerAdapters();

    // Custom enum adapter (manually written).
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
  }

  /// Open all Hive boxes here with encryption enabled.
  /// Per-box failures are caught and logged so a single corrupt box does not
  /// prevent the app from starting.
  static Future<void> _openBoxes() async {
    final cipher = _cipher;
    if (cipher == null) {
      throw const HiveServiceException('Encryption cipher not initialised');
    }

    final boxes = <Future<void>>[
      _openBoxSafe<TransactionModel>(AppBoxNames.transactions, cipher),
      _openBoxSafe<IncomeModel>(AppBoxNames.incomeBox, cipher),
      _openBoxSafe<FixedCostModel>(AppBoxNames.fixedCostsBox, cipher),
      _openBoxSafe<dynamic>(AppBoxNames.authBox, cipher),
      _openBoxSafe<AuditEventModel>(AppBoxNames.auditEventsBox, cipher),
      _openBoxSafe<String>(AppBoxNames.auditChainBox, cipher),
      _openBoxSafe<AnalyticsEventModel>(AppBoxNames.analyticsEventsBox, cipher),
      _openBoxSafe<NudgePreferencesModel>(
        AppBoxNames.nudgePreferencesBox,
        cipher,
      ),
      _openBoxSafe<NudgeLogEntryModel>(AppBoxNames.nudgeLogBox, cipher),
      _openBoxSafe<SessionModel>(AppBoxNames.sessionBox, cipher),
    ];

    await Future.wait(boxes);
  }

  static Future<void> _openBoxSafe<T>(String name, HiveCipher cipher) async {
    try {
      await Hive.openBox<T>(name, encryptionCipher: cipher);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to open Hive box $name: $e',
        name: 'HiveService',
        error: e,
        stackTrace: stackTrace,
      );
      // TODO(rakibul): log audit event once audit log is available at init time.
    }
  }

  /// Generic helper — only use for boxes not managed by [_openBoxes].
  /// Prefer [_openBoxes] for all known boxes.
  static Future<void> openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      final cipher = _cipher;
      await Hive.openBox<T>(
        boxName,
        encryptionCipher: cipher,
      );
    }
  }
}
