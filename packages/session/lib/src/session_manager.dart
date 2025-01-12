import 'dart:async';

import 'package:platform_container/container.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_dbo/dbo.dart';
import 'package:uuid/uuid.dart';

import 'config/session_config.dart';
import 'contracts/session_driver.dart';
import 'drivers/array_session_driver.dart';
import 'drivers/cache_session_driver.dart';
import 'drivers/database_session_driver.dart';
import 'drivers/file_session_driver.dart';
import 'drivers/redis_session_driver.dart';
import 'session_store.dart';

/// Manages session drivers and handles session creation.
class SessionManager {
  final Map<String, SessionDriver> _drivers = {};
  final Map<String, SessionStore> _sessions = {};
  final SessionConfig _config;
  final Container _container;
  final _uuid = const Uuid();

  /// Creates a new session manager.
  SessionManager(this._config, this._container);

  /// Gets a session store for the given ID.
  SessionStore? getSession(String id) => _sessions[id];

  /// Creates a new session store.
  Future<SessionStore> createSession([String? id]) async {
    id ??= _uuid.v4();
    final driver = await _getDriver(_config.driver);
    final store = SessionStore(
      id,
      driver,
      encrypt: _config.encrypt,
      encrypter: _config.encrypt ? _container.make<EncrypterContract>() : null,
    );
    _sessions[id] = store;
    return store;
  }

  /// Registers a custom session driver.
  void extend(String driver, SessionDriver Function() callback) {
    _drivers[driver] = callback();
  }

  /// Gets or creates a session driver.
  Future<SessionDriver> _getDriver(String name) async {
    if (_drivers.containsKey(name)) {
      return _drivers[name]!;
    }

    switch (name) {
      case 'array':
        return _drivers[name] = ArraySessionDriver();
      case 'cache':
        return _drivers[name] =
            CacheSessionDriver(_container.make<CacheStore>());
      case 'database':
        return _drivers[name] = DatabaseSessionDriver(_container.make<DBO>());
      case 'file':
        return _drivers[name] = FileSessionDriver();
      // case 'redis':
      //   return _drivers[name] =
      //       RedisSessionDriver(_container.make<Connection>());
      default:
        throw UnsupportedError('Session driver [$name] is not supported.');
    }
  }

  /// Removes expired sessions.
  Future<void> gc() async {
    final lifetime = Duration(minutes: _config.lifetime);
    for (var driver in _drivers.values) {
      await driver.gc(lifetime);
    }
    _sessions.removeWhere((_, store) => !store.isStarted);
  }
}
