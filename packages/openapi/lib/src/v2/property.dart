/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/object.dart';
import 'package:protevus_openapi/v2.dart';

/// Represents the different types of schema representations in an API.
///
/// This enumeration defines the possible structural representations of an API schema:
/// - [primitive]: Represents basic data types like strings, numbers, booleans, etc.
/// - [array]: Represents a list or collection of items.
/// - [object]: Represents a complex type with key-value pairs.
/// - [structure]: Represents a structured data type (e.g., a custom object).
/// - [unknownOrInvalid]: Represents an unknown or invalid schema representation.
enum APISchemaRepresentation {
  primitive,
  array,
  object,
  structure,
  unknownOrInvalid
}

/// Represents the different formats for collection parameters in API requests.
///
/// This enumeration defines the possible formats for serializing array parameters:
/// - [csv]: Comma-separated values (e.g., "foo,bar,baz")
/// - [ssv]: Space-separated values (e.g., "foo bar baz")
/// - [tsv]: Tab-separated values (e.g., "foo\tbar\tbaz")
/// - [pipes]: Pipe-separated values (e.g., "foo|bar|baz")
enum APICollectionFormat { csv, ssv, tsv, pipes }

/// A utility class for encoding and decoding [APICollectionFormat] values.
///
/// This class provides static methods to convert between string representations
/// and [APICollectionFormat] enum values.
/// Decodes a string representation into an [APICollectionFormat] value.
///
/// Takes a [String] input and returns the corresponding [APICollectionFormat],
/// or `null` if the input doesn't match any known format.
///
/// - Returns [APICollectionFormat.csv] for "csv"
/// - Returns [APICollectionFormat.ssv] for "ssv"
/// - Returns [APICollectionFormat.tsv] for "tsv"
/// - Returns [APICollectionFormat.pipes] for "pipes"
/// - Returns `null` for any other input
class APICollectionFormatCodec {
  /// Decodes a string representation into an [APICollectionFormat] value.
  ///
  /// Takes a [String] input and returns the corresponding [APICollectionFormat],
  /// or `null` if the input doesn't match any known format.
  ///
  /// - Returns [APICollectionFormat.csv] for "csv"
  /// - Returns [APICollectionFormat.ssv] for "ssv"
  /// - Returns [APICollectionFormat.tsv] for "tsv"
  /// - Returns [APICollectionFormat.pipes] for "pipes"
  /// - Returns `null` for any other input
  static APICollectionFormat? decode(String? location) {
    switch (location) {
      case "csv":
        return APICollectionFormat.csv;
      case "ssv":
        return APICollectionFormat.ssv;
      case "tsv":
        return APICollectionFormat.tsv;
      case "pipes":
        return APICollectionFormat.pipes;
      default:
        return null;
    }
  }

  /// Encodes an [APICollectionFormat] value into its string representation.
  ///
  /// Takes an [APICollectionFormat] input and returns the corresponding string,
  /// or `null` if the input is null or doesn't match any known format.
  ///
  /// - Returns "csv" for [APICollectionFormat.csv]
  /// - Returns "ssv" for [APICollectionFormat.ssv]
  /// - Returns "tsv" for [APICollectionFormat.tsv]
  /// - Returns "pipes" for [APICollectionFormat.pipes]
  /// - Returns `null` for any other input or null
  static String? encode(APICollectionFormat? location) {
    switch (location) {
      case APICollectionFormat.csv:
        return "csv";
      case APICollectionFormat.ssv:
        return "ssv";
      case APICollectionFormat.tsv:
        return "tsv";
      case APICollectionFormat.pipes:
        return "pipes";
      default:
        return null;
    }
  }
}

/// Represents a property in an API schema.
///
/// This class extends [APIObject] and provides fields and methods to handle
/// various aspects of an API property, including its type, format, constraints,
/// and serialization behavior.
///
/// Properties:
/// - [type]: The data type of the property (e.g., string, number, array).
/// - [format]: Additional format information for the property.
/// - [collectionFormat]: Format for serializing array parameters.
/// - [defaultValue]: Default value for the property.
/// - [maximum]: Maximum value for numeric properties.
/// - [exclusiveMaximum]: Whether the maximum is exclusive.
/// - [minimum]: Minimum value for numeric properties.
/// - [exclusiveMinimum]: Whether the minimum is exclusive.
/// - [maxLength]: Maximum length for string properties.
/// - [minLength]: Minimum length for string properties.
/// - [pattern]: Regular expression pattern for string properties.
/// - [maxItems]: Maximum number of items for array properties.
/// - [minItems]: Minimum number of items for array properties.
/// - [uniqueItems]: Whether array items must be unique.
/// - [multipleOf]: Numeric properties must be multiples of this value.
/// - [enumerated]: List of allowed values for the property.
///
/// The [representation] getter determines the schema representation of the property.
///
/// This class also implements [decode] and [encode] methods for serialization
/// and deserialization of the property data.
class APIProperty extends APIObject {
  /// The data type of the property.
  ///
  /// This field represents the primary type of the API property, such as string,
  /// number, boolean, array, or object. It is defined as nullable to allow for
  /// cases where the type might not be specified.
  ///
  /// The value is of type [APIType], which is likely an enum or similar type
  /// defining the possible data types in the API schema.
  APIType? type;

