import 'dart:async';

import 'package:illuminate_collections/collections.dart';
import 'package:illuminate_contracts/contracts.dart';

/// A batch of queued jobs.
///
/// This class represents a group of jobs that are processed together as a batch.
class Batch implements BatchContract {
  /// The unique identifier for this batch.
  @override
  final String id;

  /// The name assigned to this batch.
  @override
  final String? name;

  /// The total number of jobs in this batch.
  @override
  final int totalJobs;

  /// The number of jobs that have been processed.
  @override
  int processedJobs = 0;

  /// The number of jobs that have failed.
  @override
  int failedJobs = 0;

  /// Whether this batch has been cancelled.
  @override
  bool cancelled = false;

  /// The IDs of job batches that are chained after this batch.
  final Collection<String> _chainedBatches;

  /// The options for this batch.
  @override
  final Map<String, dynamic> options;

  /// The callback to execute after all jobs have executed successfully.
  FutureOr<void> Function(BatchContract batch)? _then;

  /// The callback to execute after the first failing job.
  void Function(BatchContract batch, dynamic error)? _catch;

  /// The callback to execute after the batch has finished executing.
  void Function(BatchContract batch)? _finally;

  /// Creates a new batch instance.
  ///
  /// [id] The unique identifier for this batch.
  /// [name] The name assigned to this batch.
  /// [totalJobs] The total number of jobs in this batch.
  /// [chainedBatches] The IDs of job batches that are chained after this batch.
  /// [options] The options for this batch.
  Batch(
    this.id,
    this.name,
    this.totalJobs,
    Collection<String> chainedBatches,
    this.options,
  ) : _chainedBatches = chainedBatches;

  @override
  int get pendingJobs => totalJobs - processedJobs;

  @override
  bool get finished => processedJobs == totalJobs;

  @override
  Collection<String> get chainedBatches => _chainedBatches;

  @override
  BatchContract then(FutureOr<void> Function(BatchContract batch) handler) {
    _then = handler;
    return this;
  }

  @override
  BatchContract onError(
      void Function(BatchContract batch, dynamic error) handler) {
    _catch = handler;
    return this;
  }

  @override
  BatchContract onFinish(void Function(BatchContract batch) handler) {
    _finally = handler;
    return this;
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }

  @override
  Future<void> delete() async {
    // Deletion logic will be handled by the repository
  }

  /// Execute the success callback if one is registered.
  Future<void> invokeSuccessCallback() async {
    if (_then != null) {
      await _then!(this);
    }
  }

  /// Execute the error callback if one is registered.
  void invokeErrorCallback(dynamic error) {
    if (_catch != null) {
      _catch!(this, error);
    }
  }

  /// Execute the finally callback if one is registered.
  void invokeFinallyCallback() {
    if (_finally != null) {
      _finally!(this);
    }
  }

  /// Creates a new batch with the given chained batches.
  Batch withChainedBatches(Collection<String> chainedBatches) {
    return Batch(
      id,
      name,
      totalJobs,
      chainedBatches,
      options,
    );
  }
}
