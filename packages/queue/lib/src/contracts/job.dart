/// Base interface for queue jobs.
abstract class Job {
  /// Get the job identifier.
  String get jobId;

  /// Get the raw body string of the job.
  String get rawBody;

  /// Get the decoded body of the job.
  Map<String, dynamic> get payload;

  /// Get the number of times the job has been attempted.
  int get attempts;

  /// Get the name of the queue the job belongs to.
  String get queue;

  /// Get the name of the connection the job belongs to.
  String get connectionName;

  /// Fire the job.
  Future<void> fire();

  /// Delete the job from the queue.
  Future<void> delete();

  /// Release the job back onto the queue after a delay.
  Future<void> release([Duration? delay]);

  /// Fail the job with the given exception.
  Future<void> fail([Object? exception, StackTrace? stackTrace]);

  /// Get whether the job has been deleted.
  bool get isDeleted;

  /// Get whether the job has been released.
  bool get isReleased;

  /// Get whether the job has failed.
  bool get hasFailed;

  /// Get the maximum number of attempts for the job.
  int? get maxTries;

  /// Get the timeout for the job.
  Duration? get timeout;

  /// Get the retry delay for the job.
  Duration? get backoff;

  /// Get the timestamp until which the job can be retried.
  DateTime? get retryUntil;
}
