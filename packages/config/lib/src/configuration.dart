/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';

import 'package:protevus_config/config.dart';
import 'package:protevus_runtime/runtime.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// A base class for configuration management in Dart applications.
///
/// [Configuration] provides a framework for reading and parsing YAML-based
/// configuration files or strings. It offers various constructors to create
/// configuration objects from different sources (maps, strings, or files),
/// and includes methods for decoding and validating configuration data.
///
/// Key features:
/// - Supports creating configurations from YAML strings, files, or maps
/// - Provides a runtime context for configuration-specific operations
/// - Includes a default decoding mechanism that can be overridden
/// - Offers a validation method to ensure all required fields are present
/// - Allows for environment variable substitution in configuration values
///
/// Subclasses of [Configuration] should implement specific configuration
/// structures by defining properties that correspond to expected YAML keys.
/// The [decode] and [validate] methods can be overridden to provide custom
/// behavior for complex configuration scenarios.
///
/// Example usage:
/// ```dart
/// class MyConfig extends Configuration {
///   late String apiKey;
///   int port = 8080;
///
///   @override
///   void validate() {
///     super.validate();
///     if (port < 1000 || port > 65535) {
///       throw ConfigurationException(this, "Invalid port number");
///     }
///   }
/// }
///
/// final config = MyConfig.fromFile(File('config.yaml'));
/// ```
abstract class Configuration {
  /// Default constructor for the Configuration class.
  ///
  /// This constructor creates a new instance of the Configuration class
  /// without any initial configuration data. It can be used as a starting
  /// point for creating custom configurations, which can then be populated
  /// using other methods or by setting properties directly.
  Configuration();

  /// Creates a [Configuration] instance from a given map.
  ///
  /// This constructor takes a [Map] with dynamic keys and values, converts
  /// all keys to strings, and then decodes the resulting map into the
  /// configuration properties. This is useful when you have configuration
  /// data already in a map format, possibly from a non-YAML source.
  ///
  /// [map] The input map containing configuration data. Keys will be
  /// converted to strings, while values remain as their original types.
  ///
  /// Example:
  /// ```dart
  /// final configMap = {'key1': 'value1', 'key2': 42};
  /// final config = MyConfiguration.fromMap(configMap);
  /// ```
  Configuration.fromMap(Map<dynamic, dynamic> map) {
    decode(map.map<String, dynamic>((k, v) => MapEntry(k.toString(), v)));
  }

  /// Creates a [Configuration] instance from a YAML string.
  ///
  /// This constructor takes a [String] containing YAML content, parses it into
  /// a map, and then decodes the resulting map into the configuration properties.
  /// It's useful when you have configuration data as a YAML string, perhaps
  /// loaded from a file or received from an API.
  ///
  /// [contents] A string containing valid YAML data. This will be parsed and
  /// used to populate the configuration properties.
  ///
  /// Throws a [YamlException] if the YAML parsing fails.
  ///
  /// Example:
  /// ```dart
  /// final yamlString = '''
  /// api_key: abc123
  /// port: 8080
  /// ''';
  /// final config = MyConfiguration.fromString(yamlString);
  /// ```
  Configuration.fromString(String contents) {
    final yamlMap = loadYaml(contents) as Map<dynamic, dynamic>?;
    final map =
        yamlMap?.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    decode(map);
  }

  /// Creates a [Configuration] instance from a YAML file.
  ///
  /// [file] must contain valid YAML data.
  Configuration.fromFile(File file) : this.fromString(file.readAsStringSync());

  /// Returns the [ConfigurationRuntime] associated with the current instance's runtime type.
  ///
  /// This getter retrieves the [ConfigurationRuntime] from the [RuntimeContext.current] map,
  /// using the runtime type of the current instance as the key. The retrieved value
  /// is then cast to [ConfigurationRuntime].
  ///
  /// This is typically used internally to access runtime-specific configuration
  /// operations and validations.
  ///
  /// Returns:
  ///   The [ConfigurationRuntime] associated with this configuration's type.
  ///
  /// Throws:
  ///   A runtime exception if the retrieved value cannot be cast to [ConfigurationRuntime].
  ConfigurationRuntime get _runtime =>
      RuntimeContext.current[runtimeType] as ConfigurationRuntime;

