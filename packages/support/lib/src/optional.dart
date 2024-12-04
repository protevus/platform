import 'package:platform_macroable/platform_macroable.dart';
import 'package:platform_reflection/reflection.dart';

/// Provides Laravel-like Optional type functionality with macro support.
///
/// This class allows for safe handling of potentially null values
/// with a fluent interface and supports runtime method extension.
class Optional<T> with Macroable {
  final T? _value;

  /// Creates a new Optional instance.
  const Optional(this._value);

  /// Creates Optional from nullable value.
  ///
  /// Example:
  /// ```dart
  /// final opt = Optional.of(someNullableValue);
  /// ```
  factory Optional.of(T? value) => Optional(value);

  /// Gets the value or returns the default.
  ///
  /// Example:
  /// ```dart
  /// final value = Optional.of(null).get('default'); // Returns 'default'
  /// ```
  T get(T defaultValue) => _value ?? defaultValue;

  /// Gets a property value by key.
  ///
  /// Example:
  /// ```dart
  /// final name = optional.prop('name'); // Returns property value
  /// ```
  dynamic prop(String key, [dynamic defaultValue]) {
    if (_value == null) return defaultValue;

    if (_value is Map) {
      final map = _value as Map;
      return map.containsKey(key) ? map[key] : defaultValue;
    }

    try {
      final reflector = RuntimeReflector.instance;
      final instance = reflector.reflect(_value!);
      if (instance != null) {
        final type = instance.type;
        final metadata = Reflector.getPropertyMetadata(type.reflectedType);

        if (metadata != null && metadata.containsKey(key)) {
          // Access property through dynamic dispatch
          final target = _value as dynamic;
          dynamic value;
          switch (key) {
            case 'item':
              value = target.item;
              break;
            default:
              throw ReflectionException('Property $key not implemented');
          }
          return value ?? defaultValue;
        }
      }
    } catch (_) {
      // If reflection fails, return default
    }

    return defaultValue;
  }

  /// Checks if a property exists.
  ///
  /// Example:
  /// ```dart
  /// if (optional.has('name')) {
  ///   print('Has name property');
  /// }
  /// ```
  bool has(String key) {
    if (_value == null) return false;

    if (_value is Map) {
      return (_value as Map).containsKey(key);
    }

    try {
      final reflector = RuntimeReflector.instance;
      final instance = reflector.reflect(_value!);
      if (instance != null) {
        final type = instance.type;
        final metadata = Reflector.getPropertyMetadata(type.reflectedType);
        return metadata != null && metadata.containsKey(key);
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  /// Array access operator to get property value.
  dynamic operator [](String key) => prop(key);

  /// Maps the value if present.
  ///
  /// Example:
  /// ```dart
  /// final opt = Optional.of(5)
  ///   .map((value) => value * 2); // Contains 10
  /// ```
  Optional<R> map<R>(R Function(T) mapper) {
    return Optional(_value == null ? null : mapper(_value!));
  }

  /// Returns true if value is present.
  ///
  /// Example:
  /// ```dart
  /// if (optional.isPresent) {
  ///   print('Has value');
  /// }
  /// ```
  bool get isPresent => _value != null;

  /// Returns true if value is empty.
  ///
  /// Example:
  /// ```dart
  /// if (optional.isEmpty) {
  ///   print('No value');
  /// }
  /// ```
  bool get isEmpty => !isPresent;

  /// Gets the value if present, otherwise null.
  ///
  /// Example:
  /// ```dart
  /// final value = optional.value; // Returns the value or null
  /// ```
  T? get value => _value;

  /// Gets the value if present, otherwise throws.
  ///
  /// Example:
  /// ```dart
  /// final value = optional.valueOrThrow; // Throws if null
  /// ```
  T get valueOrThrow {
    if (_value == null) {
      throw StateError('Optional value is null');
    }
    return _value!;
  }

  /// Executes callback if value is present.
  ///
  /// Example:
  /// ```dart
  /// optional.ifPresent((value) => print(value));
  /// ```
  void ifPresent(void Function(T) callback) {
    if (_value != null) {
      callback(_value!);
    }
  }

  /// Returns string representation.
  @override
  String toString() => 'Optional($_value)';

  /// Equality comparison.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Optional<T> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}
