import 'dart:async';

import 'package:illuminate_collections/collections.dart';

/// Interface for batch operations.
abstract interface class BatchContract {
  /// The unique identifier for this batch.
  String get id;

  /// The name assigned to this batch.
  String? get name;

  /// The total number of jobs in this batch.
  int get totalJobs;

  /// The number of jobs that have been processed.
  int get processedJobs;

  /// The number of jobs that have failed.
  int get failedJobs;

  /// The number of jobs that are still pending.
  int get pendingJobs;

  /// Whether this batch has been cancelled.
  bool get cancelled;

  /// Whether this batch has finished processing.
  bool get finished;

  /// The IDs of job batches that are chained after this batch.
  Collection<String> get chainedBatches;

  /// The options for this batch.
  Map<String, dynamic> get options;

  /// Add a callback to be executed after all jobs have executed successfully.
  BatchContract then(FutureOr<void> Function(BatchContract batch) handler);

  /// Add a callback to be executed after the first failing job.
  BatchContract onError(
      void Function(BatchContract batch, dynamic error) handler);

  /// Add a callback to be executed after the batch has finished executing.
  BatchContract onFinish(void Function(BatchContract batch) handler);

  /// Cancel the batch.
  Future<void> cancel();

  /// Delete the batch.
  Future<void> delete();
}
