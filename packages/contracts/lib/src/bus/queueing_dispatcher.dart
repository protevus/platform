import 'batch.dart';
import 'dispatcher.dart';

import 'pending_batch.dart';

/// Interface for queueing command bus dispatching.
///
/// This contract extends the base [Dispatcher] to add queueing functionality,
/// allowing commands to be dispatched to queues and processed in batches.
abstract interface class QueueingDispatcher implements Dispatcher {
  /// Attempt to find the batch with the given ID.
  ///
  /// Example:
  /// ```dart
  /// var batch = await dispatcher.findBatch('batch-123');
  /// if (batch != null) {
  ///   print('Found batch with ${batch.jobs.length} jobs');
  /// }
  /// ```
  Future<BatchContract?> findBatch(String batchId);

  /// Create a new batch of queueable jobs.
  ///
  /// Example:
  /// ```dart
  /// var batch = await dispatcher.batch([
  ///   ProcessOrderCommand(orderId: 1),
  ///   ProcessOrderCommand(orderId: 2),
  ///   ProcessOrderCommand(orderId: 3),
  /// ]);
  /// ```
  PendingBatchContract batch(dynamic jobs);

  /// Dispatch a command to its appropriate handler behind a queue.
  ///
  /// Example:
  /// ```dart
  /// await dispatcher.dispatchToQueue(
  ///   ProcessLargeOrderCommand(orderId: 1),
  /// );
  /// ```
  Future<dynamic> dispatchToQueue(dynamic job);
}
