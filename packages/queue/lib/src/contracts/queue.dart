import 'package:illuminate_queue/src/contracts/job.dart';

/// Base interface for queue implementations.
abstract class Queue {
  /// Push a new job onto the queue.
  Future<String?> push(
    String job, {
    Map<String, dynamic>? data,
    String? queue,
  });

  /// Push a new job onto the queue after a delay.
  Future<String?> later(
    Duration delay,
    String job, {
    Map<String, dynamic>? data,
    String? queue,
  });

  /// Push multiple jobs onto the queue.
  Future<void> bulk(
    List<String> jobs, {
    Map<String, dynamic>? data,
    String? queue,
  });

  /// Get the size of the queue.
  Future<int> size([String? queue]);

  /// Pop the next job off of the queue.
  Future<Job?> pop([String? queue]);

  /// Clear all of the jobs from the queue.
  Future<int> clear([String? queue]);

  /// Get the connection name for the queue.
  String get connectionName;

  /// Set the connection name for the queue.
  set connectionName(String name);
}
