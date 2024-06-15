import 'dispatcher.dart';
import 'batch.dart';
import 'pending_batch.dart';

// TODO: Missing imports will come from other ports refer to original PHP file.

abstract class QueueingDispatcher implements Dispatcher {
  /// Attempt to find the batch with the given ID.
  ///
  /// @param  String  batchId
  /// @return Batch|null
  Future<Batch?> findBatch(String batchId);

  /// Create a new batch of queueable jobs.
  ///
  /// @param  List<dynamic> jobs
  /// @return PendingBatch
  PendingBatch batch(List<dynamic> jobs);

  /// Dispatch a command to its appropriate handler behind a queue.
  ///
  /// @param  dynamic  command
  /// @return dynamic
  Future<dynamic> dispatchToQueue(dynamic command);
}
