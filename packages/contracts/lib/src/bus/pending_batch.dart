import 'dart:async';

import 'batch.dart';

/// Interface for configuring a batch before it is dispatched.
///
/// This contract defines how batches can be configured with various options
/// before they are dispatched to be processed.
abstract interface class PendingBatchContract {
  /// Set the name of the batch.
  ///
  /// Example:
  /// ```dart
  /// batch.name('process-orders');
  /// ```
  PendingBatchContract name(String name);

  /// Allow failures in the batch without stopping execution.
  ///
  /// Example:
  /// ```dart
  /// batch.allowFailures();
  /// ```
  PendingBatchContract allowFailures();

  /// Set the number of times to attempt the batch.
  ///
  /// Example:
  /// ```dart
  /// batch.tries(3);
  /// ```
  PendingBatchContract tries(int times);

  /// Set the timeout for the batch.
  ///
  /// Example:
  /// ```dart
  /// batch.timeout(Duration(minutes: 5));
  /// ```
  PendingBatchContract timeout(Duration duration);

  /// Set the delay between retry attempts.
  ///
  /// Example:
  /// ```dart
  /// batch.retryAfter(Duration(seconds: 30));
  /// ```
  PendingBatchContract retryAfter(Duration duration);

  /// Add a chain of jobs to be run after this batch completes.
  ///
  /// Example:
  /// ```dart
  /// batch.chain([SendNotificationJob(), UpdateStatusJob()]);
  /// ```
  PendingBatchContract chain(List<dynamic> jobs);

  /// Add a callback to be executed after all jobs have executed successfully.
  ///
  /// Example:
  /// ```dart
  /// batch.then((batch) {
  ///   print('Batch ${batch.id} completed successfully');
  /// });
  /// ```
  PendingBatchContract then(
      FutureOr<void> Function(BatchContract batch) handler);

  /// Add a callback to be executed after the first failing job.
  ///
  /// Example:
  /// ```dart
  /// batch.onError((batch, error) {
  ///   print('Batch ${batch.id} failed: $error');
  /// });
  /// ```
  PendingBatchContract onError(
      void Function(BatchContract batch, dynamic error) handler);

  /// Add a callback to be executed after the batch has finished executing.
  ///
  /// Example:
  /// ```dart
  /// batch.onFinish((batch) {
  ///   print('Batch ${batch.id} finished');
  /// });
  /// ```
  PendingBatchContract onFinish(void Function(BatchContract batch) handler);

  /// Dispatch the batch.
  ///
  /// Example:
  /// ```dart
  /// var batch = await pendingBatch.dispatch();
  /// print('Dispatched batch: ${batch.id}');
  /// ```
  Future<BatchContract> dispatch();
}
