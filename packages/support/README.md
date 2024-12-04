# Platform Support

Core support utilities and helper functions for the framework.

## Features

This package provides fundamental utilities and abstractions used throughout the framework:

### Fluent Interface

The `Fluent` class provides a fluent interface for working with attributes:

```dart
final user = Fluent({
  'name': 'John',
  'age': 30,
})
  ..set('email', 'john@example.com')
  ..set('active', true);

print(user.get('name')); // John
print(user.toJson()); // {"name":"John","age":30,"email":"john@example.com","active":true}
```

### Optional Values

The `Optional` class provides safe handling of potentially null values:

```dart
final value = Optional.of(someNullableValue)
  .map((val) => val * 2)
  .get(defaultValue);

// Or with null checks
final optional = Optional.of(someValue);
if (optional.isPresent) {
  optional.ifPresent((value) {
    // Do something with value
  });
}
```

### Higher Order Tap Proxy

The `HigherOrderTapProxy` class enables method chaining while allowing side effects:

```dart
final result = HigherOrderTapProxy(someObject)
  ..someMethod() // Calls method on target
  ..anotherMethod(); // Method chaining
```

## Usage

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  platform_support: ^1.0.0
```

Then import and use:

```dart
import 'package:platform_support/platform_support.dart';

// Use Fluent for attribute handling
final config = Fluent({
  'debug': true,
  'cache': {
    'driver': 'redis',
    'ttl': 3600
  }
});

// Use Optional for null safety
final value = Optional.of(config.get('missing'))
  .map((val) => val * 2)
  .get('default');

// Use HigherOrderTapProxy for method chaining
final proxy = HigherOrderTapProxy(someObject)
  ..doSomething()
  ..doSomethingElse();
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/yourusername/platform/issues).