  /// Decodes the given [value] and populates the properties of this configuration instance.
  ///
  /// Override this method to provide decoding behavior other than the default behavior.
  void decode(dynamic value) {
    if (value is! Map) {
      throw ConfigurationException(
        this,
        "input is not an object (is a '${value.runtimeType}')",
      );
    }

    _runtime.decode(this, value);

    validate();
  }

  /// Validates this configuration.
  ///
  /// This method is called automatically after the configuration is decoded. It performs
  /// validation checks on the configuration data to ensure its integrity and correctness.
  ///
  /// Override this method to perform validations on input data. Throw [ConfigurationException]
  /// for invalid data.
  @mustCallSuper
  void validate() {
    _runtime.validate(this);
  }

  /// Retrieves an environment variable value or returns the original value.
  ///
  /// This method checks if the given [value] is a string that starts with '$'.
  /// If so, it interprets the rest of the string as an environment variable name
  /// and attempts to retrieve its value from the system environment.
  ///
  /// If the environment variable exists, its value is returned.
  /// If the environment variable does not exist, null is returned.
  /// If the [value] is not a string starting with '$', the original [value] is returned unchanged.
  ///
  /// Parameters:
  ///   [value]: The value to check. Can be of any type.
  ///
  /// Returns:
  ///   - The value of the environment variable if [value] is a string starting with '$'
  ///     and the corresponding environment variable exists.
  ///   - null if [value] is a string starting with '$' but the environment variable doesn't exist.
  ///   - The original [value] if it's not a string starting with '$'.
  static dynamic getEnvironmentOrValue(dynamic value) {
    if (value is String && value.startsWith(r"$")) {
      final envKey = value.substring(1);
      if (!Platform.environment.containsKey(envKey)) {
        return null;
      }

      return Platform.environment[envKey];
    }
    return value;
  }
}

/// An abstract class representing the runtime behavior for configuration objects.
///
/// This class provides methods for decoding and validating configuration objects,
/// as well as a utility method for handling exceptions during the decoding process.
///
/// Implementations of this class should provide concrete logic for decoding
/// configuration data from input maps and validating the resulting configuration objects.
///
/// The [tryDecode] method offers a standardized way to handle exceptions that may occur
/// during the decoding process, wrapping them in appropriate [ConfigurationException]s
/// with detailed key paths for easier debugging.
abstract class ConfigurationRuntime {
  /// Decodes the input map and populates the given configuration object.
  ///
  /// This method is responsible for parsing the input map and setting the
  /// corresponding values in the configuration object. It should handle
  /// type conversions, nested structures, and any specific logic required
  /// for populating the configuration.
  ///
  /// Parameters:
  ///   [configuration]: The Configuration object to be populated with decoded values.
  ///   [input]: A Map containing the raw configuration data to be decoded.
  ///
  /// Implementations of this method should handle potential errors gracefully,
  /// possibly by throwing ConfigurationException for invalid or missing data.
  void decode(Configuration configuration, Map input);

  /// Validates the given configuration object.
  ///
  /// This method is responsible for performing validation checks on the
  /// provided configuration object. It should ensure that all required
  /// fields are present and that the values meet any specific criteria
  /// or constraints defined for the configuration.
  ///
  /// Parameters:
  ///   [configuration]: The Configuration object to be validated.
  ///
  /// Implementations of this method should throw a [ConfigurationException]
  /// if any validation errors are encountered, providing clear and specific
  /// error messages to aid in debugging and resolution of configuration issues.
  void validate(Configuration configuration);

