/// Interface for entities that have associated broadcast channels.
///
/// This contract defines how entities should specify their broadcast channel
/// route definitions and names. It's typically implemented by models that
/// need to be associated with specific broadcast channels.
abstract class HasBroadcastChannel {
  /// Get the broadcast channel route definition associated with the entity.
  ///
  /// Example:
  /// ```dart
  /// class Order implements HasBroadcastChannel {
  ///   final int id;
  ///
  ///   Order(this.id);
  ///
  ///   @override
  ///   String broadcastChannelRoute() {
  ///     return 'orders.{order}';
  ///   }
  /// }
  /// ```
  String broadcastChannelRoute();

  /// Get the broadcast channel name associated with the entity.
  ///
  /// Example:
  /// ```dart
  /// class Order implements HasBroadcastChannel {
  ///   final int id;
  ///
  ///   Order(this.id);
  ///
  ///   @override
  ///   String broadcastChannel() {
  ///     return 'orders.$id';
  ///   }
  /// }
  /// ```
  String broadcastChannel();
}
