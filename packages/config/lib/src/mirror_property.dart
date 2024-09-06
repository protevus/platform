/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:mirrors';
import 'package:protevus_config/config.dart';

/// A codec for decoding and encoding values based on their type using reflection.
///
/// This class uses the dart:mirrors library to introspect types and provide
/// appropriate decoding and encoding logic for various data types including
/// int, bool, Configuration subclasses, List, and Map.
///
/// The class supports:
/// - Decoding values from various input formats to their corresponding Dart types.
/// - Generating source code strings for decoding operations.
/// - Validating Configuration subclasses to ensure they have a default constructor.
///
/// Usage:
/// ```dart
/// final codec = MirrorTypeCodec(reflectType(SomeType));
/// final decodedValue = codec._decodeValue(inputValue);
/// final sourceCode = codec.source;
/// ```
///
/// Note: This class relies heavily on reflection, which may have performance
/// implications and is not supported in all Dart runtime environments.
class MirrorTypeCodec {
  /// Constructor for MirrorTypeCodec.
  ///
  /// This constructor takes a [TypeMirror] as its parameter and initializes the codec.
  /// It performs a validation check for Configuration subclasses to ensure they have
  /// a default (unnamed) constructor with all optional parameters.
  ///
  /// Parameters:
  ///   [type]: The TypeMirror representing the type for which this codec is being created.
  ///
  /// Throws:
  ///   [StateError]: If the type is a subclass of Configuration and doesn't have
  ///   an unnamed constructor with all optional parameters.
  ///
  /// The constructor specifically:
  /// 1. Checks if the type is a subclass of Configuration.
  /// 2. If so, it verifies the presence of a default constructor.
  /// 3. Throws a StateError if the required constructor is missing, providing
  ///    a detailed error message to guide the developer.
  MirrorTypeCodec(this.type) {
    if (type.isSubtypeOf(reflectType(Configuration))) {
      final klass = type as ClassMirror;
      final classHasDefaultConstructor = klass.declarations.values.any((dm) {
        return dm is MethodMirror &&
            dm.isConstructor &&
            dm.constructorName == Symbol.empty &&
            dm.parameters.every((p) => p.isOptional == true);
      });

      if (!classHasDefaultConstructor) {
        throw StateError(
          "Failed to compile '${type.reflectedType}'\n\t-> "
          "'Configuration' subclasses MUST declare an unnammed constructor "
          "(i.e. '${type.reflectedType}();') if they are nested.",
        );
      }
    }
  }

  /// The [TypeMirror] representing the type for which this codec is created.
  ///
  /// This field stores the reflection information about the type that this
  /// [MirrorTypeCodec] instance is designed to handle. It is used throughout
  /// the class to determine how to decode and encode values of this type.
  final TypeMirror type;

  /// Decodes a value based on its type using reflection.
  ///
  /// This method takes a [dynamic] input value and decodes it according to the
  /// type specified by this codec's [type] property. It supports decoding for:
  /// - Integers
  /// - Booleans
  /// - Configuration subclasses
  /// - Lists
  /// - Maps
  ///
  /// If the input type doesn't match any of these, the original value is returned.
  ///
  /// Parameters:
  ///   [value]: The input value to be decoded.
  ///
  /// Returns:
  ///   The decoded value, with its type corresponding to the codec's [type].
  ///
  /// Throws:
  ///   May throw exceptions if decoding fails, particularly for nested structures
  ///   like Lists and Maps.
  dynamic _decodeValue(dynamic value) {
    if (type.isSubtypeOf(reflectType(int))) {
      return _decodeInt(value);
    } else if (type.isSubtypeOf(reflectType(bool))) {
      return _decodeBool(value);
    } else if (type.isSubtypeOf(reflectType(Configuration))) {
      return _decodeConfig(value);
    } else if (type.isSubtypeOf(reflectType(List))) {
      return _decodeList(value as List);
    } else if (type.isSubtypeOf(reflectType(Map))) {
      return _decodeMap(value as Map);
    }

    return value;
  }

