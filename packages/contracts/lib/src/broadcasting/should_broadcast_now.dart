import 'should_broadcast.dart';

/// Interface for events that should be broadcast immediately.
///
/// This contract extends [ShouldBroadcast] and serves as a marker interface
/// for events that should be broadcast immediately rather than being queued.
/// While it doesn't define any additional methods, implementing this interface
/// signals that the event should bypass the queue.
///
/// Example:
/// ```dart
/// class OrderShippedEvent implements ShouldBroadcastNow {
///   final int orderId;
///
///   OrderShippedEvent(this.orderId);
///
///   @override
///   dynamic broadcastOn() {
///     return 'orders.$orderId';
///   }
/// }
/// ```
abstract class ShouldBroadcastNow implements ShouldBroadcast {}
