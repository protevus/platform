import 'dart:async';
import 'dart:convert';

import 'package:illuminate_contracts/contracts.dart';
import '../contracts/session_driver.dart';

/// A session driver that stores sessions using the cache system.
class CacheSessionDriver implements SessionDriver {
  final CacheStore _cache;
  final String _prefix;
  final JsonCodec _json;

  /// Creates a new cache session driver.
  ///
  /// The [cache] parameter is the cache store to use for storage.
  /// The [prefix] parameter is prepended to all cache keys (defaults to 'session:').
  CacheSessionDriver(
    this._cache, {
    String prefix = 'session:',
    JsonCodec? json,
  })  : _prefix = prefix,
        _json = json ?? const JsonCodec();

  String _key(String id) => '$_prefix$id';

  @override
  Future<Map<String, dynamic>?> read(String id) async {
    final data = await _cache.get(_key(id));
    if (data == null) {
      return null;
    }

    try {
      return _json.decode(data.toString()) as Map<String, dynamic>;
    } catch (_) {
      await destroy(id);
      return null;
    }
  }

  @override
  Future<void> write(String id, Map<String, dynamic> data) async {
    await _cache.put(
      _key(id),
      _json.encode(data),
      7200, // 2 hours in seconds
    );
  }

  @override
  Future<void> destroy(String id) async {
    await _cache.forget(_key(id));
  }

  @override
  Future<List<String>> all() async {
    final prefix = _cache.getPrefix() + _prefix;
    final keys = await _cache.many([prefix + '*']);
    return keys.keys
        .where((key) => key.startsWith(prefix))
        .map((key) => key.substring(prefix.length))
        .toList(growable: false);
  }

  @override
  Future<void> gc(Duration lifetime) async {
    // Cache system handles expiration automatically
  }
}
