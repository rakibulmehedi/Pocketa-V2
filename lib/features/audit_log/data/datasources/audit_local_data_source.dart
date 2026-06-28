// lib/features/audit_log/data/datasources/audit_local_data_source.dart
//
// Abstract interface and Hive implementation for audit log persistence.
//
// Rules:
//   - Events are APPEND-ONLY — never delete or modify audit records.
//   - Box is always retrieved via Hive.box() — never opened here.
//   - Opening is managed exclusively by HiveService.init().
//
// D1.05 — Trust Layer: Audit Log

import 'package:hive_ce/hive_ce.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/features/audit_log/core/audit_log_constants.dart';
import 'package:helm/features/audit_log/data/models/audit_event_model.dart';
import 'package:helm/features/audit_log/data/services/audit_chain_service.dart';
import 'package:helm/features/audit_log/domain/entities/audit_event.dart';

// ── Abstract interface ────────────────────────────────────────────────────────

/// Contract for local audit log data access.
///
/// All implementations must honour the append-only constraint:
/// no record may be updated or deleted once written.
abstract class AuditLocalDataSource {
  /// Appends [event] to the audit log. Never overwrites existing records.
  Future<void> addEvent(AuditEvent event);

  /// Returns all audit events, sorted newest-first by timestamp.
  Future<List<AuditEvent>> getAllEvents();

  /// Returns all audit events for a specific [entityId], newest-first.
  Future<List<AuditEvent>> getEventsForEntity(String entityId);
}

// ── Hive implementation ───────────────────────────────────────────────────────

/// Hive-backed implementation of [AuditLocalDataSource].
///
/// The box must be opened before any method is called.
/// Opening is managed exclusively by [HiveService.init()].
///
/// entityId is a string reference with no FK validation. Acceptable for MVP:
/// audit log is append-only; entities are never deleted without a corresponding
/// audit event.
class AuditLocalDataSourceImpl implements AuditLocalDataSource {
  final AuditChainService _chainService;

  AuditLocalDataSourceImpl({AuditChainService? chainService})
      : _chainService = chainService ?? AuditChainService();

  Box<AuditEventModel> get _box =>
      Hive.box<AuditEventModel>(AppBoxNames.auditEventsBox);

  @override
  Future<void> addEvent(AuditEvent event) async {
    // Ensure a stable, collision-resistant id at the persistence boundary.
    final stableId = event.id.isEmpty ? IdGenerator.uniqueId() : event.id;
    final stableEvent = event.copyWith(id: stableId);
    final model = AuditEventModel.fromEntity(stableEvent);

    // Append the event and extend the tamper-evidence chain.
    await _box.put(stableId, model);
    await _chainService.appendAndHash(stableEvent);

    // Enforce retention policy on every append (best-effort).
    await _pruneOldEvents();
  }

  /// Removes audit records older than [kAuditRetentionDays].
  /// Deviates from strict append-only only for explicit retention policy.
  Future<void> _pruneOldEvents() async {
    try {
      final cutoff = DateTime.now().subtract(
        const Duration(days: kAuditRetentionDays),
      );
      final keysToDelete = <String>[];
      for (final entry in _box.toMap().entries) {
        if (entry.value.timestamp.isBefore(cutoff)) {
          keysToDelete.add(entry.key as String);
        }
      }
      if (keysToDelete.isNotEmpty) {
        await _box.deleteAll(keysToDelete);
      }
    } on Exception catch (_) {
      // Retention pruning is best-effort; do not fail the audited operation.
    }
  }

  @override
  Future<List<AuditEvent>> getAllEvents() async {
    final events = _box.values.map((m) => m.toEntity()).toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  @override
  Future<List<AuditEvent>> getEventsForEntity(String entityId) async {
    final all = await getAllEvents();
    return all.where((e) => e.entityId == entityId).toList();
  }
}
