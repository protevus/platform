import '../cache/cache_driver_interface.dart';

class CacheConfig {
  final String defaultDriver;
  final Map<String, CacheDriverInterface> drivers;

  const CacheConfig({
    this.defaultDriver = 'file',
    this.drivers = const <String, CacheDriverInterface>{},
  });
}