  /// Decodes a boolean value from various input types.
  ///
  /// This method handles the conversion of input values to boolean:
  /// - If the input is a String, it returns true if the string is "true" (case-sensitive),
  ///   and false otherwise.
  /// - For non-String inputs, it attempts to cast the value directly to a bool.
  ///
  /// Parameters:
  ///   [value]: The input value to be decoded into a boolean.
  ///
  /// Returns:
  ///   A boolean representation of the input value.
  ///
  /// Throws:
  ///   TypeError: If the input cannot be cast to a bool (for non-String inputs).
  dynamic _decodeBool(dynamic value) {
    if (value is String) {
      return value == "true";
    }

    return value as bool;
  }

  /// Decodes an integer value from various input types.
  ///
  /// This method handles the conversion of input values to integers:
  /// - If the input is a String, it attempts to parse it as an integer.
  /// - For non-String inputs, it attempts to cast the value directly to an int.
  ///
  /// Parameters:
  ///   [value]: The input value to be decoded into an integer.
  ///
  /// Returns:
  ///   An integer representation of the input value.
  ///
  /// Throws:
  ///   FormatException: If the input String cannot be parsed as an integer.
  ///   TypeError: If the input cannot be cast to an int (for non-String inputs).
  dynamic _decodeInt(dynamic value) {
    if (value is String) {
      return int.parse(value);
    }

    return value as int;
  }

  /// Decodes a Configuration object from the given input.
  ///
  /// This method creates a new instance of the Configuration subclass
  /// represented by this codec's type, and then decodes the input object
  /// into it.
  ///
  /// Parameters:
  ///   [object]: The input object to be decoded into a Configuration instance.
  ///
  /// Returns:
  ///   A new instance of the Configuration subclass, populated with the decoded data.
  ///
  /// Throws:
  ///   May throw exceptions if the instantiation fails or if the decode
  ///   method of the Configuration subclass throws an exception.
  Configuration _decodeConfig(dynamic object) {
    final item = (type as ClassMirror).newInstance(Symbol.empty, []).reflectee
        as Configuration;

    item.decode(object);

    return item;
  }

  /// Decodes a List value based on the codec's type parameters.
  ///
  /// This method creates a new List instance and populates it with decoded elements
  /// from the input List. It uses an inner decoder to process each element according
  /// to the type specified in the codec's type arguments.
  ///
  /// Parameters:
  ///   [value]: The input List to be decoded.
  ///
  /// Returns:
  ///   A new List containing the decoded elements.
  ///
  /// Throws:
  ///   IntermediateException: If an error occurs during the decoding of any element.
  ///   The exception includes the index of the problematic element in its keyPath.
  ///
  /// Note:
  ///   - The method creates a growable List.
  ///   - It uses reflection to create the new List instance.
  ///   - Each element is decoded using an inner decoder based on the first type argument.
  List _decodeList(List value) {
    final out = (type as ClassMirror).newInstance(const Symbol('empty'), [], {
      const Symbol('growable'): true,
    }).reflectee as List;
    final innerDecoder = MirrorTypeCodec(type.typeArguments.first);
    for (var i = 0; i < value.length; i++) {
      try {
        final v = innerDecoder._decodeValue(value[i]);
        out.add(v);
      } on IntermediateException catch (e) {
        e.keyPath.add(i);
        rethrow;
      } catch (e) {
        throw IntermediateException(e, [i]);
      }
    }
    return out;
  }

  /// Decodes a Map value based on the codec's type parameters.
  ///
  /// This method creates a new Map instance and populates it with decoded key-value pairs
  /// from the input Map. It uses an inner decoder to process each value according
  /// to the type specified in the codec's type arguments.
  ///
  /// Parameters:
  ///   [value]: The input Map to be decoded.
  ///
  /// Returns:
  ///   A new Map containing the decoded key-value pairs.
  ///
  /// Throws:
  ///   StateError: If any key in the input Map is not a String.
  ///   IntermediateException: If an error occurs during the decoding of any value.
  ///   The exception includes the key of the problematic value in its keyPath.
  ///
  /// Note:
  ///   - The method creates a new Map instance using reflection.
  ///   - It enforces that all keys must be Strings.
  ///   - Each value is decoded using an inner decoder based on the last type argument.
  Map<dynamic, dynamic> _decodeMap(Map value) {
    final map =
        (type as ClassMirror).newInstance(Symbol.empty, []).reflectee as Map;

    final innerDecoder = MirrorTypeCodec(type.typeArguments.last);
    value.forEach((key, val) {
      if (key is! String) {
        throw StateError('cannot have non-String key');
      }

      try {
        map[key] = innerDecoder._decodeValue(val);
      } on IntermediateException catch (e) {
        e.keyPath.add(key);
        rethrow;
      } catch (e) {
        throw IntermediateException(e, [key]);
      }
    });

    return map;
  }

