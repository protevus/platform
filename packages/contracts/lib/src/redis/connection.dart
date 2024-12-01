/// Interface for Redis connections.
abstract class Connection {
  /// Subscribe to a set of given channels for messages.
  void subscribe(dynamic channels, Function callback);

  /// Subscribe to a set of given channels with wildcards.
  void psubscribe(dynamic channels, Function callback);

  /// Run a command against the Redis database.
  dynamic command(String method, [List<dynamic> parameters = const []]);
}
