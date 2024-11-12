/// The Queue Package for the Protevus Platform.
///
/// This package provides a Laravel-compatible queue implementation in Dart, offering
/// features like job queuing, delayed job processing, job encryption, and transaction-aware
/// job dispatching.
///
/// # Basic Usage
///
/// ```dart
/// final queue = Queue(container, eventBus, mqClient);
///
/// // Push a job to the queue
/// await queue.push(MyJob());
///
/// // Push a job with delay
/// await queue.later(Duration(minutes: 5), MyJob());
///
/// // Push a job to a specific queue
/// await queue.pushOn('high-priority', MyJob());
/// ```
///
/// # Features
///
/// - Job queuing and processing
/// - Delayed job execution
/// - Job encryption
/// - Transaction-aware job dispatching
/// - Event-based job monitoring
/// - Queue connection management
///
/// # Events
///
/// The queue system fires two main events:
/// - [JobQueueingEvent]: Fired before a job is queued
/// - [JobQueuedEvent]: Fired after a job has been queued
///
/// # Job Interfaces
///
/// Jobs can implement various interfaces to modify their behavior:
/// - [ShouldBeEncrypted]: Job payload will be encrypted
/// - [ShouldQueueAfterCommit]: Job will be queued after database transactions commit
/// - [HasMaxExceptions]: Specify maximum number of exceptions before job fails
/// - [HasFailOnTimeout]: Specify if job should fail on timeout
/// - [HasTimeout]: Specify job timeout duration
/// - [HasTries]: Specify maximum number of retry attempts
/// - [HasBackoff]: Specify delay between retry attempts
/// - [HasRetryUntil]: Specify when to stop retrying
/// - [HasAfterCommit]: Specify if job should run after commit
library platform_queue;

// Core queue implementation
export 'src/queue.dart';

// Events
export 'src/job_queued_event.dart';
export 'src/job_queueing_event.dart';

// Job interfaces
export 'src/should_be_encrypted.dart';
export 'src/should_queue_after_commit.dart';

// Re-export commonly used types and interfaces
export 'src/queue.dart' show Queue, InvalidPayloadException;

// Job configuration interfaces
export 'src/queue.dart' show HasMaxExceptions, HasFailOnTimeout, HasTimeout;
export 'src/queue.dart'
    show HasDisplayName, HasTries, HasBackoff, HasRetryUntil;
export 'src/queue.dart' show HasAfterCommit, HasShouldBeEncrypted;

// Support interfaces
export 'src/queue.dart' show Encrypter, TransactionManager;

// Time utilities
export 'src/queue.dart' show InteractsWithTime;
