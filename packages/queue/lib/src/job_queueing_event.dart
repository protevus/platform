import 'package:angel3_event_bus/event_bus.dart';
import 'package:equatable/equatable.dart';

/// Event fired before a job is queued.
///
/// This event is dispatched just before a job is added to the queue,
/// allowing listeners to perform actions or validations before the job
/// is actually queued.
///
/// Example:
/// ```dart
/// eventBus.on<JobQueueingEvent>().listen((event) {
///   print('About to queue job on ${event.queue}');
///   if (event.delay != null) {
///     print('Will be delayed by ${event.delay}');
///   }
/// });
/// ```
///
/// This event can be particularly useful for:
/// - Logging job attempts
/// - Validating job parameters before queueing
/// - Monitoring queue activity
/// - Implementing queue-based metrics
class JobQueueingEvent extends AppEvent {
  /// The name of the queue connection.
  final String connectionName;

  /// The name of the specific queue the job will be added to.
  final String? queue;

  /// The job instance to be queued.
  final dynamic job;

  /// The serialized payload of the job.
  final String payload;

  /// The delay before the job should be processed, if any.
  final Duration? delay;

  /// Creates a new [JobQueueingEvent].
  ///
  /// [connectionName] is the name of the queue connection.
  /// [queue] is the specific queue name, if any.
  /// [job] is the actual job instance to be queued.
  /// [payload] is the serialized job data.
  /// [delay] is the optional delay before processing.
  JobQueueingEvent(
      this.connectionName, this.queue, this.job, this.payload, this.delay);

  @override
  List<Object?> get props => [connectionName, queue, job, payload, delay];

  @override
  Map<String, dynamic> toJson() {
    return {
      'connectionName': connectionName,
      'queue': queue,
      'job': job.toString(),
      'payload': payload,
      'delay': delay?.inMilliseconds,
    };
  }

  /// The event name used for identification.
  @override
  String get name => 'job.queueing';

  @override
  String toString() =>
      'JobQueueingEvent(connectionName: $connectionName, queue: $queue, delay: $delay)';
}
