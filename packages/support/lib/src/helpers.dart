import 'package:platform_collections/collections.dart' show Arr;
import 'package:platform_contracts/contracts.dart'
    show DeferringDisplayableValue, Htmlable;

import 'env.dart';
import 'fluent.dart';
import 'higher_order_tap_proxy.dart';
import 'once.dart';
import 'onceable.dart';
import 'optional.dart';
import 'sleep.dart';
import 'str.dart';

/// Get an environment variable value.
///
/// Example:
/// ```dart
/// final dbHost = env('DB_HOST', 'localhost');
/// ```
T env<T>(String key, [T? defaultValue]) {
  return Env.get(key, defaultValue as String?) as T;
}

/// Create a collection from the given value.
///
/// Example:
/// ```dart
/// final collection = collect([1, 2, 3]);
/// ```
dynamic collect(dynamic value) {
  return Arr.wrap(value);
}

/// Create a fluent string instance.
///
/// Example:
/// ```dart
/// final str = string('hello').upper(); // HELLO
/// ```
Fluent string(String value) {
  return Fluent({'value': value});
}

/// Create a new optional instance.
///
/// Example:
/// ```dart
/// final opt = optional(someValue);
/// ```
Optional<T> optional<T>(T? value) {
  return Optional<T>(value);
}

/// Create a higher order tap proxy instance.
///
/// Example:
/// ```dart
/// final result = tap(value, (val) => print(val));
/// ```
T tap<T extends Object>(T value, Function(T value) callback) {
  callback(value);
  return value;
}

/// Create a new once instance.
///
/// Example:
/// ```dart
/// final once = createOnce();
/// once.call(() => print('Once')); // Prints once
/// ```
Once createOnce() {
  return Once();
}

/// Create a new onceable instance.
///
/// Example:
/// ```dart
/// final onceable = createOnceable();
/// onceable.once('key', () => print('Once')); // Prints once
/// ```
Onceable createOnceable() {
  return Onceable();
}

/// Sleep for the specified duration.
///
/// Example:
/// ```dart
/// await sleepFor(Duration(seconds: 1));
/// ```
Future<void> sleepFor(Duration duration) async {
  await Sleep.sleep(duration.inMilliseconds);
}

/// Convert a value to its string representation.
///
/// Example:
/// ```dart
/// final str = stringify(123); // "123"
/// ```
String stringify(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is DeferringDisplayableValue) {
    return stringify(value.resolveDisplayableValue());
  }
  if (value is Htmlable) {
    return value.toHtml();
  }
  return value.toString();
}

/// Convert a string to snake case.
///
/// Example:
/// ```dart
/// final snake = snakeCase('fooBar'); // foo_bar
/// ```
String snakeCase(String value) {
  return Str.snake(value);
}

/// Convert a string to camel case.
///
/// Example:
/// ```dart
/// final camel = camelCase('foo_bar'); // fooBar
/// ```
String camelCase(String value) {
  return Str.camel(value);
}

/// Convert a string to studly case.
///
/// Example:
/// ```dart
/// final studly = studlyCase('foo_bar'); // FooBar
/// ```
String studlyCase(String value) {
  return Str.studly(value);
}

/// Generate a random string.
///
/// Example:
/// ```dart
/// final random = randomString(16);
/// ```
String randomString([int length = 16]) {
  return Str.random(length);
}

/// Create a URL friendly slug from the given string.
///
/// Example:
/// ```dart
/// final slug = slugify('Hello World'); // hello-world
/// ```
String slugify(String value, {String separator = '-'}) {
  return Str.slug(value, separator: separator);
}

/// Get the value of an item using "dot" notation.
///
/// Example:
/// ```dart
/// final value = data('user.name', {'user': {'name': 'John'}});
/// ```
T? data<T>(String key, dynamic target, [T? defaultValue]) {
  return Arr.get(target, key, defaultValue);
}

/// Determine if a value is "blank".
///
/// Example:
/// ```dart
/// if (blank(value)) print('Value is blank');
/// ```
bool blank(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

/// Determine if a value is "filled".
///
/// Example:
/// ```dart
/// if (filled(value)) print('Value is filled');
/// ```
bool filled(dynamic value) => !blank(value);

/// Return the default value of the given value.
///
/// Example:
/// ```dart
/// final value = value_of(() => expensiveOperation());
/// ```
T value_of<T>(T Function() value) {
  return value();
}

/// Transform the given value if it passes the given truth test.
///
/// Example:
/// ```dart
/// final result = when(true, () => 'Yes', orElse: () => 'No');
/// ```
T when<T>(bool condition, T Function() value, {T Function()? orElse}) {
  if (condition) {
    return value();
  }
  return orElse?.call() ?? null as T;
}

/// Get the class "basename" of the given object.
///
/// Example:
/// ```dart
/// final name = class_basename(instance); // 'MyClass'
/// ```
String class_basename(dynamic object) {
  final type = object is Type ? object : object.runtimeType;
  final name = type.toString();
  final lastDot = name.lastIndexOf('.');
  return lastDot == -1 ? name : name.substring(lastDot + 1);
}
