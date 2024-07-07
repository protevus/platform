/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony InputBag.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/foundation.dart';
import 'package:protevus_http/foundation_exception.dart';

/// InputBag is an abstract class that extends ParameterBag to handle user input values.
/// It provides methods for getting, setting, and filtering input parameters.
///
/// Key features:
/// - Retrieves scalar input values by name
/// - Replaces or adds new input values
/// - Sets input values with type checking
/// - Converts parameter values to enums
/// - Filters and transforms parameter values
///
/// This class implements type-safe operations and throws appropriate exceptions
/// for invalid inputs or operations. It's designed to work with various types of
/// input data such as GET, POST, REQUEST, and COOKIE parameters.
abstract class InputBag extends ParameterBag {

  /// Retrieves a value from the input bag by its key.
  ///
  /// This method overrides the base [ParameterBag.get] method to add additional
  /// type checking for both the default value and the retrieved value.
  ///
  /// Parameters:
  /// - [key]: The key of the value to retrieve.
  /// - [defaultValue]: The default value to return if the key is not found.
  ///   Must be a scalar value (num, String, bool) or implement [Stringable].
  ///
  /// Returns:
  /// The value associated with the key, or the default value if the key is not found.
  ///
  /// Throws:
  /// - [FormatException]: If the default value is not a scalar or [Stringable].
  /// - [BadRequestException]: If the input value is not a scalar or [Stringable].
  @override
  dynamic get(String key, [dynamic defaultValue]) {
    if (defaultValue != null &&
        !(defaultValue is num ||
            defaultValue is String ||
            defaultValue is bool ||
            defaultValue is Stringable)) {
      throw FormatException(
          'Expected a scalar value as a 2nd argument to "get()", "${defaultValue.runtimeType}" given.');
    }

    var value = super.get(key, this);

    if (value != null &&
        identical(this, value) == false &&
        !(value is num ||
            value is String ||
            value is bool ||
            value is Stringable)) {
      throw BadRequestException('Input value "$key" contains a non-scalar value.');
    }

    return identical(this, value) ? defaultValue : value;
  }

  /// Replaces the current input values with a new set of inputs.
  ///
  /// This method overrides the base [ParameterBag.replace] method.
  /// Instead of directly replacing the parameters, it uses the [add] method
  /// to set the new input values, which ensures that each input is properly
  /// validated and set according to the rules defined in the [set] method.
  ///
  /// Parameters:
  /// - [inputs]: A Map containing the new input values to replace the current ones.
  @override
  void replace(Map<String, dynamic> inputs) {
    add(inputs);
  }

  /// Adds multiple input values to the InputBag.
  ///
  /// This method overrides the base [ParameterBag.add] method.
  /// It iterates through the provided map of inputs and sets each key-value pair
  /// using the [set] method, which ensures that each input is properly
  /// validated and set according to the rules defined in the [set] method.
  ///
  /// Parameters:
  /// - [inputs]: A Map containing the input values to be added to the InputBag.
  @override
  void add(Map<String, dynamic> inputs) {
    for (final entry in inputs.entries) {
      set(entry.key, entry.value);
    }
  }

  /// Sets an input value in the InputBag.
  ///
  /// This method overrides the base [ParameterBag.set] method to add additional
  /// type checking for the input value.
  ///
  /// Parameters:
  /// - [key]: The key under which to store the value.
  /// - [value]: The value to store. Must be null, a scalar (num, String, bool),
  ///   a List, a Map, or implement [Stringable].
  ///
  /// Throws:
  /// - [FormatException]: If the value is not null, a scalar, List, Map, or [Stringable].
  ///
  /// The method sets the value in the [parameters] map after successful validation.
  @override
  void set(String key, dynamic value) {
    if (value != null &&
        !(value is num ||
            value is String ||
            value is bool ||
            value is List ||
            value is Map ||
            value is Stringable)) {
      throw FormatException(
          'Expected a scalar, List, or Map as a 2nd argument to "set()", "${value.runtimeType}" given.');
    }

    parameters[key] = value;
  }

