// lib/features/transactions/presentation/providers/transaction_provider.dart
//
// Riverpod providers for the transaction feature.
//
// Phase 7f — Provider now exposes TransactionEntity (domain type).
// TransactionModel is no longer imported in the presentation layer.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  return TransactionLocalDataSourceImpl();
});

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  final localDataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(localDataSource);
});

final transactionsProvider = StateNotifierProvider<
    TransactionsNotifier, AsyncValue<List<TransactionEntity>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionsNotifier(repository);
});

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<TransactionEntity>>> {
  final TransactionRepository _repository;

  TransactionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  /// Test-only seed constructor — sets state directly, no repository load.
  @visibleForTesting
  TransactionsNotifier.test(List<TransactionEntity> seed)
      : _repository = _UnusedRepository(),
        super(AsyncValue.data(seed));

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repository.getTransactions();
      if (!mounted) return;
      // Sort transactions by date descending (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } on Exception catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      await _repository.addTransaction(transaction);
      if (!mounted) return;
      // In-memory append — avoids full Hive re-read on every mutation (L-4).
      final current = state.valueOrNull ?? [];
      final updated = [transaction, ...current]
        ..sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updated);
    } on Exception catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      if (!mounted) return;
      // In-memory replace by id — avoids full Hive re-read on every mutation (L-4).
      final current = state.valueOrNull ?? [];
      final updated = current.map((t) => t.id == transaction.id ? transaction : t).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updated);
    } on Exception catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      if (!mounted) return;
      // In-memory removal by id — avoids full Hive re-read on every mutation (L-4).
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((t) => t.id != id).toList());
    } on Exception catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearTransactions() async {
    try {
      await _repository.clearTransactions();
      if (!mounted) return;
      await loadTransactions();
    } on Exception catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }
}

/// Test-only no-op repository stub. All methods throw [UnimplementedError].
class _UnusedRepository implements TransactionRepository {
  @override
  Future<void> addTransaction(TransactionEntity transaction) =>
      throw UnimplementedError('test stub repository');

  @override
  Future<void> updateTransaction(TransactionEntity transaction) =>
      throw UnimplementedError('test stub repository');

  @override
  Future<List<TransactionEntity>> getTransactions() =>
      throw UnimplementedError('test stub repository');

  @override
  Future<void> deleteTransaction(String id) =>
      throw UnimplementedError('test stub repository');

  @override
  Future<void> clearTransactions() =>
      throw UnimplementedError('test stub repository');
}
