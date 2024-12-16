# Platform Config

A Dart implementation of Laravel-inspired configuration management for the Protevus platform.

## Features

- Flexible configuration storage and retrieval
- Support for nested configuration keys
- Type-safe retrieval methods (string, integer, float, boolean, array)
- Implementation of Dart's `Map` interface for familiar usage
- Macro system for extending functionality at runtime

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_config: ^1.0.0
```

Then run:

```
dart pub get
```

## Usage

Here's a basic example of how to use the `Repository` class:

```dart
import 'package:platform_config/platform_config.dart';

void main() {
  final config = Repository({
    'app': {
      'name': 'My App',
      'debug': true,
    },
    'database': {
      'default': 'mysql',
      'connections': {
        'mysql': {
          'host': 'localhost',
          'port': 3306,
        },
      },
    },
  });

  // Get a value
  print(config.get('app.name')); // Output: My App

  // Get a typed value
  final isDebug = config.boolean('app.debug');
  print(isDebug); // Output: true

  // Get a nested value
  final dbPort = config.integer('database.connections.mysql.port');
  print(dbPort); // Output: 3306

  // Set a value
  config.set('app.version', '1.0.0');

  // Check if a key exists
  print(config.has('app.version')); // Output: true

  // Get multiple values
  final values = config.getMany(['app.name', 'app.debug']);
  print(values); // Output: {app.name: My App, app.debug: true}
}
```

### Available Methods

- `get<T>(String key, [T? defaultValue])`: Get a value by key, optionally specifying a default value.
- `set(dynamic key, dynamic value)`: Set a value for a key.
- `has(String key)`: Check if a key exists in the configuration.
- `string(String key, [String? defaultValue])`: Get a string value.
- `integer(String key, [int? defaultValue])`: Get an integer value.
- `float(String key, [double? defaultValue])`: Get a float value.
- `boolean(String key, [bool? defaultValue])`: Get a boolean value.
- `array(String key, [List<dynamic>? defaultValue])`: Get an array value.
- `getMany(List<String> keys)`: Get multiple values at once.
- `all()`: Get all configuration items.
- `prepend(String key, dynamic value)`: Prepend a value to an array.
- `push(String key, dynamic value)`: Append a value to an array.

The `Repository` class also implements Dart's `Map` interface, so you can use it like a regular map:

```dart
config['new.key'] = 'new value';
print(config['new.key']); // Output: new value
```

## Error Handling

The type-safe methods (`string()`, `integer()`, `float()`, `boolean()`, `array()`) will throw an `ArgumentError` if the value at the specified key is not of the expected type.

## Extending Functionality

You can extend the `Repository` class with custom methods using the macro system:

```dart
Repository.macro('getConnectionUrl', (Repository repo, String connection) {
  final conn = repo.get('database.connections.$connection');
  return 'mysql://${conn['username']}:${conn['password']}@${conn['host']}:${conn['port']}/${conn['database']}';
});

final config = Repository(/* ... */);
final mysqlUrl = config.callMacro('getConnectionUrl', ['mysql']);
print(mysqlUrl); // Output: mysql://user:password@localhost:3306/dbname
```

## Testing

To run the tests for this package, use the following command:

```
dart test
```

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License.
