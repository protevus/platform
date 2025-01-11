import 'dart:async';

import 'broadcasters/broadcaster.dart';
import 'channels/channel.dart';
import 'exceptions/broadcast_exception.dart';

/// Manages broadcasting configuration and driver instances.
///
/// The BroadcastManager provides a centralized way to manage different broadcasting
/// drivers and handle event broadcasting. It supports multiple driver implementations
/// and provides a consistent API for broadcasting events.
class BroadcastManager {
  /// Map of registered broadcasting drivers.
  final Map<String, Broadcaster> _drivers = {};

  /// Map of registered driver factories.
  final Map<String, FutureOr<Broadcaster> Function(Map<String, dynamic>)>
      _factories = {};

  /// The default driver name.
  String _defaultDriver = 'null';

  /// Gets the default broadcasting driver name.
  String get defaultDriver => _defaultDriver;

  /// Sets the default broadcasting driver name.
  set defaultDriver(String name) {
    if (!_factories.containsKey(name)) {
      throw BroadcastException('Driver "$name" is not registered.');
    }
    _defaultDriver = name;
  }

  /// Registers a new broadcasting driver factory.
  ///
  /// Parameters:
  /// - [name]: The name of the driver
  /// - [factory]: A function that creates a new instance of the driver
  /// - [config]: Optional configuration for the driver
  Future<void> registerDriver(
    String name,
    FutureOr<Broadcaster> Function(Map<String, dynamic>) factory, {
    Map<String, dynamic>? config,
  }) async {
    _factories[name] = factory;
    if (config != null) {
      await createDriver(name, config);
    }
  }

  /// Creates a new instance of a broadcasting driver.
  ///
  /// Parameters:
  /// - [name]: The name of the driver to create
  /// - [config]: Configuration options for the driver
  Future<Broadcaster> createDriver(
      String name, Map<String, dynamic> config) async {
    if (!_factories.containsKey(name)) {
      throw BroadcastException('Driver "$name" is not registered.');
    }

    final driver = await _factories[name]!(config);
    _drivers[name] = driver;
    return driver;
  }

  /// Gets a broadcasting driver instance.
  ///
  /// Parameters:
  /// - [name]: Optional name of the driver to get. If not provided, uses the default driver.
  Future<Broadcaster> driver([String? name]) async {
    name ??= _defaultDriver;
    final driver = _drivers[name];
    if (driver == null) {
      throw BroadcastException('Driver "$name" has not been created.');
    }
    return driver;
  }

  /// Begins broadcasting an event to specified channels.
  ///
  /// This is the main entry point for broadcasting events. It handles both
  /// immediate broadcasting and queueing of events.
  ///
  /// Parameters:
  /// - [channels]: The channels to broadcast to
  /// - [event]: The name of the event
  /// - [data]: The data to broadcast
  /// - [socket]: Optional socket ID to exclude
  /// - [driver]: Optional specific driver to use
  Future<void> broadcast(
    List<Channel> channels,
    String event,
    Map<String, dynamic> data, {
    String? socket,
    String? driver,
  }) async {
    final broadcaster = await this.driver(driver);
    await broadcaster.broadcast(channels, event, data, socketId: socket);
  }

  /// Begins broadcasting an event to a single channel.
  ///
  /// Convenience method for broadcasting to a single channel.
  ///
  /// Parameters:
  /// - [channel]: The channel to broadcast to
  /// - [event]: The name of the event
  /// - [data]: The data to broadcast
  /// - [socket]: Optional socket ID to exclude
  /// - [driver]: Optional specific driver to use
  Future<void> broadcastTo(
    Channel channel,
    String event,
    Map<String, dynamic> data, {
    String? socket,
    String? driver,
  }) {
    return broadcast([channel], event, data, socket: socket, driver: driver);
  }

  /// Creates a new private channel instance.
  ///
  /// Parameters:
  /// - [name]: The name of the channel
  PrivateChannel private(String name) => PrivateChannel(name);

  /// Creates a new presence channel instance.
  ///
  /// Parameters:
  /// - [name]: The name of the channel
  PresenceChannel presence(String name) => PresenceChannel(name);

  /// Creates a new encrypted private channel instance.
  ///
  /// Parameters:
  /// - [name]: The name of the channel
  EncryptedPrivateChannel encrypted(String name) =>
      EncryptedPrivateChannel(name);

  /// Removes a driver instance.
  ///
  /// Parameters:
  /// - [name]: The name of the driver to remove
  void removeDriver(String name) {
    _drivers.remove(name);
  }

  /// Removes all driver instances.
  void clearDrivers() {
    _drivers.clear();
  }
}