  /// Attempts to decode a configuration property and handles exceptions.
  ///
  /// This method provides a standardized way to handle exceptions that may occur
  /// during the decoding process of a configuration property. It wraps the decoding
  /// logic in a try-catch block and transforms various exceptions into appropriate
  /// [ConfigurationException]s with detailed key paths for easier debugging.
  ///
  /// Parameters:
  ///   [configuration]: The Configuration object being decoded.
  ///   [name]: The name of the property being decoded.
  ///   [decode]: A function that performs the actual decoding logic.
  ///
  /// Returns:
  ///   The result of the [decode] function if successful.
  ///
  /// Throws:
  ///   [ConfigurationException]:
  ///     - If a [ConfigurationException] is caught, it's re-thrown with an updated key path.
  ///     - If an [IntermediateException] is caught, it's transformed into a [ConfigurationException]
  ///       with appropriate error details.
  ///     - For any other exception, a new [ConfigurationException] is thrown with the exception message.
  ///
  /// This method is particularly useful for maintaining a consistent error handling
  /// approach across different configuration properties and types.
  dynamic tryDecode(
    Configuration configuration,
    String name,
    dynamic Function() decode,
  ) {
    try {
      return decode();
    } on ConfigurationException catch (e) {
      throw ConfigurationException(
        configuration,
        e.message,
        keyPath: [name, ...e.keyPath],
      );
    } on IntermediateException catch (e) {
      final underlying = e.underlying;
      if (underlying is ConfigurationException) {
        final keyPaths = [
          [name],
          e.keyPath,
          underlying.keyPath,
        ].expand((i) => i).toList();

        throw ConfigurationException(
          configuration,
          underlying.message,
          keyPath: keyPaths,
        );
      } else if (underlying is TypeError) {
        throw ConfigurationException(
          configuration,
          "input is wrong type",
          keyPath: [name, ...e.keyPath],
        );
      }

      throw ConfigurationException(
        configuration,
        underlying.toString(),
        keyPath: [name, ...e.keyPath],
      );
    } catch (e) {
      throw ConfigurationException(
        configuration,
        e.toString(),
        keyPath: [name],
      );
    }
  }
}

/// Enumerates the possible options for a configuration item property's optionality.
///
/// This enum is used to specify whether a configuration property is required or optional
/// when parsing configuration data. It helps in determining how to handle missing keys
/// in the source YAML configuration.
enum ConfigurationItemAttributeType {
  /// Indicates that a configuration property is required.
  ///
  /// When a configuration property is marked as [required], it means that
  /// the corresponding key must be present in the source YAML configuration.
  /// If the key is missing, an exception will be thrown during the parsing
  /// or validation process.
  ///
  /// This helps ensure that all necessary configuration values are provided
  /// and reduces the risk of runtime errors due to missing configuration data.
  required,

  /// Indicates that a configuration property is optional.
  ///
  /// When a configuration property is marked as [optional], it means that
  /// the corresponding key can be omitted from the source YAML configuration
  /// without causing an error. If the key is missing, the property will be
  /// silently ignored during the parsing process.
  ///
  /// This allows for more flexible configuration structures where some
  /// properties are not mandatory and can be omitted without affecting
  /// the overall functionality of the configuration.
  ///
  /// [Configuration] properties marked as [optional] will be silently ignored
  /// if their source YAML doesn't contain a matching key.
  optional
}

/// Represents an attribute for configuration item properties.
///
/// **NOTICE**: This will be removed in version 2.0.0.
/// To signify required or optional config you could do:
/// Example:
/// ```dart
/// class MyConfig extends Config {
///    late String required;
///    String? optional;
///    String optionalWithDefult = 'default';
///    late String optionalWithComputedDefault = _default();
///
///    String _default() => 'computed';
/// }
/// ```
class ConfigurationItemAttribute {
  const ConfigurationItemAttribute._(this.type);

  final ConfigurationItemAttributeType type;
}

/// A [ConfigurationItemAttribute] for required properties.
///
/// **NOTICE**: This will be removed in version 2.0.0.
/// To signify required or optional config you could do:
/// Example:
/// ```dart
/// class MyConfig extends Config {
///    late String required;
///    String? optional;
///    String optionalWithDefult = 'default';
///    late String optionalWithComputedDefault = _default();
///
///    String _default() => 'computed';
/// }
/// ```
@Deprecated("Use `late` property")
const ConfigurationItemAttribute requiredConfiguration =
    ConfigurationItemAttribute._(ConfigurationItemAttributeType.required);

