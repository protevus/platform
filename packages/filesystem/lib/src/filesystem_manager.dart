import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_macroable/macroable.dart';
import 'package:illuminate_conditionable/conditionable.dart';

import 'filesystem.dart';
import 'filesystem_adapter.dart';

/// The FilesystemManager manages the filesystem configuration and creates the appropriate
/// filesystem driver instances.
class FilesystemManager with Macroable, Conditionable {
  /// The array of registered filesystem drivers.
  final Map<String, Function> _customCreators = {};

  /// The array of filesystem connections.
  final Map<String, CloudFilesystemContract> _disks = {};

  /// The default filesystem disk.
  final String _defaultDisk;

  /// The filesystem configuration.
  final Map<String, dynamic> _config;

  /// Create a new filesystem manager instance.
  FilesystemManager(this._config, [String? defaultDisk])
      : _defaultDisk = defaultDisk ?? _config['default'] ?? 'local';

  /// Get a filesystem instance.
  ///
  /// @param name The name of the disk
  /// @return The filesystem instance
  CloudFilesystemContract disk([String? name]) {
    name = name ?? _defaultDisk;

    return _disks[name] ??= _get(name);
  }

  /// Get the default driver name.
  String getDefaultDriver() => _defaultDisk;

  /// Get the driver configuration.
  Map<String, dynamic> getConfig([String? name]) {
    name = name ?? _defaultDisk;
    return _config['disks'][name] ?? {};
  }

  /// Register a custom driver creator Closure.
  void extend(String driver, Function callback) {
    _customCreators[driver] = callback;
  }

  /// Create an instance of the local driver.
  CloudFilesystemContract _createLocalDriver(Map<String, dynamic> config) {
    return FilesystemAdapter(
      Filesystem(),
      null,
      config,
    );
  }

  /// Create a new filesystem instance.
  CloudFilesystemContract _get(String name) {
    final config = getConfig(name);
    final driver = config['driver'] ?? '';

    if (_customCreators.containsKey(driver)) {
      return _customCreators[driver]!(config);
    }

    switch (driver) {
      case 'local':
        return _createLocalDriver(config);
      default:
        throw UnsupportedError('Driver [$driver] is not supported.');
    }
  }
}
