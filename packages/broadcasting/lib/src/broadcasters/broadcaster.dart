import 'dart:async';

import '../channels/channel.dart';

/// Interface for implementing broadcasting drivers.
///
/// This interface defines the contract that all broadcaster implementations must follow.
/// It provides methods for authentication, channel management, and event broadcasting.
abstract class Broadcaster {
  /// Authenticates the incoming request for a given channel.
  ///
  /// This method is called when a client attempts to subscribe to a private or
  /// presence channel. It should validate the authentication credentials and
  /// return appropriate authentication response data.
  ///
  /// Parameters:
  /// - [channelName]: The name of the channel being subscribed to
  /// - [socketId]: The unique identifier of the client socket
  /// - [auth]: Optional authentication data provided by the client
  Future<Map<String, dynamic>> auth(
    String channelName,
    String socketId, {
    Map<String, dynamic>? auth,
  });

  /// Validates the incoming webhook request.
  ///
  /// This method is used to verify that webhook requests are coming from
  /// the broadcasting service and haven't been tampered with.
  ///
  /// Parameters:
  /// - [headers]: The headers from the webhook request
  /// - [payload]: The raw payload from the webhook request
  Future<bool> validateWebhook(
    Map<String, String> headers,
    String payload,
  );

  /// Broadcasts an event to specified channels.
  ///
  /// This method sends an event with the given name and data to all specified channels.
  ///
  /// Parameters:
  /// - [channels]: List of channels to broadcast to
  /// - [event]: Name of the event
  /// - [data]: Data to be broadcasted
  /// - [socketId]: Optional socket ID to exclude from broadcast (for echo control)
  Future<void> broadcast(
    List<Channel> channels,
    String event,
    Map<String, dynamic> data, {
    String? socketId,
  });

  /// Broadcasts an event to a single channel.
  ///
  /// Convenience method for broadcasting to a single channel.
  ///
  /// Parameters:
  /// - [channel]: The channel to broadcast to
  /// - [event]: Name of the event
  /// - [data]: Data to be broadcasted
  /// - [socketId]: Optional socket ID to exclude from broadcast
  Future<void> broadcastTo(
    Channel channel,
    String event,
    Map<String, dynamic> data, {
    String? socketId,
  }) {
    return broadcast([channel], event, data, socketId: socketId);
  }

  /// Gets the socket ID for the current request.
  ///
  /// This method should extract and return the socket ID from the current request
  /// context, if available.
  String? getSocketId();

  /// Registers a callback for channel authentication.
  ///
  /// The callback will be used to determine if a user has access to a given channel.
  ///
  /// Parameters:
  /// - [pattern]: The channel pattern to match (supports wildcards)
  /// - [callback]: Function that determines if access should be granted
  void registerAuthCallback(
    String pattern,
    FutureOr<bool> Function(String channelName, Map<String, dynamic>? auth)
        callback,
  );

  /// Registers a callback for presence channel authentication.
  ///
  /// Similar to [registerAuthCallback] but specifically for presence channels,
  /// allowing additional user information to be provided.
  ///
  /// Parameters:
  /// - [pattern]: The channel pattern to match (supports wildcards)
  /// - [callback]: Function that returns user data if access should be granted
  void registerPresenceAuthCallback(
    String pattern,
    FutureOr<Map<String, dynamic>?> Function(
      String channelName,
      Map<String, dynamic>? auth,
    ) callback,
  );
}
