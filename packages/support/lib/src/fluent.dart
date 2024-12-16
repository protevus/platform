import 'dart:convert';
import 'package:platform_contracts/contracts.dart';
import 'package:collection/collection.dart';

/// Provides fluent interface building with attribute access.
///
/// Similar to Laravel's Fluent class, this provides a fluent interface
/// for working with attributes through method chaining.
class Fluent implements Arrayable<String, dynamic>, Jsonable {
  /// The attributes container
  final Map<String, dynamic> _attributes;

  /// Create a new fluent container instance.
  ///
  /// Example:
  /// ```dart
  /// final fluent = Fluent({'name': 'John'})
  ///   ..set('age', 30)
  ///   ..set('email', 'john@example.com');
  /// ```
  Fluent([Map<String, dynamic>? attributes]) : _attributes = attributes ?? {};

  /// Get an attribute from the container.
  ///
  /// Example:
  /// ```dart
  /// final name = fluent.get('name'); // Returns 'John'
  /// ```
  dynamic get(String key, [dynamic defaultValue]) {
    if (key.contains('.')) {
      final segments = key.split('.');
      dynamic value = _attributes;

      for (final segment in segments) {
        if (value is! Map) return defaultValue;
        if (!value.containsKey(segment)) return defaultValue;
        value = value[segment];
      }

      return value ?? defaultValue;
    }

    return _attributes[key] ?? defaultValue;
  }

  /// Get an integer value from the container.
  ///
  /// Example:
  /// ```dart
  /// final age = fluent.getInteger('age'); // Returns 30
  /// ```
  int getInteger(String key, [int defaultValue = 0]) {
    final value = get(key);
    if (value == null) return defaultValue;

    if (value is int) return value;
    if (value is String) {
      // Handle string numbers with spaces or underscores
      final cleaned = value.trim().replaceAll('_', '');
      // Try to parse just the numeric part if it starts with a number
      final match = RegExp(r'^\d+').firstMatch(cleaned);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? defaultValue;
      }
    }
    return defaultValue;
  }

  /// Get a double value from the container.
  ///
  /// Example:
  /// ```dart
  /// final price = fluent.getDouble('price'); // Returns 99.99
  /// ```
  double getDouble(String key, [double defaultValue = 0.0]) {
    final value = get(key);
    if (value == null) return defaultValue;

    if (value is num) return value.toDouble();
    if (value is String) {
      // Handle string numbers with spaces
      final cleaned = value.trim();
      // Try to parse just the numeric part if it starts with a number or decimal
      final match = RegExp(r'^[0-9]*\.?[0-9]+').firstMatch(cleaned);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? defaultValue;
      }
    }
    return defaultValue;
  }

  /// Set an attribute on the container.
  ///
  /// Example:
  /// ```dart
  /// fluent.set('name', 'Jane');
  /// ```
  Fluent set(String key, dynamic value) {
    _attributes[key] = value;
    return this;
  }

  /// Get all attributes from the container.
  ///
  /// Example:
  /// ```dart
  /// final attributes = fluent.getAttributes(); // Returns {'name': 'John', 'age': 30}
  /// ```
  Map<String, dynamic> getAttributes() => Map.from(_attributes);

  @override
  Map<String, dynamic> toArray() => getAttributes();

  @override
  String toJson([Map<String, dynamic>? options]) {
    return json.encode(_attributes);
  }

  /// Determine if an attribute exists on the container.
  ///
  /// Example:
  /// ```dart
  /// if (fluent.has('name')) {
  ///   print('Name exists');
  /// }
  /// ```
  bool has(String key) => _attributes.containsKey(key);

  /// Remove an attribute from the container.
  ///
  /// Example:
  /// ```dart
  /// fluent.remove('name');
  /// ```
  Fluent remove(String key) {
    _attributes.remove(key);
    return this;
  }

  /// Clear all attributes from the container.
  ///
  /// Example:
  /// ```dart
  /// fluent.clear();
  /// ```
  Fluent clear() {
    _attributes.clear();
    return this;
  }

  /// Merge the given attributes into the container.
  ///
  /// Example:
  /// ```dart
  /// fluent.merge({'age': 31, 'city': 'New York'});
  /// ```
  Fluent merge(Map<String, dynamic> attributes) {
    _attributes.addAll(attributes);
    return this;
  }

  /// Array access operator to get attribute value
  dynamic operator [](String key) => get(key);

  /// Array access operator to set attribute value
  void operator []=(String key, dynamic value) => set(key, value);

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fluent &&
        const DeepCollectionEquality().equals(_attributes, other._attributes);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(_attributes);
}
