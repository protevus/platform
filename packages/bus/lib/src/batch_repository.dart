import 'package:platform_collections/platform_collections.dart';
import 'package:platform_contracts/contracts.dart';

/// In-memory implementation of the batch repository.
class InMemoryBatchRepository implements BatchRepository {
  /// The batches stored in memory.
  final Map<String, BatchContract> _batches = {};

  /// The jobs stored in memory.
  final Map<String, Collection<dynamic>> _jobs = {};

  @override
  Future<BatchContract?> find(String id) async {
    return _batches[id];
  }

  @override
  Future<void> store(BatchContract batch) async {
    _batches[batch.id] = batch;
  }

  @override
  Future<void> delete(String id) async {
    _batches.remove(id);
    _jobs.remove(id);
  }

  @override
  Future<List<BatchContract>> all() async {
    return _batches.values.toList();
  }

  @override
  Future<List<BatchContract>> getFinished() async {
    return _batches.values.where((batch) => batch.finished).toList();
  }

  @override
  Future<List<BatchContract>> getPending() async {
    return _batches.values.where((batch) => !batch.finished).toList();
  }

  @override
  Future<Collection<dynamic>> getJobs(String id) async {
    return _jobs[id] ?? Collection.empty();
  }

  @override
  Future<void> storeJobs(String id, Collection<dynamic> jobs) async {
    _jobs[id] = jobs;
  }
}

/// Database implementation of the batch repository.
class DatabaseBatchRepository implements BatchRepository {
  /// The database connection.
  final dynamic _db;

  /// Creates a new database batch repository.
  ///
  /// [db] The database connection.
  DatabaseBatchRepository(this._db);

  @override
  Future<BatchContract?> find(String id) async {
    // TODO: Implement database find
    throw UnimplementedError();
  }

  @override
  Future<void> store(BatchContract batch) async {
    // TODO: Implement database store
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    // TODO: Implement database delete
    throw UnimplementedError();
  }

  @override
  Future<List<BatchContract>> all() async {
    // TODO: Implement database all
    throw UnimplementedError();
  }

  @override
  Future<List<BatchContract>> getFinished() async {
    // TODO: Implement database getFinished
    throw UnimplementedError();
  }

  @override
  Future<List<BatchContract>> getPending() async {
    // TODO: Implement database getPending
    throw UnimplementedError();
  }

  @override
  Future<Collection<dynamic>> getJobs(String id) async {
    // TODO: Implement database getJobs
    throw UnimplementedError();
  }

  @override
  Future<void> storeJobs(String id, Collection<dynamic> jobs) async {
    // TODO: Implement database storeJobs
    throw UnimplementedError();
  }
}
