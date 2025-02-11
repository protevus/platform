// import 'dart:async';
// import 'dart:convert';

// import 'package:platform_redis/angel3_redis.dart';
// import '../contracts/session_driver.dart';

// /// A session driver that stores sessions in Redis.
// class RedisSessionDriver implements SessionDriver {
//   final Redis _redis;
//   final String _prefix;
//   final JsonCodec _json;

//   /// Creates a new Redis session driver.
//   ///
//   /// The [redis] parameter is the Redis connection to use.
//   /// The [prefix] parameter is prepended to all Redis keys (defaults to 'session:').
//   RedisSessionDriver(
//     this._redis, {
//     String prefix = 'session:',
//     JsonCodec? json,
//   })  : _prefix = prefix,
//         _json = json ?? const JsonCodec();

//   String _key(String id) => '$_prefix$id';

//   @override
//   Future<Map<String, dynamic>?> read(String id) async {
//     final data = await _redis.get(_key(id));
//     if (data == null) {
//       return null;
//     }

//     try {
//       return _json.decode(data) as Map<String, dynamic>;
//     } catch (_) {
//       await destroy(id);
//       return null;
//     }
//   }

//   @override
//   Future<void> write(String id, Map<String, dynamic> data) async {
//     final key = _key(id);
//     await _redis.setex(
//       key,
//       Duration(hours: 2),
//       _json.encode(data),
//     );
//   }

//   @override
//   Future<void> destroy(String id) async {
//     await _redis.del(_key(id));
//   }

//   @override
//   Future<List<String>> all() async {
//     final keys = await _redis.keys('$_prefix*');
//     return keys
//         .map((key) => key.substring(_prefix.length))
//         .toList(growable: false);
//   }

//   @override
//   Future<void> gc(Duration lifetime) async {
//     // Redis handles expiration automatically through TTL
//   }
// }
