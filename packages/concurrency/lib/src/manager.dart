import 'dart:async';

import 'package:meta/meta.dart';

import 'driver.dart';
import 'drivers/isolate_driver.dart';
import 'drivers/process_driver.dart';
import 'drivers/sync_driver.dart';

/// Manager class for handling different concurrency drivers.
class ConcurrencyManager implements Driver {
  final Map<String, Driver> _drivers = {};
  final Map<String, FutureOr<Driver> Function()> _factories = {};
  String _defaultDriver = 'isolate';

  /// Creates a new concurrency manager instance.
  ConcurrencyManager() {
    // Register default drivers
    registerDriver('isolate', () => IsolateDriver());
    registerDriver('process', () => ProcessDriver());
    registerDriver('sync', () => SyncDriver());
  }

  /// Registers a new driver factory.
  @visibleForTesting
  void registerDriver(String name, FutureOr<Driver> Function() factory) {
    _factories[name] = factory;
  }

  /// Sets the default driver name.
  void setDefaultDriver(String name) {
    if (!_factories.containsKey(name)) {
      throw ConcurrencyException('Driver "$name" is not registered');
    }
    _defaultDriver = name;
  }

  /// Gets a driver instance by name.
  Future<Driver> driver([String? name]) async {
    name ??= _defaultDriver;

    // Return cached instance if available
    if (_drivers.containsKey(name)) {
      return _drivers[name]!;
    }

    // Get factory
    final factory = _factories[name];
    if (factory == null) {
      throw ConcurrencyException('Driver "$name" is not registered');
    }

    // Create and cache new instance
    final driver = await factory();
    _drivers[name] = driver;
    return driver;
  }

  @override
  Future<List<T>> run<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    return (await driver()).run(task, times: times);
  }

  @override
  Future<List<T>> runAll<T>(List<FutureOr<T> Function()> tasks) async {
    return (await driver()).runAll(tasks);
  }

  @override
  Future<void> defer<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    return (await driver()).defer(task, times: times);
  }

  @override
  Future<void> deferAll<T>(List<FutureOr<T> Function()> tasks) async {
    return (await driver()).deferAll(tasks);
  }
}