  /// Returns the parameter value converted to an enum.
  ///
  /// This method attempts to convert the parameter value associated with [key] to an enum
  /// of type [T]. The [values] list should contain all possible enum values.
  ///
  /// Parameters:
  /// - [key]: The key of the parameter to retrieve and convert.
  /// - [values]: A list of all possible enum values of type [T].
  /// - [defaultValue]: An optional default value to return if the key is not found.
  ///
  /// Returns:
  /// The enum value corresponding to the parameter value, or [defaultValue] if the key is not found.
  ///
  /// Throws:
  /// - [BadRequestException]: If the parameter value cannot be converted to the specified enum.
  ///   This exception wraps the original [UnexpectedValueException] thrown by the superclass.
  @override
  T? getEnum<T extends Enum>(String key, List<T> values, [T? defaultValue]) {
    try {
      return super.getEnum(key, values, defaultValue);
    } on UnexpectedValueException catch (e) {
      throw BadRequestException(e.toString());
    }
  }

  /// Retrieves a string value from the input bag by its key.
  ///
  /// This method overrides the base [ParameterBag.getString] method.
  /// It retrieves the value associated with the given [key] and converts it to a string.
  ///
  /// Parameters:
  /// - [key]: The key of the value to retrieve.
  /// - [defaultValue]: The default value to return if the key is not found. Defaults to an empty string.
  ///
  /// Returns:
  /// A string representation of the value associated with the key, or the default value if the key is not found.
  @override
  String getString(String key, [String defaultValue = '']) {
    return get(key, defaultValue).toString();
  }

  /// Filters and transforms a parameter value.
  ///
  /// This method retrieves a value from the input parameters and applies a specified filter to it.
  ///
  /// Parameters:
  /// - [key]: The key of the parameter to filter.
  /// - [defaultValue]: The default value to use if the key is not found in the parameters.
  /// - [filter]: An optional integer representing the filter to apply. If null, [Filter.defaultFilter] is used.
  /// - [options]: Additional options for the filter. Can be a Map or an integer representing flags.
  ///
  /// Returns:
  /// The filtered value, or null if the filtering fails and the FILTER_NULL_ON_FAILURE flag is set.
  ///
  /// Throws:
  /// - [BadRequestException]: If the input value is a List and neither FILTER_REQUIRE_ARRAY nor FILTER_FORCE_ARRAY flags are set.
  /// - [FormatException]: If FILTER_CALLBACK is used without providing a proper callback function.
  /// - [BadRequestException]: If the input value is invalid and the FILTER_NULL_ON_FAILURE flag is not set.
  ///
  /// This method handles various scenarios:
  /// - Converts options to a Map if it's not already one.
  /// - Checks for List inputs and appropriate flags.
  /// - Validates the callback function when FILTER_CALLBACK is used.
  /// - Applies the filter using [Filter.filterVar].
  /// - Handles the FILTER_NULL_ON_FAILURE flag.
  @override
  dynamic filter(String key, {dynamic defaultValue, int? filter, dynamic options}) {
    var value = has(key) ? parameters[key] : defaultValue;

    // Always turn options into a Map - this allows filter_var option shortcuts.
    if (options is! Map && options != null) {
      options = {'flags': options};
    }
    options ??= {};

    if (value is List && !((options['flags'] ?? 0) & (Filter.FILTER_REQUIRE_ARRAY | Filter.FILTER_FORCE_ARRAY))) {
      throw BadRequestException(
          'Input value "$key" contains a List, but "FILTER_REQUIRE_ARRAY" or "FILTER_FORCE_ARRAY" flags were not set.');
    }

    if ((filter ?? 0) & Filter.FILTER_CALLBACK != 0 && options['options'] is! Function) {
      throw FormatException(
          'A Function must be passed when FILTER_CALLBACK is used, "${options['options'].runtimeType}" given.');
    }

    options['flags'] ??= 0;
    bool nullOnFailure = (options['flags'] & Filter.FILTER_NULL_ON_FAILURE) != 0;
    options['flags'] |= Filter.FILTER_NULL_ON_FAILURE;

    var filteredValue = Filter.filterVar(value, filter ?? Filter.FILTER_DEFAULT, options);

    if (filteredValue != null || nullOnFailure) {
      return filteredValue;
    }

    throw BadRequestException(
        'Input value "$key" is invalid and flag "FILTER_NULL_ON_FAILURE" was not set.');
  }
}

