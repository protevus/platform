/// Represents a broadcast notification message.
class BroadcastMessage {
  /// The data to broadcast.
  final Map<String, dynamic> _data;

  /// The queue connection that should be used.
  String? connection;

  /// The queue that should be used.
  String? queue;

  /// Creates a new broadcast message instance.
  ///
  /// [data] The data to broadcast
  BroadcastMessage(Map<String, dynamic> data) : _data = Map.from(data);

  /// Get the message data.
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  /// Set the queue connection for the broadcast.
  ///
  /// Returns this instance for method chaining.
  BroadcastMessage onConnection(String connection) {
    this.connection = connection;
    return this;
  }

  /// Set the queue name for the broadcast.
  ///
  /// Returns this instance for method chaining.
  BroadcastMessage onQueue(String queue) {
    this.queue = queue;
    return this;
  }
}
