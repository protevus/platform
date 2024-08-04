/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/v2.dart';

/// Enum representing the possible locations of a parameter in an API request.
///
/// The possible values are:
/// - [query]: Parameter is passed as a query parameter in the URL
/// - [header]: Parameter is included in the request headers
/// - [path]: Parameter is part of the URL path
/// - [formData]: Parameter is sent as form data in the request body
/// - [body]: Parameter is sent in the request body (typically as JSON)
enum APIParameterLocation { query, header, path, formData, body }

/// A utility class for encoding and decoding [APIParameterLocation] enum values.
class APIParameterLocationCodec {
  /// Decodes a string representation of an API parameter location into an [APIParameterLocation] enum value.
  ///
  /// This method takes a [String] parameter [location] and returns the corresponding
  /// [APIParameterLocation] enum value. If the input string doesn't match any known
  /// location, the method returns null.
  ///
  /// Parameters:
  ///   [location] - A string representing the API parameter location.
  ///
  /// Returns:
  ///   The corresponding [APIParameterLocation] enum value, or null if no match is found.
  static APIParameterLocation? decode(String? location) {
    switch (location) {
      case "query":
        return APIParameterLocation.query;
      case "header":
        return APIParameterLocation.header;
      case "path":
        return APIParameterLocation.path;
      case "formData":
        return APIParameterLocation.formData;
      case "body":
        return APIParameterLocation.body;
      default:
        return null;
    }
  }

  /// Encodes an [APIParameterLocation] enum value into its string representation.
  ///
  /// This method takes an [APIParameterLocation] enum value as input and returns
  /// the corresponding string representation. If the input is null or doesn't
  /// match any known location, the method returns null.
  ///
  /// Parameters:
  ///   [location] - An [APIParameterLocation] enum value to be encoded.
  ///
  /// Returns:
  ///   A [String] representing the API parameter location, or null if the input is null or invalid.
  static String? encode(APIParameterLocation? location) {
    switch (location) {
      case APIParameterLocation.query:
        return "query";
      case APIParameterLocation.header:
        return "header";
      case APIParameterLocation.path:
        return "path";
      case APIParameterLocation.formData:
        return "formData";
      case APIParameterLocation.body:
        return "body";
      default:
        return null;
    }
  }
}

/// Represents a parameter in the OpenAPI specification.
///
/// This class extends [APIProperty] and provides additional functionality
/// specific to API parameters. It includes properties such as name, description,
/// required status, and location of the parameter.
///
/// The class supports two main parameter types:
/// 1. Body parameters: When [location] is [APIParameterLocation.body], it uses
///    [schema] to define the parameter structure.
/// 2. Non-body parameters: For all other locations, it uses properties inherited
///    from [APIProperty] and adds [allowEmptyValue] and [items] for array types.
///
/// The class implements [Codable] through its superclass, providing [decode] and
/// [encode] methods for serialization and deserialization.
class APIParameter extends APIProperty {
  /// Default constructor for [APIParameter].
  ///
  /// Creates a new instance of [APIParameter] with default values.
  /// All properties are initialized to their default values as defined in the class.
  APIParameter();

  /// The name of the API parameter.
  ///
  /// This property represents the name of the parameter as defined in the API specification.
  /// It can be null if the name is not specified or not applicable.
  String? name;

  /// A description of the API parameter.
  ///
  /// This property provides additional information about the parameter,
  /// explaining its purpose, expected format, or any other relevant details.
  /// It can be null if no description is provided.
  String? description;

  /// Indicates whether the parameter is required.
  ///
  /// This boolean property determines if the API parameter is mandatory (true) or optional (false).
  /// By default, it is set to false, meaning the parameter is optional unless specified otherwise.
  bool isRequired = false;

  /// The location of the API parameter.
  ///
  /// This property specifies where the parameter should be placed in the API request.
  /// It can be one of the following values from the [APIParameterLocation] enum:
  /// - [APIParameterLocation.query]: Parameter is included in the URL query string
  /// - [APIParameterLocation.header]: Parameter is included in the request headers
  /// - [APIParameterLocation.path]: Parameter is part of the URL path
  /// - [APIParameterLocation.formData]: Parameter is sent as form data in the request body
  /// - [APIParameterLocation.body]: Parameter is sent in the request body (typically as JSON)
  ///
  /// The location can be null if it's not specified or not applicable.
  APIParameterLocation? location;

