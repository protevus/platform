import 'package:illuminate_collections/collections.dart';
import 'package:illuminate_contracts/contracts.dart';

import 'batch_repository.dart';

/// Interface for batch repositories that support pruning.
///
/// This interface extends the base [BatchRepository] interface to add support
/// for pruning old or completed batches from storage.
abstract interface class PrunableBatchRepository implements BatchRepository {
  /// Prune old batches from storage.
  ///
  /// [hours] The number of hours after which batches should be pruned.
  /// Returns the number of batches that were pruned.
  Future<int> prune(int hours);
}

/// A prunable in-memory batch repository.
class PrunableInMemoryBatchRepository implements PrunableBatchRepository {
  /// The underlying repository.
  final InMemoryBatchRepository _repository;

  /// The timestamps when batches were created.
  final Map<String, DateTime> _timestamps = {};

  /// Creates a new prunable in-memory batch repository.
  PrunableInMemoryBatchRepository() : _repository = InMemoryBatchRepository();

  @override
  Future<List<BatchContract>> all() => _repository.all();

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
    _timestamps.remove(id);
  }

  @override
  Future<BatchContract?> find(String id) => _repository.find(id);

  @override
  Future<List<BatchContract>> getFinished() => _repository.getFinished();

  @override
  Future<List<BatchContract>> getPending() => _repository.getPending();

  @override
  Future<void> store(BatchContract batch) async {
    await _repository.store(batch);
    _timestamps[batch.id] = DateTime.now();
  }

  @override
  Future<Collection<dynamic>> getJobs(String id) => _repository.getJobs(id);

  @override
  Future<void> storeJobs(String id, Collection<dynamic> jobs) =>
      _repository.storeJobs(id, jobs);

  @override
  Future<int> prune(int hours) async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(hours: hours));
    final prunedIds = <String>[];

    _timestamps.forEach((id, timestamp) {
      if (timestamp.isBefore(cutoff)) {
        prunedIds.add(id);
      }
    });

    for (final id in prunedIds) {
      await delete(id);
    }

    return prunedIds.length;
  }
}

/// A prunable database batch repository.
class PrunableDatabaseBatchRepository implements PrunableBatchRepository {
  /// The underlying repository.
  final DatabaseBatchRepository _repository;

  /// Creates a new prunable database batch repository.
  ///
  /// [db] The database connection.
  PrunableDatabaseBatchRepository(dynamic db)
      : _repository = DatabaseBatchRepository(db);

  @override
  Future<List<BatchContract>> all() => _repository.all();

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<BatchContract?> find(String id) => _repository.find(id);

  @override
  Future<List<BatchContract>> getFinished() => _repository.getFinished();

  @override
  Future<List<BatchContract>> getPending() => _repository.getPending();

  @override
  Future<void> store(BatchContract batch) => _repository.store(batch);

  @override
  Future<Collection<dynamic>> getJobs(String id) => _repository.getJobs(id);

  @override
  Future<void> storeJobs(String id, Collection<dynamic> jobs) =>
      _repository.storeJobs(id, jobs);

  @override
  Future<int> prune(int hours) async {
    // TODO: Implement database prune
    throw UnimplementedError();
  }
}