/// A [ConfigurationItemAttribute] for optional properties.
///
/// **NOTICE**: This will be removed in version 2.0.0.
/// To signify required or optional config you could do:
/// Example:
/// ```dart
/// class MyConfig extends Config {
///    late String required;
///    String? optional;
///    String optionalWithDefult = 'default';
///    late String optionalWithComputedDefault = _default();
///
///    String _default() => 'computed';
/// }
/// ```
@Deprecated("Use `nullable` property")
const ConfigurationItemAttribute optionalConfiguration =
    ConfigurationItemAttribute._(ConfigurationItemAttributeType.optional);

/// Represents an exception thrown when reading data into a [Configuration] fails.
///
/// This exception provides detailed information about the configuration error,
/// including the configuration object where the error occurred, the error message,
/// and optionally, the key path to the problematic configuration item.
///
/// The class offers two constructors:
/// 1. A general constructor for creating exceptions with custom messages.
/// 2. A specialized constructor [ConfigurationException.missingKeys] for creating
///    exceptions specifically related to missing required keys.
///
/// The [toString] method provides a formatted error message that includes the
/// configuration type, the key path (if available), and the error message.
///
/// Usage:
/// ```dart
/// throw ConfigurationException(
///   myConfig,
///   "Invalid value",
///   keyPath: ['server', 'port'],
/// );
/// ```
///
/// Or for missing keys:
/// ```dart
/// throw ConfigurationException.missingKeys(
///   myConfig,
///   ['apiKey', 'secret'],
/// );
/// ```
class ConfigurationException {
  /// Creates a new [ConfigurationException] instance.
  ///
  /// This constructor is used to create an exception that provides information
  /// about a configuration error.
  ///
  /// Parameters:
  /// - [configuration]: The [Configuration] object where the error occurred.
  /// - [message]: A string describing the error.
  /// - [keyPath]: An optional list of keys or indices that specify the path to
  ///   the problematic configuration item. Defaults to an empty list.
  ///
  /// Example:
  /// ```dart
  /// throw ConfigurationException(
  ///   myConfig,
  ///   "Invalid port number",
  ///   keyPath: ['server', 'port'],
  /// );
  /// ```
  ConfigurationException(
    this.configuration,
    this.message, {
    this.keyPath = const [],
  });

  /// Creates a [ConfigurationException] for missing required keys.
  ///
  /// This constructor is specifically used to create an exception when one or more
  /// required keys are missing from the configuration.
  ///
  /// Parameters:
  /// - [configuration]: The [Configuration] object where the missing keys were detected.
  /// - [missingKeys]: A list of strings representing the names of the missing required keys.
  /// - [keyPath]: An optional list of keys or indices that specify the path to the
  ///   configuration item where the missing keys were expected. Defaults to an empty list.
  ///
  /// The [message] is automatically generated to list all the missing keys.
  ///
  /// Example:
  /// ```dart
  /// throw ConfigurationException.missingKeys(
  ///   myConfig,
  ///   ['apiKey', 'secret'],
  ///   keyPath: ['server', 'authentication'],
  /// );
  /// ```
  ConfigurationException.missingKeys(
    this.configuration,
    List<String> missingKeys, {
    this.keyPath = const [],
  }) : message =
            "missing required key(s): ${missingKeys.map((s) => "'$s'").join(", ")}";

  /// The [Configuration] instance in which this exception occurred.
  ///
  /// This field stores a reference to the [Configuration] object that was being
  /// processed when the exception was thrown. It provides context about which
  /// specific configuration was involved in the error, allowing for more
  /// detailed error reporting and easier debugging.
  ///
  /// The stored configuration can be used to access additional information
  /// about the configuration state at the time of the error, which can be
  /// helpful in diagnosing and resolving configuration-related issues.
  final Configuration configuration;

  /// The reason for the exception.
  ///
  /// This field contains a string describing the specific error or reason
  /// why the [ConfigurationException] was thrown. It provides detailed
  /// information about what went wrong during the configuration process.
  ///
  /// The message can be used for logging, debugging, or displaying error
  /// information to users or developers to help diagnose and fix
  /// configuration-related issues.
  final String message;

  /// The key path of the object being evaluated.
  ///
  /// Either a string (adds '.name') or an int (adds '\[value\]').
  final List<dynamic> keyPath;

