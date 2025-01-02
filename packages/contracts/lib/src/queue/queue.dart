import 'dart:async';

/// Interface for queue implementations.
///
/// This contract defines how jobs should be pushed onto and processed from a queue.
abstract class Queue {
  /// Push a job onto the queue.
  ///
  /// Example:
  /// ```dart
  /// await queue.push(ProcessOrderJob(orderId: 123));
  /// ```
  Future<dynamic> push(dynamic job);

  /// Push a job onto a specific queue.
  ///
  /// Example:
  /// ```dart
  /// await queue.pushOn('high-priority', ProcessOrderJob(orderId: 123));
  /// ```
  Future<dynamic> pushOn(String queue, dynamic job);

  /// Push a job onto the queue after a delay.
  ///
  /// Example:
  /// ```dart
  /// await queue.later(Duration(minutes: 5), SendReminderJob());
  /// ```
  Future<dynamic> later(Duration delay, dynamic job);

  /// Push a job onto a specific queue after a delay.
  ///
  /// Example:
  /// ```dart
  /// await queue.laterOn(
  ///   'notifications',
  ///   Duration(minutes: 5),
  ///   SendReminderJob(),
  /// );
  /// ```
  Future<dynamic> laterOn(String queue, Duration delay, dynamic job);

  /// Get the size of the queue.
  ///
  /// Example:
  /// ```dart
  /// var size = await queue.size();
  /// print('Queue has $size jobs');
  /// ```
  Future<int> size();

  /// Clear all jobs from the queue.
  ///
  /// Example:
  /// ```dart
  /// await queue.clear();
  /// ```
  Future<void> clear();
}
