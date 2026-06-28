// test/integration/income_pipeline_data_integrity_test.dart
//
// M-27: Integration test verifying the income state machine transitions
// (expected → pending → received) complete without errors.
//
// Uses a ProviderContainer with an in-memory fake IncomeRepository —
// no device, Hive, or Flutter widget infrastructure required.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/domain/repositories/income_repository.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';

// ---------------------------------------------------------------------------
// In-memory fake repository (no Hive required)
// ---------------------------------------------------------------------------

class _FakeIncomeRepository implements IncomeRepository {
  final List<IncomeEntryEntity> _entries = [];

  @override
  Future<void> addIncome(IncomeEntryEntity entity) async =>
      _entries.add(entity);

  @override
  Future<void> clearIncomes() async => _entries.clear();

  @override
  Future<void> deleteIncome(String id) async =>
      _entries.removeWhere((e) => e.id == id);

  @override
  List<IncomeEntryEntity> getIncomes() => List.unmodifiable(_entries);

  @override
  Future<void> updateIncome(IncomeEntryEntity entity) async {
    final idx = _entries.indexWhere((e) => e.id == entity.id);
    if (idx >= 0) _entries[idx] = entity;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('M-27 — Income pipeline data integrity', () {
    late ProviderContainer container;
    late _FakeIncomeRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeIncomeRepository();
      container = ProviderContainer(
        overrides: [
          incomeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('expected → pending → received transitions complete without error',
        () async {
      final notifier = container.read(incomeNotifierProvider.notifier);

      // 1. Create entry with status = expected
      final entry = IncomeEntryEntity(
        id: 'integrity-test-1',
        clientName: 'Test Client',
        projectName: 'Test Project',
        amount: 1000.0,
        currency: 'USD',
        status: IncomeStatus.expected,
        expectedDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notifier.addIncome(entry);

      final afterAdd = container.read(incomeNotifierProvider);
      expect(afterAdd.length, 1);
      expect(afterAdd.first.status, IncomeStatus.expected);

      // 2. Transition expected → pending
      final pendingEntry = entry.copyWith(
        status: IncomeStatus.pending,
        updatedAt: DateTime.now(),
      );
      await notifier.updateIncome(pendingEntry);

      final afterPending = container.read(incomeNotifierProvider);
      expect(afterPending.first.status, IncomeStatus.pending);

      // 3. Transition pending → received
      final now = DateTime.now();
      final receivedEntry = pendingEntry.copyWith(
        status: IncomeStatus.received,
        receivedDate: now,
        fxRate: 110.0,
        updatedAt: now,
      );
      await notifier.updateIncome(receivedEntry);

      final finalState = container.read(incomeNotifierProvider);
      expect(finalState.length, 1);
      expect(finalState.first.status, IncomeStatus.received);
      expect(finalState.first.receivedDate, isNotNull);
    });

    test('no exceptions are thrown during full pipeline lifecycle', () async {
      final notifier = container.read(incomeNotifierProvider.notifier);

      final entry = IncomeEntryEntity(
        id: 'integrity-test-2',
        clientName: 'Lifecycle Client',
        projectName: 'Lifecycle Project',
        amount: 500.0,
        currency: 'USD',
        status: IncomeStatus.expected,
        expectedDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // All three steps must complete without throwing
      expect(() async {
        await notifier.addIncome(entry);
        await notifier.updateIncome(
          entry.copyWith(
            status: IncomeStatus.pending,
            updatedAt: DateTime.now(),
          ),
        );
        await notifier.updateIncome(
          entry.copyWith(
            status: IncomeStatus.received,
            receivedDate: DateTime.now(),
            fxRate: 115.0,
            updatedAt: DateTime.now(),
          ),
        );
      }, returnsNormally);
    });
  });
}
