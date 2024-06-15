import 'package:meta/meta.dart';
import 'package:psr/simple_cache.dart';
import 'dart:async';

// TODO: Find dart replacements for missing imports.

abstract class Repository implements CacheInterface {
  /// Retrieve an item from the cache and delete it.
  ///
  /// @template TCacheValue
  ///
  /// @param  List<String>|String  key
  /// @param  TCacheValue|Future<TCacheValue> Function()  default
  /// @return  Future<TCacheValue>
  Future<dynamic> pull(dynamic key, [dynamic defaultValue]);

  /// Store an item in the cache.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  DateTime|Duration|int|null  ttl
  /// @return Future<bool>
  Future<bool> put(String key, dynamic value, [dynamic ttl]);

  /// Store an item in the cache if the key does not exist.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  DateTime|Duration|int|null  ttl
  /// @return Future<bool>
  Future<bool> add(String key, dynamic value, [dynamic ttl]);

  /// Increment the value of an item in the cache.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return Future<int|bool>
  Future<dynamic> increment(String key, [int value = 1]);

  /// Decrement the value of an item in the cache.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return Future<int|bool>
  Future<dynamic> decrement(String key, [int value = 1]);

  /// Store an item in the cache indefinitely.
  ///
  /// @param  String  key
  /// @param  dynamic  value
  /// @return Future<bool>
  Future<bool> forever(String key, dynamic value);

  /// Get an item from the cache, or execute the given Closure and store the result.
  ///
  /// @template TCacheValue
  ///
  /// @param  String  key
  /// @param  DateTime|Duration|Future<TCacheValue> Function()|int|null  ttl
  /// @param  Future<TCacheValue> Function()  callback
  /// @return Future<TCacheValue>
  Future<dynamic> remember(String key, dynamic ttl, Future<dynamic> Function() callback);

  /// Get an item from the cache, or execute the given Closure and store the result forever.
  ///
  /// @template TCacheValue
  ///
  /// @param  String  key
  /// @param  Future<TCacheValue> Function()  callback
  /// @return Future<TCacheValue>
  Future<dynamic> sear(String key, Future<dynamic> Function() callback);

  /// Get an item from the cache, or execute the given Closure and store the result forever.
  ///
  /// @template TCacheValue
  ///
  /// @param  String  key
  /// @param  Future<TCacheValue> Function()  callback
  /// @return Future<TCacheValue>
  Future<dynamic> rememberForever(String key, Future<dynamic> Function() callback);

  /// Remove an item from the cache.
  ///
  /// @param  String  key
  /// @return Future<bool>
  Future<bool> forget(String key);

  /// Get the cache store implementation.
  ///
  /// @return CacheStore
  CacheStore getStore();
}

abstract class CacheStore {
  // Define methods that a CacheStore should have.
}