  /// The format of the property.
  ///
  /// This field provides additional format information for the property.
  /// It can specify more precise data types or constraints, such as:
  /// - For strings: "date", "date-time", "password", etc.
  /// - For numbers: "float", "double", etc.
  ///
  /// The format is optional and can be null if not specified.
  String? format;

  /// The format used for serializing array parameters.
  ///
  /// This property specifies how collection/array parameters are formatted when sent in
  /// API requests. It is applicable only when the [type] is [APIType.array].
  ///
  /// Possible values are defined in the [APICollectionFormat] enum:
  /// - [APICollectionFormat.csv]: Comma-separated values
  /// - [APICollectionFormat.ssv]: Space-separated values
  /// - [APICollectionFormat.tsv]: Tab-separated values
  /// - [APICollectionFormat.pipes]: Pipe-separated values
  ///
  /// If not specified (null), the default format is typically comma-separated.
  APICollectionFormat? collectionFormat;

  /// The default value for the property.
  ///
  /// This field represents the default value that should be used for the property
  /// if no value is provided. It can be of any type (hence the 'dynamic' type),
  /// allowing it to match the property's data type.
  ///
  /// The default value is optional and can be null if not specified.
  dynamic defaultValue;

  /// The maximum value for numeric properties.
  ///
  /// This field specifies the maximum allowed value for numeric properties.
  /// It is applicable when [type] is a numeric type (e.g., integer or number).
  /// The value is inclusive unless [exclusiveMaximum] is set to true.
  ///
  /// This property is optional and can be null if not specified.
  num? maximum;

  /// Indicates whether the maximum value is exclusive.
  ///
  /// When set to `true`, the [maximum] value is treated as an exclusive upper bound.
  /// When `false` or `null`, the [maximum] value is inclusive.
  ///
  /// This property is only applicable when [maximum] is set and [type] is a numeric type.
  bool? exclusiveMaximum;

  /// The minimum value for numeric properties.
  ///
  /// This field specifies the minimum allowed value for numeric properties.
  /// It is applicable when [type] is a numeric type (e.g., integer or number).
  /// The value is inclusive unless [exclusiveMinimum] is set to true.
  ///
  /// This property is optional and can be null if not specified.
  num? minimum;

  /// Indicates whether the minimum value is exclusive.
  ///
  /// When set to `true`, the [minimum] value is treated as an exclusive lower bound.
  /// When `false` or `null`, the [minimum] value is inclusive.
  ///
  /// This property is only applicable when [minimum] is set and [type] is a numeric type.
  bool? exclusiveMinimum;

  /// The maximum length for string properties.
  ///
  /// This field specifies the maximum allowed length for string properties.
  /// It is applicable when [type] is [APIType.string].
  ///
  /// The value is an integer representing the maximum number of characters allowed.
  /// If not specified (null), there is no upper limit on the string length.
  int? maxLength;

  /// The minimum length for string properties.
  ///
  /// This field specifies the minimum allowed length for string properties.
  /// It is applicable when [type] is [APIType.string].
  ///
  /// The value is an integer representing the minimum number of characters required.
  /// If not specified (null), there is no lower limit on the string length.
  int? minLength;

  /// The regular expression pattern for string properties.
  ///
  /// This field specifies a regular expression that a string property must match.
  /// It is applicable when [type] is [APIType.string].
  ///
  /// The pattern is represented as a string containing a valid regular expression.
  /// If not specified (null), no pattern matching is enforced on the string value.
  String? pattern;

  /// The maximum number of items for array properties.
  ///
  /// This field specifies the maximum allowed number of items in an array property.
  /// It is applicable when [type] is [APIType.array].
  ///
  /// The value is an integer representing the maximum number of elements allowed in the array.
  /// If not specified (null), there is no upper limit on the number of array items.
  int? maxItems;

  /// The minimum number of items for array properties.
  ///
  /// This field specifies the minimum required number of items in an array property.
  /// It is applicable when [type] is [APIType.array].
  ///
  /// The value is an integer representing the minimum number of elements required in the array.
  /// If not specified (null), there is no lower limit on the number of array items.
  int? minItems;

