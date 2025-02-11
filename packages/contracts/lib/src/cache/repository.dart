// import 'package:dsr_simple_cache/simple_cache.dart';
// import 'store.dart';

// /// Interface for cache operations.
// ///
// /// This contract extends the DSR-16 CacheInterface to add additional
// /// functionality specific to Laravel's caching system.
// abstract class CacheRepository extends CacheInterface {
//   /// Retrieve an item from the cache and delete it.
//   ///
//   /// Example:
//   /// ```dart
//   /// var value = await cache.pull('key', defaultValue: 'default');
//   /// ```
//   Future<T> pull<T>(String key, {T? defaultValue});

//   /// Store an item in the cache.
//   ///
//   /// Example:
//   /// ```dart
//   /// await cache.put('key', 'value', ttl: Duration(minutes: 10));
//   /// ```
//   Future<bool> put(String key, dynamic value, {Duration? ttl});

//   /// Store an item in the cache if the key does not exist.
//   ///
//   /// Example:
//   /// ```dart
//   /// var added = await cache.add('key', 'value', ttl: Duration(minutes: 10));
//   /// ```
//   Future<bool> add(String key, dynamic value, {Duration? ttl});

//   /// Increment the value of an item in the cache.
//   ///
//   /// Example:
//   /// ```dart
//   /// var newValue = await cache.increment('visits');
//   /// ```
//   Future<int?> increment(String key, [int value = 1]);

//   /// Decrement the value of an item in the cache.
//   ///
//   /// Example:
//   /// ```dart
//   /// var newValue = await cache.decrement('remaining');
//   /// ```
//   Future<int?> decrement(String key, [int value = 1]);

//   /// Store an item in the cache indefinitely.
//   ///
//   /// Example:
//   /// ```dart
//   /// await cache.forever('key', 'value');
//   /// ```
//   Future<bool> forever(String key, dynamic value);

//   /// Get an item from the cache, or execute the callback and store the result.
//   ///
//   /// Example:
//   /// ```dart
//   /// var value = await cache.remember<String>(
//   ///   'key',
//   ///   Duration(minutes: 10),
//   ///   () async => await computeValue(),
//   /// );
//   /// ```
//   Future<T> remember<T>(
//     String key,
//     Duration? ttl,
//     Future<T> Function() callback,
//   );

//   /// Get an item from the cache, or execute the callback and store the result forever.
//   ///
//   /// Example:
//   /// ```dart
//   /// var value = await cache.sear<String>(
//   ///   'key',
//   ///   () async => await computeValue(),
//   /// );
//   /// ```
//   Future<T> sear<T>(String key, Future<T> Function() callback);

//   /// Get an item from the cache, or execute the callback and store the result forever.
//   ///
//   /// Example:
//   /// ```dart
//   /// var value = await cache.rememberForever<String>(
//   ///   'key',
//   ///   () async => await computeValue(),
//   /// );
//   /// ```
//   Future<T> rememberForever<T>(String key, Future<T> Function() callback);

//   /// Remove an item from the cache.
//   ///
//   /// Example:
//   /// ```dart
//   /// await cache.forget('key');
//   /// ```
//   Future<bool> forget(String key);

//   /// Get the cache store implementation.
//   ///
//   /// Example:
//   /// ```dart
//   /// var store = cache.getStore();
//   /// ```
//   CacheStore getStore();
// }
