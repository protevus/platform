// Import necessary libraries
import 'dart:async';

/// Represents the MailQueue interface.
abstract class MailQueue {
  /// Queues a new e-mail message for sending.
  ///
  /// [view] can be a Mailable, String, or List.
  /// [queue] is the optional queue name.
  /// Returns a Future representing the queued result.
  Future<dynamic> queue(dynamic view, {String? queue});

  /// Queues a new e-mail message for sending after [delay].
  ///
  /// [delay] can be a Duration, int (in seconds), or DateTime.
  /// [view] can be a Mailable, String, or List.
  /// [queue] is the optional queue name.
  /// Returns a Future representing the queued result.
  Future<dynamic> later(dynamic delay, dynamic view, {String? queue});
}
