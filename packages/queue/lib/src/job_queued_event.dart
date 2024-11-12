import 'package:angel3_event_bus/event_bus.dart';
import 'package:equatable/equatable.dart';

/// Event fired after a job has been successfully queued.
///
/// This event is dispatched after a job has been successfully added to the queue,
/// providing information about the queued job including its ID, payload, and any
/// specified delay.
///
/// Example:
/// ```dart
/// eventBus.on<JobQueuedEvent>().listen((event) {
///   print('Job ${event.jobId} queued on ${event.queue}');
///   print('Will execute after: ${event.delay}');
/// });
/// ```
class JobQueuedEvent extends AppEvent {
  /// The name of the queue connection.
  final String connectionName;

  /// The name of the specific queue the job was added to.
  final String? queue;

  /// The unique identifier assigned to the queued job.
  final String jobId;

  /// The job instance that was queued.
  final dynamic job;

  /// The serialized payload of the job.
  final String payload;

  /// The delay before the job should be processed, if any.
  final Duration? delay;

  /// Creates a new [JobQueuedEvent].
  ///
  /// [connectionName] is the name of the queue connection.
  /// [queue] is the specific queue name, if any.
  /// [jobId] is the unique identifier assigned to the job.
  /// [job] is the actual job instance.
  /// [payload] is the serialized job data.
  /// [delay] is the optional delay before processing.
  JobQueuedEvent(this.connectionName, this.queue, this.jobId, this.job,
      this.payload, this.delay);

  @override
  List<Object?> get props =>
      [connectionName, queue, jobId, job, payload, delay];

  @override
  Map<String, dynamic> toJson() {
    return {
      'connectionName': connectionName,
      'queue': queue,
      'jobId': jobId,
      'job': job.toString(),
      'payload': payload,
      'delay': delay?.inMilliseconds,
    };
  }

  /// The event name used for identification.
  @override
  String get name => 'job.queued';

  @override
  String toString() =>
      'JobQueuedEvent(connectionName: $connectionName, queue: $queue, jobId: $jobId, delay: $delay)';
}