  /// Indicates whether array items must be unique.
  ///
  /// This field specifies whether all items in an array property must be unique.
  /// It is applicable when [type] is [APIType.array].
  ///
  /// When set to `true`, all elements in the array must be unique.
  /// When `false` or `null`, duplicate elements are allowed in the array.
  ///
  /// This property is optional and can be null if not specified.
  bool? uniqueItems;

  /// Specifies that numeric properties must be multiples of this value.
  ///
  /// This field is applicable when [type] is a numeric type (e.g., integer or number).
  /// If set, the value of the property must be divisible by this number.
  ///
  /// For example, if [multipleOf] is set to 2, valid values could be 0, 2, 4, -2, etc.
  ///
  /// This property is optional and can be null if not specified.
  num? multipleOf;

  /// A list of allowed values for the property.
  ///
  /// This field specifies a list of valid values that the property can take.
  /// It is applicable to properties of various types, including strings, numbers, and more.
  ///
  /// When set, the value of the property must be one of the items in this list.
  /// If not specified (null), there are no restrictions on the allowed values.
  ///
  /// The list is of type `dynamic` to accommodate different data types that may be used
  /// for the enumeration values, depending on the property's type.
  List<dynamic>? enumerated;

  /// Determines the schema representation of the property.
  ///
  /// This getter analyzes the [type] of the property and returns the corresponding
  /// [APISchemaRepresentation]:
  /// - Returns [APISchemaRepresentation.array] if the type is [APIType.array]
  /// - Returns [APISchemaRepresentation.object] if the type is [APIType.object]
  /// - Returns [APISchemaRepresentation.primitive] for all other types
  ///
  /// This representation helps in categorizing and handling different property types
  /// in API schemas.
  ///
  /// Returns: An [APISchemaRepresentation] value indicating the schema representation.
  APISchemaRepresentation get representation {
    if (type == APIType.array) {
      return APISchemaRepresentation.array;
    } else if (type == APIType.object) {
      return APISchemaRepresentation.object;
    }

    return APISchemaRepresentation.primitive;
  }

  /// Decodes the property information from a [KeyedArchive] object.
  ///
  /// This method populates the fields of the [APIProperty] instance with values
  /// decoded from the given [KeyedArchive] object. It decodes various properties
  /// such as type, format, constraints, and other metadata associated with the API property.
  ///
  /// The method first calls the superclass's decode method, then decodes specific
  /// fields for the [APIProperty] class. Each field is extracted from the archive
  /// using its corresponding key.
  ///
  /// Parameters:
  ///   [object] - A [KeyedArchive] containing the encoded property information.
  ///
  /// Note: This method assumes that the [KeyedArchive] contains keys matching
  /// the property names of the [APIProperty] class.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    type = APITypeCodec.decode(object.decode("type"));
    format = object.decode("format");
    collectionFormat =
        APICollectionFormatCodec.decode(object.decode("collectionFormat"));
    defaultValue = object.decode("default");
    maximum = object.decode("maximum");
    exclusiveMaximum = object.decode("exclusiveMaximum");
    minimum = object.decode("minimum");
    exclusiveMinimum = object.decode("exclusiveMinimum");
    maxLength = object.decode("maxLength");
    minLength = object.decode("minLength");
    pattern = object.decode("pattern");
    maxItems = object.decode("maxItems");
    minItems = object.decode("minItems");
    uniqueItems = object.decode("uniqueItems");
    multipleOf = object.decode("multipleOf");
    enumerated = object.decode("enum");
  }

  /// Encodes the property information into a [KeyedArchive] object.
  ///
  /// This method serializes the fields of the [APIProperty] instance into the given
  /// [KeyedArchive] object. It encodes various properties such as type, format,
  /// constraints, and other metadata associated with the API property.
  ///
  /// The method first calls the superclass's encode method, then encodes specific
  /// fields of the [APIProperty] class. Each field is added to the archive
  /// using its corresponding key.
  ///
  /// Parameters:
  ///   [object] - A [KeyedArchive] to store the encoded property information.
  ///
  /// Note: This method encodes all fields of the [APIProperty] class, including
  /// null values. The receiving end should handle potential null values appropriately.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("type", APITypeCodec.encode(type));
    object.encode("format", format);
    object.encode(
      "collectionFormat",
      APICollectionFormatCodec.encode(collectionFormat),
    );
    object.encode("default", defaultValue);
    object.encode("maximum", maximum);
    object.encode("exclusiveMaximum", exclusiveMaximum);
    object.encode("minimum", minimum);
    object.encode("exclusiveMinimum", exclusiveMinimum);
    object.encode("maxLength", maxLength);
    object.encode("minLength", minLength);
    object.encode("pattern", pattern);
    object.encode("maxItems", maxItems);
    object.encode("minItems", minItems);
    object.encode("uniqueItems", uniqueItems);
    object.encode("multipleOf", multipleOf);
    object.encode("enum", enumerated);
  }
}
