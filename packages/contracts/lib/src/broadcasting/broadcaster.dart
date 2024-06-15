//import 'package:some_http_package/some_http_package.dart'; // Replace with actual HTTP package

abstract class Broadcaster {
  /// Authenticate the incoming request for a given channel.
  ///
  /// @param  Request  request
  /// @return mixed
  Future<dynamic> auth(Request request);

  /// Return the valid authentication response.
  ///
  /// @param  Request  request
  /// @param  mixed  result
  /// @return mixed
  Future<dynamic> validAuthenticationResponse(Request request, dynamic result);

  /// Broadcast the given event.
  ///
  /// @param  List<String>  channels
  /// @param  String  event
  /// @param  Map<String, dynamic>  payload
  /// @return void
  ///
  /// @throws BroadcastException
  Future<void> broadcast(List<String> channels, String event, {Map<String, dynamic> payload = const {}});
}

class BroadcastException implements Exception {
  final String message;
  BroadcastException(this.message);
  
  @override
  String toString() => 'BroadcastException: $message';
}

// TODO: Find dart library to replace symfony for Request Class.