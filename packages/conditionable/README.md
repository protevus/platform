# Platform Conditionable

A Dart implementation of Laravel's Conditionable trait, providing fluent conditional execution with method chaining.

## Features

- Conditional method execution with `when` and `unless`
- Support for method chaining
- Cascade notation support with `whenThen` and `unlessThen`
- Fallback execution with `orElse` handlers
- Support for both direct values and closure conditions

## Usage

```dart
import 'package:platform_conditionable/platform_conditionable.dart';

// Add the Conditionable mixin to your class
class YourClass with Conditionable {
  // Your class implementation
}
```

### Basic Conditional Execution

```dart
class QueryBuilder with Conditionable {
  final conditions = <String>[];
  
  void addCondition(String condition) {
    conditions.add(condition);
  }
}

final query = QueryBuilder();

// Using when
query.when(hasStatus, (self, _) {
  (self as QueryBuilder).addCondition("status = 'active'");
});

// Using unless
query.unless(category == null, (self, value) {
  (self as QueryBuilder).addCondition("category = '$value'");
});
```

### Method Chaining with Cascade Notation

```dart
class Config with Conditionable {
  bool debugMode = false;
  List<String> features = [];
}

final config = Config()
  ..whenThen(
    isDevelopment,
    () => config.features.add('debug-toolbar'),
  )
  ..unlessThen(
    isProduction,
    () => config.features.add('detailed-logs'),
  );
```

### Using Fallback Handlers

```dart
final result = instance.when(
  condition,
  (self, value) => 'Primary result',
  orElse: (self, value) => 'Fallback result',
);
```

### Closure Conditions

```dart
instance.when(
  () => someComplexCondition(),
  (self, value) {
    // Execute when condition is true
  },
);
```

## Features in Detail

### The `when` Method

Executes a callback if the condition is true:

```dart
instance.when(condition, (self, value) {
  // Executed if condition is true
});
```

### The `unless` Method

Executes a callback if the condition is false:

```dart
instance.unless(condition, (self, value) {
  // Executed if condition is false
});
```

### Cascade Notation with `whenThen` and `unlessThen`

For void operations that work well with cascade notation:

```dart
instance
  ..whenThen(condition1, () {
    // Execute if condition1 is true
  })
  ..unlessThen(condition2, () {
    // Execute if condition2 is false
  });
```

### Fallback Handling

All methods support fallback execution through `orElse`:

```dart
instance.when(
  condition,
  (self, value) => 'Primary action',
  orElse: (self, value) => 'Fallback action',
);

instance.whenThen(
  condition,
  () => print('Primary action'),
  orElse: () => print('Fallback action'),
);
```

## Example

See the [example](example/platform_conditionable_example.dart) for a complete demonstration of all features, including:

- Conditional query building
- Configuration setup
- Method chaining
- Fallback handlers
- Closure conditions

## Important Notes

1. When using callbacks that need to access the instance methods, cast the `self` parameter to your class type:
   ```dart
   instance.when(condition, (self, value) {
     (self as YourClass).someMethod();
   });
   ```

2. The `whenThen` and `unlessThen` methods are designed for void operations and work well with cascade notation.

3. Conditions can be either direct values or closures that return a value.

4. All methods return the instance by default if no callback is provided, enabling method chaining.
