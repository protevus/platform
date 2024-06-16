import 'dart:async';

abstract class Connection {
  /// Subscribe to a set of given channels for messages.
  ///
  /// @param  List<String> channels
  /// @param  void Function(dynamic) callback
  /// @return void
  void subscribe(List<String> channels, void Function(dynamic) callback);

  /// Subscribe to a set of given channels with wildcards.
  ///
  /// @param  List<String> channels
  /// @param  void Function(dynamic) callback
  /// @return void
  void psubscribe(List<String> channels, void Function(dynamic) callback);

  /// Run a command against the Redis database.
  ///
  /// @param  String method
  /// @param  List<dynamic> parameters
  /// @return Future<dynamic>
  Future<dynamic> command(String method, [List<dynamic> parameters = const []]);
}
