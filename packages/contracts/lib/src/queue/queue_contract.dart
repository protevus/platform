import 'package:meta/meta.dart';

/// Contract for queue operations.
///
/// Laravel-compatible: Core queue functionality matching Laravel's Queue
/// interface, adapted for Dart's type system and async patterns.
@sealed
abstract class QueueContract {
  /// Pushes a job onto the queue.
  ///
  /// Laravel-compatible: Core push method.
  /// Uses dynamic job type for flexibility.
  Future<String> push(dynamic job, [String? queue]);

  /// Pushes a job onto a specific queue.
  ///
  /// Laravel-compatible: Queue-specific push.
  /// Uses dynamic job type for flexibility.
  Future<String> pushOn(String queue, dynamic job);

  /// Pushes a delayed job onto the queue.
  ///
  /// Laravel-compatible: Delayed job push.
  /// Uses Duration instead of DateTime/Carbon.
  Future<String> later(Duration delay, dynamic job, [String? queue]);

  /// Pushes a delayed job onto a specific queue.
  ///
  /// Laravel-compatible: Queue-specific delayed push.
  /// Uses Duration instead of DateTime/Carbon.
  Future<String> laterOn(String queue, Duration delay, dynamic job);

  /// Pushes multiple jobs onto the queue.
  ///
  /// Laravel-compatible: Bulk job push.
  /// Uses dynamic job type for flexibility.
  Future<void> bulk(List<dynamic> jobs, [String? queue]);

  /// Gets the next job from the queue.
  ///
  /// Laravel-compatible: Job pop operation.
  Future<JobContract?> pop([String? queue]);

  /// Creates a job batch.
  ///
  /// Laravel-compatible: Batch creation.
  BatchContract batch(List<JobContract> jobs);

  /// Gets a queue connection.
  ///
  /// Laravel-compatible: Connection retrieval.
  QueueConnectionContract connection([String? name]);
}

/// Contract for queue jobs.
///
/// Laravel-compatible: Core job interface matching Laravel's Job
/// contract, with platform-specific extensions.
@sealed
abstract class JobContract {
  /// Gets the job ID.
  ///
  /// Laravel-compatible: Job identifier.
  String get id;

  /// Gets the job payload.
  ///
  /// Laravel-compatible: Job data.
  Map<String, dynamic> get payload;

  /// Gets the number of attempts.
  ///
  /// Laravel-compatible: Attempt tracking.
  int get attempts;

  /// Gets the maximum number of tries.
  ///
  /// Laravel-compatible: Retry limit.
  int get tries;

  /// Gets the job timeout in seconds.
  ///
  /// Laravel-compatible: Timeout configuration.
  int get timeout;

  /// Gets the queue name.
  ///
  /// Laravel-compatible: Queue designation.
  String? get queue;

  /// Gets the job delay.
  ///
  /// Laravel-compatible: Delay configuration.
  /// Uses Duration instead of DateTime/Carbon.
  Duration? get delay;

  /// Whether the job should be encrypted.
  ///
  /// Platform-specific: Adds encryption support.
  bool get shouldBeEncrypted;

  /// Whether to dispatch after commit.
  ///
  /// Laravel-compatible: Transaction support.
  bool get afterCommit;

  /// Executes the job.
  ///
  /// Laravel-compatible: Core job execution.
  Future<void> handle();

  /// Handles job failure.
  ///
  /// Laravel-compatible: Failure handling.
  Future<void> failed([Exception? exception]);

  /// Releases the job back to the queue.
  ///
  /// Laravel-compatible: Job release.
  /// Uses Duration instead of DateTime/Carbon.
  Future<void> release([Duration? delay]);

  /// Deletes the job.
  ///
  /// Laravel-compatible: Job deletion.
  Future<void> delete();
}

/// Contract for job batches.
///
/// Laravel-compatible: Batch operations matching Laravel's batch
/// functionality, with platform-specific extensions.
@sealed
abstract class BatchContract {
  /// Gets the batch ID.
  ///
  /// Laravel-compatible: Batch identifier.
  String get id;

  /// Gets the jobs in the batch.
  ///
  /// Laravel-compatible: Batch jobs.
  List<JobContract> get jobs;

  /// Adds jobs to the batch.
  ///
  /// Laravel-compatible: Job addition.
  void add(List<JobContract> jobs);

  /// Dispatches the batch.
  ///
  /// Laravel-compatible: Batch dispatch.
  Future<void> dispatch();

  /// Allows failures in the batch.
  ///
  /// Laravel-compatible: Failure configuration.
  BatchContract allowFailures();

  /// Sets the batch name.
  ///
  /// Laravel-compatible: Batch naming.
  BatchContract name(String name);

  /// Adds a callback when all jobs finish.
  ///
  /// Laravel-compatible: Success callback.
  BatchContract then(void Function(BatchContract) callback);

  /// Adds a callback when the batch fails.
  ///
  /// Laravel-compatible: Error callback.
  BatchContract onError(void Function(BatchContract, dynamic) callback);

  /// Gets the batch progress.
  ///
  /// Platform-specific: Progress tracking.
  double get progress;

  /// Gets finished job count.
  ///
  /// Platform-specific: Completion tracking.
  int get finished;

  /// Gets failed job count.
  ///
  /// Platform-specific: Failure tracking.
  int get failed;

  /// Gets pending job count.
  ///
  /// Platform-specific: Pending tracking.
  int get pending;

  /// Gets total job count.
  ///
  /// Platform-specific: Size tracking.
  int get total;
}

/// Contract for queue connections.
///
/// Laravel-compatible: Connection management matching Laravel's
/// queue connection functionality.
@sealed
abstract class QueueConnectionContract {
  /// Gets the connection name.
  ///
  /// Laravel-compatible: Connection identifier.
  String get name;

  /// Gets the connection driver.
  ///
  /// Laravel-compatible: Driver type.
  String get driver;

  /// Gets the connection config.
  ///
  /// Laravel-compatible: Configuration access.
  Map<String, dynamic> get config;

  /// Pushes a job onto the queue.
  ///
  /// Laravel-compatible: Job push.
  Future<String> push(dynamic job, [String? queue]);

  /// Gets the next job from the queue.
  ///
  /// Laravel-compatible: Job pop.
  Future<JobContract?> pop([String? queue]);

  /// Gets queue size.
  ///
  /// Laravel-compatible: Size check.
  Future<int> size([String? queue]);

  /// Clears the queue.
  ///
  /// Laravel-compatible: Queue clear.
  Future<void> clear([String? queue]);

  /// Pauses job processing.
  ///
  /// Laravel-compatible: Processing pause.
  Future<void> pause([String? queue]);

  /// Resumes job processing.
  ///
  /// Laravel-compatible: Processing resume.
  Future<void> resume([String? queue]);
}

/// Contract for queue manager.
///
/// Laravel-compatible: Manager functionality matching Laravel's
/// queue manager interface.
@sealed
abstract class QueueManagerContract {
  /// Gets a queue connection.
  ///
  /// Laravel-compatible: Connection retrieval.
  QueueConnectionContract connection([String? name]);

  /// Gets the default connection name.
  ///
  /// Laravel-compatible: Default connection.
  String get defaultConnection;

  /// Sets the default connection name.
  ///
  /// Laravel-compatible: Default connection.
  set defaultConnection(String name);

  /// Gets connection configuration.
  ///
  /// Laravel-compatible: Config access.
  Map<String, dynamic> getConfig(String name);

  /// Extends available drivers.
  ///
  /// Laravel-compatible: Driver extension.
  void extend(String driver,
      QueueConnectionContract Function(Map<String, dynamic>) callback);
}
