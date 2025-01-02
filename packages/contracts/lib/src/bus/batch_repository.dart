import 'dart:async';

import 'package:platform_collections/platform_collections.dart';

import 'batch.dart';

/// Interface for batch storage and retrieval.
///
/// This contract defines how batches should be stored and retrieved from
/// a persistent storage system.
abstract interface class BatchRepository {
  /// Find a batch by its ID.
  ///
  /// Example:
  /// ```dart
  /// var batch = await repository.find('batch-123');
  /// if (batch != null) {
  ///   print('Found batch: ${batch.id}');
  /// }
  /// ```
  Future<BatchContract?> find(String id);

  /// Store a batch.
  ///
  /// Example:
  /// ```dart
  /// await repository.store(batch);
  /// ```
  Future<void> store(BatchContract batch);

  /// Delete a batch by its ID.
  ///
  /// Example:
  /// ```dart
  /// await repository.delete('batch-123');
  /// ```
  Future<void> delete(String id);

  /// Get all batches.
  ///
  /// Example:
  /// ```dart
  /// var batches = await repository.all();
  /// for (var batch in batches) {
  ///   print('Batch: ${batch.id}');
  /// }
  /// ```
  Future<List<BatchContract>> all();

  /// Get all batches that have finished.
  ///
  /// Example:
  /// ```dart
  /// var finishedBatches = await repository.getFinished();
  /// for (var batch in finishedBatches) {
  ///   print('Finished batch: ${batch.id}');
  /// }
  /// ```
  Future<List<BatchContract>> getFinished();

  /// Get all batches that are still pending.
  ///
  /// Example:
  /// ```dart
  /// var pendingBatches = await repository.getPending();
  /// for (var batch in pendingBatches) {
  ///   print('Pending batch: ${batch.id}');
  /// }
  /// ```
  Future<List<BatchContract>> getPending();

  /// Get the jobs for a batch.
  ///
  /// Example:
  /// ```dart
  /// var jobs = await repository.getJobs('batch-123');
  /// for (var job in jobs) {
  ///   print('Job: ${job.runtimeType}');
  /// }
  /// ```
  Future<Collection<dynamic>> getJobs(String id);

  /// Store jobs for a batch.
  ///
  /// Example:
  /// ```dart
  /// await repository.storeJobs('batch-123', [job1, job2]);
  /// ```
  Future<void> storeJobs(String id, Collection<dynamic> jobs);
}
