import 'package:illuminate_foundation/cache/drivers/file/file_cache_driver.dart';
import 'package:illuminate_foundation/dox_core.dart';

CacheConfig cache = CacheConfig(
  /// default cache driver
  defaultDriver: Env.get('CACHE_DRIVER', 'file'),

  /// register cache driver list
  drivers: <String, CacheDriverInterface>{
    'file': FileCacheDriver(),
  },
);
