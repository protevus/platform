abstract class Job {
  /// Get the UUID of the job.
  String? uuid();

  /// Get the job identifier.
  String getJobId();

  /// Get the decoded body of the job.
  Map<String, dynamic> payload();

  /// Fire the job.
  void fire();

  /// Release the job back into the queue after [delay] seconds.
  void release(int delay);

  /// Determine if the job was released back into the queue.
  bool isReleased();

  /// Delete the job from the queue.
  void delete();

  /// Determine if the job has been deleted.
  bool isDeleted();

  /// Determine if the job has been deleted or released.
  bool isDeletedOrReleased();

  /// Get the number of times the job has been attempted.
  int attempts();

  /// Determine if the job has been marked as a failure.
  bool hasFailed();

  /// Mark the job as "failed".
  void markAsFailed();

  /// Delete the job, call the "failed" method, and raise the failed job event.
  void fail([Exception? e]);

  /// Get the number of times to attempt a job.
  int? maxTries();

  /// Get the maximum number of exceptions allowed, regardless of attempts.
  int? maxExceptions();

  /// Get the number of seconds the job can run.
  int? timeout();

  /// Get the timestamp indicating when the job should timeout.
  int? retryUntil();

  /// Get the name of the queued job class.
  String getName();

  /// Get the resolved name of the queued job class.
  String resolveName();

  /// Get the name of the connection the job belongs to.
  String getConnectionName();

  /// Get the name of the queue the job belongs to.
  String getQueue();

  /// Get the raw body string for the job.
  String getRawBody();
}
