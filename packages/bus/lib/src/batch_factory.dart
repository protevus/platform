import 'package:platform_collections/platform_collections.dart';
import 'package:platform_contracts/contracts.dart';

import 'batch.dart';

/// Factory for creating batch instances.
///
/// This class provides methods for creating and configuring batch instances
/// with the appropriate options and configuration.
class BatchFactory {
  /// Create a new batch instance.
  ///
  /// [id] The unique identifier for the batch.
  /// [name] The name assigned to the batch.
  /// [totalJobs] The total number of jobs in the batch.
  /// [chainedBatches] The IDs of job batches that are chained after this batch.
  /// [options] The options for the batch.
  static BatchContract create(
    String id,
    String? name,
    int totalJobs,
    Collection<String> chainedBatches,
    Map<String, dynamic> options,
  ) {
    return Batch(
      id,
      name,
      totalJobs,
      chainedBatches,
      options,
    );
  }

  /// Create a new batch instance with default options.
  ///
  /// [id] The unique identifier for the batch.
  /// [totalJobs] The total number of jobs in the batch.
  static BatchContract createDefault(String id, int totalJobs) {
    return create(
      id,
      null,
      totalJobs,
      Collection<String>([]),
      {},
    );
  }

  /// Create a new batch instance from a JSON map.
  ///
  /// [data] The JSON map containing the batch data.
  static BatchContract fromJson(Map<String, dynamic> data) {
    return create(
      data['id'] as String,
      data['name'] as String?,
      data['total_jobs'] as int,
      Collection<String>((data['chained_batches'] as List).cast<String>()),
      Map<String, dynamic>.from(data['options'] as Map),
    );
  }

  /// Convert a batch instance to a JSON map.
  ///
  /// [batch] The batch instance to convert.
  static Map<String, dynamic> toJson(BatchContract batch) {
    return {
      'id': batch.id,
      'name': batch.name,
      'total_jobs': batch.totalJobs,
      'processed_jobs': batch.processedJobs,
      'failed_jobs': batch.failedJobs,
      'pending_jobs': batch.pendingJobs,
      'cancelled': batch.cancelled,
      'finished': batch.finished,
      'chained_batches': batch.chainedBatches.toList(),
      'options': batch.options,
    };
  }
}
