# Config Package Specification

## Overview

The Config package provides a flexible configuration management system that matches Laravel's config functionality. It integrates with our Container and Package systems while supporting hierarchical configuration, environment-based settings, and caching.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Contracts Package Specification](contracts_package_specification.md) for config contracts

## Core Features

### 1. Configuration Repository

```dart
/// Core configuration repository
class ConfigRepository implements ConfigContract {
  final Container _container;
  final Map<String, dynamic> _items;
  final EnvironmentLoader _env;
  final ConfigCache? _cache;
  
  ConfigRepository(
    this._container, [
    Map<String, dynamic>? items,
    EnvironmentLoader? env,
    ConfigCache? cache
  ]) : _items = items ?? {},
       _env = env ?? EnvironmentLoader(),
       _cache = cache;
  
  @override
  T? get<T>(String key, [T? defaultValue]) {
    var value = _getNestedValue(key);
    if (value == null) {
      return defaultValue;
    }
    return _cast<T>(value);
  }
  
  @override
  void set(String key, dynamic value) {
    _setNestedValue(key, value);
    _cache?.clear();
  }
  
  @override
  bool has(String key) {
    return _getNestedValue(key) != null;
  }
  
  /// Gets all configuration items
  Map<String, dynamic> all() => Map.from(_items);
  
  /// Merges configuration values
  void merge(Map<String, dynamic> items) {
    _items.addAll(_deepMerge(_items, items));
    _cache?.clear();
  }
  
  /// Deep merges two maps
  Map<String, dynamic> _deepMerge(
    Map<String, dynamic> target,
    Map<String, dynamic> source
  ) {
    source.forEach((key, value) {
      if (value is Map && target[key] is Map) {
        target[key] = _deepMerge(
          target[key] as Map<String, dynamic>,
          value as Map<String, dynamic>
        );
      } else {
        target[key] = value;
      }
    });
    return target;
  }
  
  /// Casts a value to the requested type
  T _cast<T>(dynamic value) {
    if (value is T) return value;
    
    // Handle common type conversions
    if (T == bool) {
      if (value is String) {
        return (value.toLowerCase() == 'true') as T;
      }
      return (value == 1) as T;
    }
    
    if (T == int && value is String) {
      return int.parse(value) as T;
    }
    
    if (T == double && value is String) {
      return double.parse(value) as T;
    }
    
    throw ConfigCastException(
      'Cannot cast $value to $T'
    );
  }
}
```

### 2. Environment Management

```dart
/// Manages environment configuration
class EnvironmentManager {
  final Container _container;
  final Map<String, String> _cache = {};
  final List<String> _files = ['.env'];
  
  EnvironmentManager(this._container);
  
  /// Loads environment files
  Future<void> load([String? path]) async {
    path ??= _container.make<PathResolver>().base;
    
    for (var file in _files) {
      var envFile = File('$path/$file');
      if (await envFile.exists()) {
        var contents = await envFile.readAsString();
        _parseEnvFile(contents);
      }
    }
  }
  
  /// Gets an environment variable
  String? get(String key, [String? defaultValue]) {
    return _cache[key] ?? 
           Platform.environment[key] ?? 
           defaultValue;
  }
  
  /// Sets an environment variable
  void set(String key, String value) {
    _cache[key] = value;
  }
  
  /// Adds an environment file
  void addEnvFile(String file) {
    _files.add(file);
  }
  
  /// Parses an environment file
  void _parseEnvFile(String contents) {
    var lines = contents.split('\n');
    for (var line in lines) {
      if (_isComment(line)) continue;
      if (_isEmpty(line)) continue;
      
      var parts = line.split('=');
      if (parts.length != 2) continue;
      
      var key = parts[0].trim();
      var value = _parseValue(parts[1].trim());
      
      _cache[key] = value;
    }
  }
  
  /// Parses an environment value
  String _parseValue(String value) {
    // Remove quotes
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    
    // Handle special values
    switch (value.toLowerCase()) {
      case 'true':
      case '(true)':
        return 'true';
      case 'false':
      case '(false)':
        return 'false';
      case 'empty':
      case '(empty)':
        return '';
      case 'null':
      case '(null)':
        return '';
    }
    
    return value;
  }
}
```

### 3. Package Configuration

