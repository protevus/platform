/// Interface for events that should be broadcast.
///
/// This contract defines how events should specify their broadcast channels.
/// It's implemented by event classes that need to be broadcast to specific channels.
abstract class ShouldBroadcast {
  /// Get the channels the event should broadcast on.
  ///
  /// Example:
  /// ```dart
  /// class OrderShippedEvent implements ShouldBroadcast {
  ///   final int orderId;
  ///
  ///   OrderShippedEvent(this.orderId);
  ///
  ///   @override
  ///   dynamic broadcastOn() {
  ///     // Return a single channel
  ///     return 'orders.$orderId';
  ///
  ///     // Or return multiple channels
  ///     return [
  ///       'orders.$orderId',
  ///       'admin.orders',
  ///     ];
  ///   }
  /// }
  /// ```
  dynamic broadcastOn();
}
