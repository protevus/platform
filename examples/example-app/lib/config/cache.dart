import 'package:illuminate_cache/cache.dart';
import 'package:illuminate_config/config.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';

CacheConfig cache = CacheConfig(
  /// default cache driver
  defaultDriver: Env.get('CACHE_DRIVER', 'file'),

  /// register cache driver list
  drivers: <String, CacheDriverInterface>{
    'file': FileCacheDriver(),
  },
);
