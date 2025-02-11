/// Interface for broadcasts that should be unique.
///
/// This contract serves as a marker interface for broadcasts that should
/// be unique. While it doesn't define any methods, implementing this interface
/// signals that the broadcast should be unique and any duplicate broadcasts
/// should be prevented.
///
/// Example:
/// ```dart
/// class OrderShippedEvent implements ShouldBroadcast, ShouldBeUnique {
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
abstract class ShouldBeUnique {}
