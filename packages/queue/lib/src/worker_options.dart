/// Configuration options for queue workers.
class WorkerOptions {
  /// The maximum number of seconds a job may be processed.
  final Duration timeout;

  /// The number of seconds to wait before retrying a job that has failed.
  final Duration backoff;

  /// The maximum number of times to attempt a job.
  final int maxTries;

  /// The number of jobs to process before stopping.
  final int maxJobs;

  /// The maximum amount of time the worker should run.
  final Duration maxTime;

  /// The number of seconds to sleep when no job is available.
  final Duration sleep;

  /// The number of seconds to rest between jobs.
  final Duration rest;

  /// Whether to stop when the queue is empty.
  final bool stopWhenEmpty;

  /// Create a new worker options instance.
  const WorkerOptions({
    this.timeout = const Duration(minutes: 1),
    this.backoff = const Duration(seconds: 0),
    this.maxTries = 0,
    this.maxJobs = 0,
    this.maxTime = Duration.zero,
    this.sleep = const Duration(seconds: 3),
    this.rest = Duration.zero,
    this.stopWhenEmpty = false,
  });

  /// Create a copy of this instance with the given values.
  WorkerOptions copyWith({
    Duration? timeout,
    Duration? backoff,
    int? maxTries,
    int? maxJobs,
    Duration? maxTime,
    Duration? sleep,
    Duration? rest,
    bool? stopWhenEmpty,
  }) {
    return WorkerOptions(
      timeout: timeout ?? this.timeout,
      backoff: backoff ?? this.backoff,
      maxTries: maxTries ?? this.maxTries,
      maxJobs: maxJobs ?? this.maxJobs,
      maxTime: maxTime ?? this.maxTime,
      sleep: sleep ?? this.sleep,
      rest: rest ?? this.rest,
      stopWhenEmpty: stopWhenEmpty ?? this.stopWhenEmpty,
    );
  }
}
