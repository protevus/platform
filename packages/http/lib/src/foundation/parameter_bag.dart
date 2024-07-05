/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony ParameterBag.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/foundation.dart';
import 'package:protevus_http/foundation_exception.dart';

/// ParameterBag is an abstract container for key/value pairs.
/// It implements Iterable<MapEntry<String, dynamic>> and Countable interfaces.
abstract class ParameterBag implements Iterable<MapEntry<String, dynamic>>, Countable {
  /// The underlying map containing the parameters.
  ///
  /// This getter provides access to the internal map that stores all the key-value pairs
  /// of parameters. The keys are of type [String], and the values can be of any type,
  /// hence [dynamic].
  ///
  /// This map is the core data structure of the ParameterBag, allowing for storage and
  /// retrieval of various parameters used throughout the application.
  Map<String, dynamic> get parameters;

  /// Returns all parameters or a specific nested parameter.
  ///
  /// If [key] is null, this method returns all parameters as a [Map<String, dynamic>].
  /// If [key] is provided, it returns the value associated with that key, which must be
  /// a [Map<String, dynamic>]. If the value is not a Map, it throws a [BadRequestException].
  ///
  /// Parameters:
  ///   [key] - Optional. The key of the nested parameter to retrieve.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] containing either all parameters or the nested parameter.
  ///
  /// Throws:
  ///   [BadRequestException] if the value for the given key is not a Map<String, dynamic>.
  Map<String, dynamic> all([String? key]) {
    if (key == null) {
      return parameters;
    }

    final value = parameters[key];
    if (value is! Map<String, dynamic>) {
      throw BadRequestException(
          'Unexpected value for parameter "$key": expecting "Map", got "${value.runtimeType}".');
    }

    return value;
  }

  /// Returns a list of all parameter keys.
  ///
  /// This method retrieves all the keys from the [parameters] map and returns them
  /// as a [List<String>]. This can be useful when you need to iterate over or
  /// inspect all the keys in the parameter bag without accessing their values.
  ///
  /// Returns:
  ///   A [List<String>] containing all the keys from the parameters map.
  List<String> keys() {
    return parameters.keys.toList();
  }

  /// Replaces the current parameters with a new set of parameters.
  ///
  /// This method completely replaces the existing parameters in the ParameterBag
  /// with the new parameters provided in the [parameters] argument.
  ///
  /// Parameters:
  ///   [parameters] - A Map<String, dynamic> containing the new set of parameters
  ///                  that will replace the existing ones.
  ///
  /// Example:
  ///   parameterBag.replace({'key1': 'value1', 'key2': 42});
  void replace(Map<String, dynamic> parameters);

  /// Adds new parameters to the existing set of parameters.
  ///
  /// This method merges the provided [parameters] with the existing parameters
  /// in the ParameterBag. If a key already exists, its value will be updated
  /// with the new value from the provided map.
  ///
  /// Parameters:
  ///   [parameters] - A Map<String, dynamic> containing the new parameters
  ///                  to be added to the existing set.
  ///
  /// Example:
  ///   parameterBag.add({'key1': 'newValue', 'key3': 'value3'});
  void add(Map<String, dynamic> parameters);

  /// Retrieves the value associated with the given key from the parameters.
  ///
  /// This method searches for the specified [key] in the parameters map.
  /// If the key is found, it returns the corresponding value.
  /// If the key is not found, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key to look up in the parameters map.
  ///   [defaultValue] - Optional. The value to return if the key is not found.
  ///                    If not provided, it defaults to null.
  ///
  /// Returns:
  ///   The value associated with the key if found, otherwise the defaultValue.
  ///
  /// Example:
  ///   var value = parameterBag.get('username', 'guest');
  dynamic get(String key, [dynamic defaultValue]) {
    return parameters.containsKey(key) ? parameters[key] : defaultValue;
  }

  /// Sets a parameter value for the given key.
  ///
  /// This method adds or updates a parameter in the ParameterBag.
  /// If the key already exists, its value will be updated.
  /// If the key doesn't exist, a new key-value pair will be added.
  ///
  /// Parameters:
  ///   [key] - The string key for the parameter.
  ///   [value] - The value to be associated with the key. Can be of any type.
  ///
  /// Example:
  ///   parameterBag.set('username', 'john_doe');
  ///   parameterBag.set('age', 30);
  void set(String key, dynamic value);

  /// Checks if a parameter with the given key exists in the ParameterBag.
  ///
  /// This method determines whether the specified [key] is present in the
  /// parameters map. It returns true if the key exists, and false otherwise.
  ///
  /// Parameters:
  ///   [key] - The string key to check for existence in the parameters map.
  ///
  /// Returns:
  ///   A boolean value: true if the key exists, false otherwise.
  ///
  /// Example:
  ///   if (parameterBag.has('username')) {
  ///     // Do something with the username parameter
  ///   }
  bool has(String key) {
    return parameters.containsKey(key);
  }

