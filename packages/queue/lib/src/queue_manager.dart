import 'package:queue/src/contracts/queue.dart';
import 'package:queue/src/drivers/redis_queue.dart';
import 'package:queue/src/exceptions/queue_connection_exception.dart';

/// Manager for queue connections and drivers.
class QueueManager {
  /// The registered queue driver factories.
  final Map<String, Queue Function(Map<String, dynamic>)> _drivers = {};

  /// The active queue connections.
  final Map<String, Queue> _connections = {};

  /// The default queue connection name.
  String _defaultConnection = 'default';

  /// Register a new queue driver.
  void registerDriver(
    String driver,
    Queue Function(Map<String, dynamic>) callback,
  ) {
    _drivers[driver] = callback;
  }

  /// Register the default queue drivers.
  void registerDefaultDrivers() {
    registerDriver('redis', (config) {
      final redis = config['connection'];
      if (redis == null) {
        throw QueueConnectionException(
          'Redis connection not configured.',
        );
      }

      return RedisQueue(
        redis: redis,
        defaultQueue: config['queue'] as String? ?? 'default',
        retryAfter: config['retry_after'] as int? ?? 60,
        blockFor: config['block_for'] as int?,
      );
    });

    // TODO: Register other drivers (database, sqs, etc.)
  }

  /// Get a queue connection instance.
  Queue connection([String? name]) {
    name ??= _defaultConnection;

    if (_connections.containsKey(name)) {
      return _connections[name]!;
    }

    return _connections[name] = _resolve(name);
  }

  /// Resolve a queue connection.
  Queue _resolve(String name) {
    final config = _getConfig(name);
    final driver = config['driver'] as String?;

    if (driver == null || !_drivers.containsKey(driver)) {
      throw QueueConnectionException(
        'Driver [$driver] not supported.',
      );
    }

    return _drivers[driver]!(config);
  }

  /// Get the configuration for a queue connection.
  Map<String, dynamic> _getConfig(String name) {
    // TODO: Implement configuration loading
    // This would typically come from a configuration file or service
    return {
      'driver': 'redis',
      'connection': null,
      'queue': 'default',
      'retry_after': 60,
      'block_for': null,
    };
  }

  /// Get the default queue connection name.
  String get defaultConnection => _defaultConnection;

  /// Set the default queue connection name.
  set defaultConnection(String name) {
    _defaultConnection = name;
  }

  /// Get all of the created queue connections.
  Map<String, Queue> get connections => Map.unmodifiable(_connections);
}
