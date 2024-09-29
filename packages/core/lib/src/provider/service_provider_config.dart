import 'package:platform_core/core.dart';
import 'package:platform_core/src/provider/service_provider.dart';

class ServiceProviderConfig {
  final List<Type> providers;
  final Map<Type, bool> deferredProviders;
  final Map<Type, Map<String, dynamic>> providerConfigs;

  ServiceProviderConfig({
    required this.providers,
    this.deferredProviders = const {},
    this.providerConfigs = const {},
  });

  factory ServiceProviderConfig.fromMap(Map<String, dynamic> map) {
    final providersList =
        (map['providers'] as List<dynamic>).cast<Map<String, dynamic>>();

    final providers = <Type>[];
    final deferredProviders = <Type, bool>{};
    final providerConfigs = <Type, Map<String, dynamic>>{};

    for (var providerMap in providersList) {
      final type = _getTypeFromString(providerMap['type'] as String);
      providers.add(type);

      if (providerMap['deferred'] == true) {
        deferredProviders[type] = true;
      }

      if (providerMap['config'] != null) {
        providerConfigs[type] = (providerMap['config'] as Map<String, dynamic>);
      }
    }

    return ServiceProviderConfig(
      providers: providers,
      deferredProviders: deferredProviders,
      providerConfigs: providerConfigs,
    );
  }

  static Type _getTypeFromString(String typeName) {
    // This is a simple implementation. You might need to expand this
    // to cover all your service provider types.
    switch (typeName) {
      case 'TestServiceProvider':
        return TestServiceProvider;
      case 'AnotherServiceProvider':
        return AnotherServiceProvider;
      // Add cases for all your service provider types
      default:
        throw UnimplementedError(
            'Type $typeName is not implemented in _getTypeFromString');
    }
  }
}

// Example service provider classes (you should replace these with your actual service providers)
class TestServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Implementation
  }

  @override
  Future<void> boot() async {
    // Implementation
  }
}

class AnotherServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Implementation
  }

  @override
  Future<void> boot() async {
    // Implementation
  }
}