```dart
/// Manages package configuration publishing
class ConfigPublisher {
  final Container _container;
  final Map<String, List<String>> _publishGroups = {};
  
  ConfigPublisher(this._container);
  
  /// Publishes configuration files
  Future<void> publish(
    String package,
    Map<String, String> paths, [
    List<String>? groups
  ]) async {
    var resolver = _container.make<PathResolver>();
    var configPath = resolver.config;
    
    for (var entry in paths.entries) {
      var source = entry.key;
      var dest = '$configPath/${entry.value}';
      
      await _publishFile(source, dest);
      
      if (groups != null) {
        for (var group in groups) {
          _publishGroups.putIfAbsent(group, () => [])
            .add(dest);
        }
      }
    }
  }
  
  /// Gets files in a publish group
  List<String> getGroup(String name) {
    return _publishGroups[name] ?? [];
  }
  
  /// Copies a configuration file
  Future<void> _publishFile(
    String source,
    String destination
  ) async {
    var sourceFile = File(source);
    var destFile = File(destination);
    
    if (!await destFile.exists()) {
      await destFile.create(recursive: true);
      await sourceFile.copy(destination);
    }
  }
}
```

### 4. Configuration Cache

```dart
/// Caches configuration values
class ConfigCache {
  final Container _container;
  final String _cacheKey = 'config.cache';
  
  ConfigCache(this._container);
  
  /// Caches configuration values
  Future<void> cache(Map<String, dynamic> items) async {
    var cache = _container.make<CacheContract>();
    await cache.forever(_cacheKey, items);
  }
  
  /// Gets cached configuration
  Future<Map<String, dynamic>?> get() async {
    var cache = _container.make<CacheContract>();
    return await cache.get<Map<String, dynamic>>(_cacheKey);
  }
  
  /// Clears cached configuration
  Future<void> clear() async {
    var cache = _container.make<CacheContract>();
    await cache.forget(_cacheKey);
  }
}
```

## Integration Examples

### 1. Package Configuration
```dart
class MyPackageServiceProvider extends ServiceProvider {
  @override
  void register() {
    // Publish package config
    publishConfig('my-package', {
      'config/my-package.php': 'my-package'
    });
  }
  
  @override
  void boot() {
    // Merge package config
    var config = container.make<ConfigContract>();
    config.merge({
      'my-package': {
        'key': 'value'
      }
    });
  }
}
```

### 2. Environment Configuration
```dart
class AppServiceProvider extends ServiceProvider {
  @override
  void boot() {
    var env = container.make<EnvironmentManager>();
    
    // Add environment files
    env.addEnvFile('.env.local');
    if (protevusEnv.isTesting) {
      env.addEnvFile('.env.testing');
    }
    
    // Load environment
    await env.load();
  }
}
```

### 3. Configuration Cache
```dart
class CacheCommand {
  Future<void> handle() async {
    var config = container.make<ConfigContract>();
    var cache = container.make<ConfigCache>();
    
    // Cache config
    await cache.cache(config.all());
    
    // Clear config cache
    await cache.clear();
  }
}
```

## Testing

```dart
void main() {
  group('Config Repository', () {
    test('merges configuration', () {
      var config = ConfigRepository(container);
      
      config.set('database', {
        'default': 'mysql',
        'connections': {
          'mysql': {'host': 'localhost'}
        }
      });
      
      config.merge({
        'database': {
          'connections': {
            'mysql': {'port': 3306}
          }
        }
      });
      
      expect(
        config.get('database.connections.mysql'),
        equals({
          'host': 'localhost',
          'port': 3306
        })
      );
    });
  });
  
  group('Environment Manager', () {
    test('loads multiple env files', () async {
      var env = EnvironmentManager(container);
      env.addEnvFile('.env.testing');
      
      await env.load();
      
      expect(env.get('APP_ENV'), equals('testing'));
    });
  });
}
```

## Next Steps

1. Complete package config publishing
2. Add config merging
3. Enhance environment handling
4. Add caching improvements
5. Write more tests

Would you like me to enhance any other package specifications?

## Development Guidelines

### 1. Getting Started
Before implementing config features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Understand [Contracts Package Specification](contracts_package_specification.md)

### 2. Implementation Process
For each config feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Implement required contracts (see [Contracts Package Specification](contracts_package_specification.md))

### 4. Integration Considerations
When implementing config features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
5. Implement all contracts from [Contracts Package Specification](contracts_package_specification.md)

### 5. Performance Guidelines
Config system must:
1. Cache configuration efficiently
2. Minimize file I/O
3. Support lazy loading
4. Handle environment variables efficiently
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Config tests must:
1. Cover all configuration scenarios
2. Test environment handling
3. Verify caching behavior
4. Check file operations
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Config documentation must:
1. Explain configuration patterns
2. Show environment examples
3. Cover caching strategies
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
