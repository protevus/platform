import 'dart:async';

import 'queue.dart';

/// Marker interface for jobs that should be queued.
abstract class ShouldQueue {}

/// Interface for jobs that can be queued with configuration.
abstract class QueueableJob {
  /// The name of the connection the job should be sent to.
  String? get connection;

  /// The name of the queue the job should be sent to.
  String? get queue;

  /// The number of seconds before the job should be processed.
  Duration? get delay;

  /// The number of times the job may be attempted.
  int? get maxTries;

  /// The number of seconds to wait before retrying the job.
  Duration? get retryAfter;

  /// The time at which the job should timeout.
  Duration? get timeout;

  /// Set the desired connection for the job.
  QueueableJob onConnection(String connection);

  /// Set the desired queue for the job.
  QueueableJob onQueue(String queue);

  /// Set the desired delay for the job.
  QueueableJob withDelay(Duration delay);

  /// Set the number of times the job may be attempted.
  QueueableJob setTries(int count, {Duration? retryAfter});

  /// Set the timeout for the job.
  QueueableJob withTimeout(Duration timeout);
}

/// Interface for jobs that interact with the queue.
abstract class InteractsWithQueue {
  /// The underlying queue job instance.
  dynamic get job;

  /// Set the underlying queue job instance.
  set job(dynamic job);

  /// Get the number of times the job has been attempted.
  int get attempts;

  /// Get the name of the queue the job belongs to.
  String get queue;

  /// Get whether or not the job has been deleted.
  bool get isDeleted;

  /// Get whether or not the job has been released.
  bool get isReleased;

  /// Delete the job from the queue.
  Future<void> delete();

  /// Release the job back onto the queue.
  Future<void> release([Duration? delay]);

  /// Set the underlying queue job instance.
  void setJob(dynamic job);
}

/// Interface for jobs that can be queued.
abstract class Queueable {
  /// The name of the connection the job should be sent to.
  String? get connection;

  /// The name of the queue the job should be sent to.
  String? get queue;

  /// The number of seconds before the job should be processed.
  Duration? get delay;

  /// The time at which the job should timeout.
  Duration? get timeout;

  /// Handle a job failure.
  Future<void> failed([dynamic error]);
}
