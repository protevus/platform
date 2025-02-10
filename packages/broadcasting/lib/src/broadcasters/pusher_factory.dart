import 'package:pusher_client/pusher_client.dart' as pusher;

import 'pusher_broadcaster.dart';

/// Factory for creating Pusher broadcaster instances.
class PusherFactory {
  /// Creates a new Pusher broadcaster instance with the given configuration.
  ///
  /// Parameters:
  /// - [key]: The Pusher application key
  /// - [secret]: The Pusher application secret
  /// - [cluster]: The Pusher cluster (e.g., 'us2', 'eu', 'ap1')
  /// - [encrypted]: Whether to use TLS encryption (defaults to true)
  /// - [host]: Optional custom host
  /// - [port]: Optional custom port
  /// - [maxReconnectionAttempts]: Maximum number of reconnection attempts
  /// - [autoConnect]: Whether to connect automatically (defaults to true)
  static Future<PusherBroadcaster> create({
    required String key,
    required String secret,
    required String cluster,
    bool encrypted = true,
    String? host,
    int? port,
    int maxReconnectionAttempts = 6,
    bool autoConnect = true,
  }) async {
    final options = pusher.PusherOptions(
      cluster: cluster,
      encrypted: encrypted,
      host: host,
      wsPort: port,
      maxReconnectionAttempts: maxReconnectionAttempts,
    );

    final client = pusher.PusherClient(
      key,
      options,
      autoConnect: autoConnect,
      enableLogging: true,
    );

    // Wait for connection to be established if autoConnect is true
    if (autoConnect) {
      await client.connect();
    }

    return PusherBroadcaster(client, key, secret);
  }

  /// Creates a new Pusher broadcaster instance for local development.
  ///
  /// This is a convenience method that creates a broadcaster configured
  /// for local development with common defaults.
  ///
  /// Parameters:
  /// - [key]: The Pusher application key
  /// - [secret]: The Pusher application secret
  /// - [host]: The local host (defaults to 'localhost')
  /// - [port]: The local port (defaults to 6001)
  static Future<PusherBroadcaster> createLocal({
    required String key,
    required String secret,
    String host = 'localhost',
    int port = 6001,
  }) {
    return create(
      key: key,
      secret: secret,
      cluster: 'local',
      host: host,
      port: port,
      encrypted: false,
    );
  }
}
