import '../http/request.dart';
import 'broadcast_exception.dart';

/// Interface for broadcasting functionality.
///
/// This contract defines how broadcasting should be handled,
/// providing methods for authentication and event broadcasting.
abstract class Broadcaster {
  /// Authenticate the incoming request for a given channel.
  ///
  /// Example:
  /// ```dart
  /// var result = await broadcaster.auth(request);
  /// if (result != null) {
  ///   // Request is authenticated
  /// }
  /// ```
  Future<dynamic> auth(Request request);

  /// Return the valid authentication response.
  ///
  /// Example:
  /// ```dart
  /// var response = await broadcaster.validAuthenticationResponse(
  ///   request,
  ///   authResult,
  /// );
  /// ```
  Future<dynamic> validAuthenticationResponse(Request request, dynamic result);

  /// Broadcast the given event.
  ///
  /// Example:
  /// ```dart
  /// await broadcaster.broadcast(
  ///   ['private-orders.1', 'private-orders.2'],
  ///   'OrderShipped',
  ///   {'orderId': 1},
  /// );
  /// ```
  ///
  /// Throws a [BroadcastException] if broadcasting fails.
  Future<void> broadcast(
    List<String> channels,
    String event, [
    Map<String, dynamic> payload = const {},
  ]);
}