  /// Removes a parameter from the ParameterBag.
  ///
  /// This method removes the key-value pair associated with the given [key]
  /// from the parameters map. If the key doesn't exist, this method does nothing.
  ///
  /// Parameters:
  ///   [key] - The string key of the parameter to be removed.
  ///
  /// Example:
  ///   parameterBag.remove('username');
  void remove(String key);

  /// Returns the alphabetic characters of the parameter value.
  ///
  /// This method retrieves the value associated with the given [key] as a string,
  /// and then removes all non-alphabetic characters from it. If the key doesn't
  /// exist or its value is empty, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve and process.
  ///   [defaultValue] - Optional. The value to return if the key is not found
  ///                    or its value is empty. Defaults to an empty string.
  ///
  /// Returns:
  ///   A string containing only alphabetic characters (a-z and A-Z) from the
  ///   original parameter value.
  ///
  /// Example:
  ///   parameterBag.set('mixed', 'abc123XYZ!@#');
  ///   print(parameterBag.getAlpha('mixed')); // Outputs: 'abcXYZ'
  String getAlpha(String key, [String defaultValue = '']) {
    return getString(key, defaultValue).replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Returns the alphanumeric characters of the parameter value.
  ///
  /// This method retrieves the value associated with the given [key] as a string,
  /// and then removes all non-alphanumeric characters from it. If the key doesn't
  /// exist or its value is empty, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve and process.
  ///   [defaultValue] - Optional. The value to return if the key is not found
  ///                    or its value is empty. Defaults to an empty string.
  ///
  /// Returns:
  ///   A string containing only alphanumeric characters (a-z, A-Z, and 0-9) from the
  ///   original parameter value.
  ///
  /// Example:
  ///   parameterBag.set('mixed', 'abc123XYZ!@#');
  ///   print(parameterBag.getAlnum('mixed')); // Outputs: 'abc123XYZ'
  String getAlnum(String key, [String defaultValue = '']) {
    return getString(key, defaultValue).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Returns only the digit characters from the parameter value.
  ///
  /// This method retrieves the value associated with the given [key] as a string,
  /// and then removes all non-digit characters from it. If the key doesn't
  /// exist or its value is empty, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve and process.
  ///   [defaultValue] - Optional. The value to return if the key is not found
  ///                    or its value is empty. Defaults to an empty string.
  ///
  /// Returns:
  ///   A string containing only digit characters (0-9) from the original parameter value.
  ///
  /// Example:
  ///   parameterBag.set('mixed', 'abc123XYZ!@#');
  ///   print(parameterBag.getDigits('mixed')); // Outputs: '123'
  String getDigits(String key, [String defaultValue = '']) {
    return getString(key, defaultValue).replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Returns the parameter value as a string.
  ///
  /// This method retrieves the value associated with the given [key] and converts it to a string.
  /// If the key doesn't exist, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve.
  ///   [defaultValue] - Optional. The value to return if the key is not found.
  ///                    Defaults to an empty string.
  ///
  /// Returns:
  ///   A string representation of the parameter value.
  ///
  /// Throws:
  ///   [UnexpectedValueException] if the value cannot be converted to a string
  ///   (i.e., if it's not a String, num, or bool).
  ///
  /// Example:
  ///   parameterBag.set('number', 42);
  ///   print(parameterBag.getString('number')); // Outputs: '42'
  String getString(String key, [String defaultValue = '']) {
    final value = get(key, defaultValue);
    if (value is! String && value is! num && value is! bool) {
      throw UnexpectedValueException(
          'Parameter value "$key" cannot be converted to "String".');
    }
    return value.toString();
  }

  /// Returns the parameter value converted to an integer.
  ///
  /// This method retrieves the value associated with the given [key] and attempts to convert it to an integer.
  /// If the key doesn't exist or the value cannot be converted to an integer, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve.
  ///   [defaultValue] - Optional. The value to return if the key is not found or the value cannot be converted to an integer.
  ///                    Defaults to 0.
  ///
  /// Returns:
  ///   An integer representation of the parameter value.
  ///
  /// Example:
  ///   parameterBag.set('number', '42');
  ///   print(parameterBag.getInt('number')); // Outputs: 42
  ///   print(parameterBag.getInt('nonexistent', 10)); // Outputs: 10
  int getInt(String key, [int defaultValue = 0]) {
    final value = get(key, defaultValue);
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Returns the parameter value converted to a boolean.
  ///
  /// This method retrieves the value associated with the given [key] and attempts to convert it to a boolean.
  /// If the key doesn't exist, it returns the [defaultValue].
  ///
  /// The conversion rules are as follows:
  /// - If the value is already a boolean, it is returned as-is.
  /// - If the value is a string, it returns true if the string is 'true' (case-insensitive) or '1'.
  /// - For all other cases, it returns the [defaultValue].
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve.
  ///   [defaultValue] - Optional. The value to return if the key is not found or the value cannot be converted to a boolean.
  ///                    Defaults to false.
  ///
  /// Returns:
  ///   A boolean representation of the parameter value.
  ///
  /// Example:
  ///   parameterBag.set('flag1', 'true');
  ///   parameterBag.set('flag2', '1');
  ///   parameterBag.set('flag3', 'false');
  ///   print(parameterBag.getBoolean('flag1')); // Outputs: true
  ///   print(parameterBag.getBoolean('flag2')); // Outputs: true
  ///   print(parameterBag.getBoolean('flag3')); // Outputs: false
  ///   print(parameterBag.getBoolean('nonexistent')); // Outputs: false
  bool getBoolean(String key, [bool defaultValue = false]) {
    final value = get(key, defaultValue);
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  /// Returns the parameter value converted to an enum.
  ///
  /// This method retrieves the value associated with the given [key] and attempts to convert it
  /// to an enum of type [T]. The method compares the string representation of each enum value
  /// (without the enum type prefix) to the parameter value.
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to retrieve.
  ///   [values] - A list of all possible enum values of type [T].
  ///   [defaultValue] - Optional. The value to return if the key is not found or the value
  ///                    cannot be converted to an enum. Defaults to null.
  ///
  /// Returns:
  ///   An enum value of type [T] if a match is found, otherwise returns the [defaultValue].
  ///
  /// Throws:
  ///   [UnexpectedValueException] if the value exists but cannot be converted to an enum.
  ///
  /// Example:
  ///   enum Color { red, green, blue }
  ///   parameterBag.set('color', 'red');
  ///   var color = parameterBag.getEnum('color', Color.values); // Returns Color.red
  T? getEnum<T extends Enum>(String key, List<T> values, [T? defaultValue]) {
    final value = get(key);
    if (value == null) return defaultValue;
    try {
      return values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      throw UnexpectedValueException(
          'Parameter "$key" cannot be converted to enum: ${e.toString()}');
    }
  }

  /// Filters a parameter value based on the given key.
  ///
  /// This method retrieves the value associated with the given [key] and applies
  /// basic filtering logic. If the key doesn't exist, it returns the [defaultValue].
  ///
  /// The current implementation provides a simple string sanitization for string values,
  /// trimming whitespace from the beginning and end. For all other types, the value
  /// is returned as-is.
  ///
  /// This method is designed to be overridden or extended in subclasses to provide
  /// more sophisticated filtering logic.
  ///
  /// Parameters:
  ///   [key] - The key of the parameter to filter.
  ///   [defaultValue] - Optional. The value to return if the key doesn't exist.
  ///   [filter] - Optional. An integer representing the filter type (not used in the base implementation).
  ///   [options] - Optional. Additional options for filtering (not used in the base implementation).
  ///
  /// Returns:
  ///   The filtered value if the key exists, otherwise the [defaultValue].
  ///
  /// Example:
  ///   parameterBag.set('name', '  John Doe  ');
  ///   print(parameterBag.filter('name')); // Outputs: 'John Doe'
  dynamic filter(String key, {dynamic defaultValue, int? filter, dynamic options}) {
    if (!has(key)) {
      return defaultValue;
    }

    var value = get(key);

    // Basic filtering logic, can be overridden or extended in subclasses
    if (value is String) {
      // Simple string sanitization as an example
      return value.trim();
    }

    // For other types, return as is
    return value;
  }

  /// Returns an iterator for the entries in the parameters map.
  ///
  /// This getter provides an iterator that allows for traversing all key-value
  /// pairs (entries) in the underlying parameters map. It's particularly useful
  /// for iterating over all parameters in the ParameterBag.
  ///
  /// The iterator yields [MapEntry] objects, where each entry contains a String
  /// key and a dynamic value, corresponding to a parameter in the ParameterBag.
  ///
  /// This implementation is part of the [Iterable] interface, allowing
  /// ParameterBag to be used in for-in loops and with other Iterable methods.
  ///
  /// Returns:
  ///   An [Iterator] of [MapEntry<String, dynamic>] for the parameters map.
  ///
  /// Example:
  ///   for (var entry in parameterBag) {
  ///     print('${entry.key}: ${entry.value}');
  ///   }
  @override
  Iterator<MapEntry<String, dynamic>> get iterator => parameters.entries.iterator;

  /// Returns the number of parameters in the ParameterBag.
  ///
  /// This getter provides the count of key-value pairs in the underlying
  /// parameters map. It's an implementation of the [Countable] interface.
  ///
  /// Returns:
  ///   An integer representing the number of parameters stored in the ParameterBag.
  ///
  /// Example:
  ///   int parameterCount = parameterBag.count;
  ///   print('Number of parameters: $parameterCount');
  @override
  int get count => parameters.length;
}