  /// The schema object for the API parameter.
  ///
  /// This property is used when the [location] is [APIParameterLocation.body].
  /// It defines the structure and validation rules for the parameter in the request body.
  /// The schema is represented as an [APISchemaObject], which can describe complex
  /// data structures including nested objects and arrays.
  ///
  /// This property is null for parameters that are not in the body location.
  APISchemaObject? schema;

  /// Indicates whether an empty value is allowed for this parameter.
  ///
  /// This property is only applicable for non-body parameters (i.e., when [location] is not [APIParameterLocation.body]).
  /// When set to true, it allows the parameter to be sent with an empty value.
  /// By default, it is set to false, meaning empty values are not allowed unless explicitly specified.
  bool allowEmptyValue = false;

  /// Represents the items of an array-type parameter.
  ///
  /// This property is only used when [type] is [APIType.array]. It defines the
  /// schema for the items in the array. The [APIProperty] object describes the
  /// structure and validation rules for each item in the array.
  ///
  /// This property is null for non-array parameters or when not specified.
  APIProperty? items;

  /// Decodes the parameter from a [KeyedArchive] object.
  ///
  /// This method populates the properties of the [APIParameter] instance
  /// by decoding values from the provided [KeyedArchive] object. It handles
  /// both body and non-body parameters differently:
  ///
  /// For all parameters:
  /// - Decodes 'name', 'description', and 'in' (location) properties.
  /// - Sets 'isRequired' based on the location or the 'required' field.
  ///
  /// For body parameters ([APIParameterLocation.body]):
  /// - Decodes the 'schema' object.
  ///
  /// For non-body parameters:
  /// - Calls the superclass decode method to handle common properties.
  /// - Decodes 'allowEmptyValue'.
  /// - For array types, decodes the 'items' property.
  ///
  /// Parameters:
  ///   [object] - The [KeyedArchive] containing the encoded parameter data.
  @override
  void decode(KeyedArchive object) {
    name = object.decode("name");
    description = object.decode("description");
    location = APIParameterLocationCodec.decode(object.decode("in"));
    if (location == APIParameterLocation.path) {
      isRequired = true;
    } else {
      isRequired = object.decode("required") ?? false;
    }

    if (location == APIParameterLocation.body) {
      schema = object.decodeObject("schema", () => APISchemaObject());
    } else {
      super.decode(object);
      allowEmptyValue = object.decode("allowEmptyValue") ?? false;
      if (type == APIType.array) {
        items = object.decodeObject("items", () => APIProperty());
      }
    }
  }

  /// Encodes the parameter into a [KeyedArchive] object.
  ///
  /// This method serializes the properties of the [APIParameter] instance
  /// into the provided [KeyedArchive] object. It handles both body and
  /// non-body parameters differently:
  ///
  /// For all parameters:
  /// - Encodes 'name', 'description', 'in' (location), and 'required' properties.
  ///
  /// For body parameters ([APIParameterLocation.body]):
  /// - Encodes the 'schema' object.
  ///
  /// For non-body parameters:
  /// - Calls the superclass encode method to handle common properties.
  /// - Encodes 'allowEmptyValue' if it's true.
  /// - For array types, encodes the 'items' property.
  ///
  /// Parameters:
  ///   [object] - The [KeyedArchive] to store the encoded parameter data.
  @override
  void encode(KeyedArchive object) {
    object.encode("name", name);
    object.encode("description", description);
    object.encode("in", APIParameterLocationCodec.encode(location));
    object.encode("required", isRequired);

    if (location == APIParameterLocation.body) {
      object.encodeObject("schema", schema);
    } else {
      super.encode(object);
      if (allowEmptyValue) {
        object.encode("allowEmptyValue", allowEmptyValue);
      }
      if (type == APIType.array) {
        object.encodeObject("items", items);
      }
    }
  }
}