  /// Provides a string representation of the [ConfigurationException].
  ///
  /// This method generates a formatted error message that includes:
  /// - The type of the configuration where the error occurred
  /// - The key path to the problematic configuration item (if available)
  /// - The specific error message
  ///
  /// The key path is constructed by joining the elements in [keyPath]:
  /// - String elements are joined with dots (e.g., 'server.port')
  /// - Integer elements are enclosed in square brackets (e.g., '[0]')
  ///
  /// If [keyPath] is empty, a general error message for the configuration is returned.
  ///
  /// Returns:
  ///   A string containing the formatted error message.
  ///
  /// Throws:
  ///   [StateError] if an element in [keyPath] is neither a String nor an int.
  @override
  String toString() {
    if (keyPath.isEmpty) {
      return "Failed to read '${configuration.runtimeType}'\n\t-> $message";
    }
    final joinedKeyPath = StringBuffer();
    for (var i = 0; i < keyPath.length; i++) {
      final thisKey = keyPath[i];
      if (thisKey is String) {
        if (i != 0) {
          joinedKeyPath.write(".");
        }
        joinedKeyPath.write(thisKey);
      } else if (thisKey is int) {
        joinedKeyPath.write("[$thisKey]");
      } else {
        throw StateError("not an int or String");
      }
    }

    return "Failed to read key '$joinedKeyPath' for '${configuration.runtimeType}'\n\t-> $message";
  }
}

/// Represents an error that occurs when a [Configuration] subclass is invalid and requires a change in code.
///
/// This exception is thrown when there's a structural or logical issue with a [Configuration] subclass
/// that cannot be resolved at runtime and requires modifications to the code itself.
///
/// The [ConfigurationError] provides information about the specific [Configuration] type that caused the error
/// and a descriptive message explaining the nature of the invalidity.
///
/// Properties:
/// - [type]: The Type of the [Configuration] subclass where the error occurred.
/// - [message]: A String describing the specific error or invalidity.
///
/// Usage:
/// ```dart
/// throw ConfigurationError(MyConfig, "Missing required property 'apiKey'");
/// ```
///
/// The [toString] method provides a formatted error message combining the invalid type and the error description.
class ConfigurationError {
  /// Creates a new [ConfigurationError] instance.
  ///
  /// This constructor is used to create an error that indicates an invalid [Configuration] subclass
  /// which requires changes to the code itself to resolve.
  ///
  /// Parameters:
  /// - [type]: The [Type] of the [Configuration] subclass where the error occurred.
  /// - [message]: A string describing the specific error or invalidity.
  ///
  /// This error is typically thrown when there's a structural or logical issue with a [Configuration]
  /// subclass that cannot be resolved at runtime and requires modifications to the code.
  ///
  /// Example:
  /// ```dart
  /// throw ConfigurationError(MyConfig, "Missing required property 'apiKey'");
  /// ```
  ConfigurationError(this.type, this.message);

  /// The type of [Configuration] in which this error appears.
  ///
  /// This property stores the [Type] of the [Configuration] subclass that is
  /// considered invalid or problematic. It provides context about which specific
  /// configuration class triggered the error, allowing for more precise error
  /// reporting and easier debugging.
  ///
  /// The stored type can be used to identify the exact [Configuration] subclass
  /// that needs to be modified or corrected to resolve the error.
  final Type type;

  /// The reason for the error.
  ///
  /// This field contains a string describing the specific error or reason
  /// why the [ConfigurationError] was thrown. It provides detailed
  /// information about what makes the [Configuration] subclass invalid
  /// or problematic.
  ///
  /// The message can be used for logging, debugging, or displaying error
  /// information to developers to help diagnose and fix issues related
  /// to the structure or implementation of the [Configuration] subclass.
  String message;

  /// Returns a string representation of the [ConfigurationError].
  ///
  /// This method generates a formatted error message that includes:
  /// - The type of the invalid [Configuration] subclass
  /// - The specific error message describing the invalidity
  ///
  /// The resulting string is useful for logging, debugging, or displaying
  /// error information to developers to help identify and fix issues with
  /// the [Configuration] subclass implementation.
  ///
  /// Returns:
  ///   A string containing the formatted error message.
  @override
  String toString() {
    return "Invalid configuration type '$type'. $message";
  }
}