  /// Returns a string representation of the expected type for this codec.
  ///
  /// This getter uses the [reflectedType] property of the [type] field
  /// to obtain a string representation of the type that this codec is
  /// expecting to handle. This is useful for generating type-specific
  /// decoding logic or for debugging purposes.
  ///
  /// Returns:
  ///   A [String] representing the name of the expected type.
  String get expectedType {
    return type.reflectedType.toString();
  }

  /// Returns the source code for decoding a value based on its type.
  ///
  /// This getter generates and returns a string containing Dart code that can be used
  /// to decode a value of the type represented by this codec. The returned code varies
  /// depending on the type:
  ///
  /// - For [int], it returns code to parse integers from strings or cast to int.
  /// - For [bool], it returns code to convert strings to booleans or cast to bool.
  /// - For [Configuration] subclasses, it returns code to create and decode a new instance.
  /// - For [List], it returns code to decode each element of the list.
  /// - For [Map], it returns code to decode each value in the map.
  /// - For any other type, it returns code that simply returns the input value unchanged.
  ///
  /// The generated code assumes the input value is named 'v'.
  ///
  /// Returns:
  ///   A [String] containing Dart code for decoding the value.
  String get source {
    if (type.isSubtypeOf(reflectType(int))) {
      return _decodeIntSource;
    } else if (type.isSubtypeOf(reflectType(bool))) {
      return _decodeBoolSource;
    } else if (type.isSubtypeOf(reflectType(Configuration))) {
      return _decodeConfigSource;
    } else if (type.isSubtypeOf(reflectType(List))) {
      return _decodeListSource;
    } else if (type.isSubtypeOf(reflectType(Map))) {
      return _decodeMapSource;
    }

    return "return v;";
  }

  /// Generates source code for decoding a List value.
  ///
  /// This getter creates a string containing Dart code that decodes a List
  /// based on the codec's type parameters. The generated code:
  /// - Creates a new List to store decoded elements.
  /// - Defines an inner decoder function for processing each element.
  /// - Iterates through the input List, decoding each element.
  /// - Handles exceptions, wrapping them in IntermediateException with the index.
  ///
  /// The decoder function uses the source code from the inner codec,
  /// which is based on the first type argument of the List.
  ///
  /// Returns:
  ///   A String containing the Dart code for List decoding.
  String get _decodeListSource {
    final typeParam = MirrorTypeCodec(type.typeArguments.first);
    return """
final out = <${typeParam.expectedType}>[];
final decoder = (v) {
  ${typeParam.source}
};
for (var i = 0; i < (v as List).length; i++) {
  try {
    final innerValue = decoder(v[i]);
    out.add(innerValue);
  } on IntermediateException catch (e) {
    e.keyPath.add(i);
    rethrow;
  } catch (e) {
    throw IntermediateException(e, [i]);
  }
}
return out;
    """;
  }

  /// Generates source code for decoding a Map value.
  ///
  /// This getter creates a string containing Dart code that decodes a Map
  /// based on the codec's type parameters. The generated code:
  /// - Creates a new Map to store decoded key-value pairs.
  /// - Defines an inner decoder function for processing each value.
  /// - Iterates through the input Map, ensuring all keys are Strings.
  /// - Decodes each value using the inner decoder function.
  /// - Handles exceptions, wrapping them in IntermediateException with the key.
  ///
  /// The decoder function uses the source code from the inner codec,
  /// which is based on the last type argument of the Map.
  ///
  /// Returns:
  ///   A String containing the Dart code for Map decoding.
  String get _decodeMapSource {
    final typeParam = MirrorTypeCodec(type.typeArguments.last);
    return """
final map = <String, ${typeParam.expectedType}>{};
final decoder = (v) {
  ${typeParam.source}
};
v.forEach((key, val) {
  if (key is! String) {
    throw StateError('cannot have non-String key');
  }

  try {
    map[key] = decoder(val);
  } on IntermediateException catch (e) {
    e.keyPath.add(key);
    rethrow;
  } catch (e) {
    throw IntermediateException(e, [key]);
  }
});

return map;
    """;
  }

  /// Generates source code for decoding a Configuration object.
  ///
  /// This getter returns a string containing Dart code that:
  /// 1. Creates a new instance of the Configuration subclass represented by [expectedType].
  /// 2. Calls the `decode` method on this new instance, passing in the input value 'v'.
  /// 3. Returns the decoded Configuration object.
  ///
  /// The generated code assumes the input value is named 'v'.
  ///
  /// Returns:
  ///   A [String] containing Dart code for decoding a Configuration object.
  String get _decodeConfigSource {
    return """
    final item = $expectedType();

    item.decode(v);

    return item;
    """;
  }

  /// Generates source code for decoding an integer value.
  ///
  /// This getter returns a string containing Dart code that:
  /// 1. Checks if the input value 'v' is a String.
  /// 2. If it is a String, parses it to an integer using `int.parse()`.
  /// 3. If it's not a String, casts the value directly to an int.
  ///
  /// The generated code assumes the input value is named 'v'.
  ///
  /// Returns:
  ///   A [String] containing Dart code for decoding an integer value.
  String get _decodeIntSource {
    return """
    if (v is String) {
      return int.parse(v);
    }

    return v as int;
""";
  }

  /// Generates source code for decoding a boolean value.
  ///
  /// This getter returns a string containing Dart code that:
  /// 1. Checks if the input value 'v' is a String.
  /// 2. If it is a String, returns true if it equals "true", false otherwise.
  /// 3. If it's not a String, casts the value directly to a bool.
  ///
  /// The generated code assumes the input value is named 'v'.
  ///
  /// Returns:
  ///   A [String] containing Dart code for decoding a boolean value.
  String get _decodeBoolSource {
    return """
    if (v is String) {
      return v == "true";
    }

    return v as bool;
    """;
  }
}

/// Represents a property of a Configuration class, providing metadata and decoding capabilities.
///
/// This class encapsulates information about a single property within a Configuration
/// subclass, including its name, whether it's required, and how to decode its value.
///
/// It uses the [MirrorTypeCodec] to handle the decoding of values based on the property's type.
///
/// Key features:
/// - Extracts the property name from the [VariableMirror].
/// - Determines if the property is required based on its metadata.
/// - Provides access to the decoding logic through the [codec] field.
/// - Offers a method to decode input values, taking into account environment variables.
///
/// Usage:
/// ```dart
/// final property = MirrorConfigurationProperty(someVariableMirror);
/// final decodedValue = property.decode(inputValue);
/// ```
class MirrorConfigurationProperty {
  MirrorConfigurationProperty(this.property)
      : codec = MirrorTypeCodec(property.type);

  final VariableMirror property;
  final MirrorTypeCodec codec;

  String get key => MirrorSystem.getName(property.simpleName);
  bool get isRequired => _isVariableRequired(property);

  String get source => codec.source;

  static bool _isVariableRequired(VariableMirror m) {
    try {
      final attribute = m.metadata
          .firstWhere(
            (im) =>
                im.type.isSubtypeOf(reflectType(ConfigurationItemAttribute)),
          )
          .reflectee as ConfigurationItemAttribute;

      return attribute.type == ConfigurationItemAttributeType.required;
    } catch (_) {
      return false;
    }
  }

  dynamic decode(dynamic input) {
    return codec._decodeValue(Configuration.getEnvironmentOrValue(input));
  }
}
