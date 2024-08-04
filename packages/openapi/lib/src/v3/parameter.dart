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
import 'package:protevus_openapi/v3.dart';

/// Enumerates the possible locations for parameters in an API request.
///
/// - path:
/// - query:
/// - header:
/// - cookie:
enum APIParameterLocation {
  /// Parameters that are appended to the URL.
  ///
  /// For example, in /items?id=###, the query parameter is id.
  ///
  /// Query parameters are used to filter, sort, or provide additional
  /// information for the requested resource. They appear after the question
  /// mark (?) in the URL and are separated by ampersands (&) if there are
  /// multiple parameters.
  query,

  /// Custom headers that are expected as part of the request.
  ///
  /// Headers are additional metadata sent with an HTTP request or response.
  /// They provide information about the request or response, such as content type,
  /// authentication tokens, or caching directives.
  ///
  /// Examples of common headers include:
  /// - Content-Type: Specifies the media type of the resource
  /// - Authorization: Contains credentials for authenticating the client
  /// - User-Agent: Identifies the client software making the request
  ///
  /// Note that RFC7230 states header names are case insensitive.
  header,

  /// Used together with Path Templating, where the parameter value is actually part of the operation's URL.
  ///
  /// This does not include the host or base path of the API. For example, in /items/{itemId}, the path parameter is itemId.
  ///
  /// Path parameters are used to identify a specific resource or resources. They are part of the URL path and are typically
  /// used to specify the ID of a resource. Path parameters are always required, as they are necessary to construct the full URL.
  ///
  /// Examples:
  /// - /users/{userId}: 'userId' is a path parameter
  /// - /posts/{postId}/comments/{commentId}: both 'postId' and 'commentId' are path parameters
  ///
  /// When defining an API, path parameters are denoted by curly braces {} in the URL template.
  path,

  /// Used to pass a specific cookie value to the API.
  ///
  /// Cookie parameters are used to send data to the server using HTTP cookies.
  /// They are typically used for maintaining session state, tracking user preferences,
  /// or passing authentication tokens.
  ///
  /// Cookie parameters are sent in the Cookie HTTP header. Unlike query parameters,
  /// cookie parameters are not visible in the URL and are sent with every request
  /// to the domain that set the cookie.
  ///
  /// Example of a cookie header:
  /// Cookie: session_id=abc123; user_preference=dark_mode
  ///
  /// Note: Use of cookies should be done with consideration for security and privacy implications.
  cookie
}

/// A utility class for encoding and decoding [APIParameterLocation] values.
///
/// This class provides two static methods:
/// - [decode]: Converts a string representation of a parameter location to an [APIParameterLocation] enum value.
/// - [encode]: Converts an [APIParameterLocation] enum value to its string representation.
///
/// Both methods handle null values gracefully, returning null if the input is null or not recognized.
///
/// Usage:
/// ```dart
/// // Decoding a string to APIParameterLocation
/// APIParameterLocation? location = APIParameterLocationCodec.decode("query");
/// print(location); // Output: APIParameterLocation.query
///
/// // Encoding an APIParameterLocation to a string
/// String? locationString = APIParameterLocationCodec.encode(APIParameterLocation.path);
/// print(locationString); // Output: "path"
/// ```
///
/// This class is particularly useful when working with API specifications or
/// when serializing/deserializing API parameter location data.
class APIParameterLocationCodec {
  /// Decodes a string representation of a parameter location to an [APIParameterLocation] enum value.
  ///
  /// Returns:
  ///   The corresponding [APIParameterLocation] enum value, or null if not recognized.
  static APIParameterLocation? decode(String? location) {
    switch (location) {
      case "query":
        return APIParameterLocation.query;
      case "header":
        return APIParameterLocation.header;
      case "path":
        return APIParameterLocation.path;
      case "cookie":
        return APIParameterLocation.cookie;
      default:
        return null;
    }
  }

  /// Encodes an [APIParameterLocation] enum value to its string representation.
  ///
  /// This method takes an [APIParameterLocation] enum value [location] and returns
  /// the corresponding string representation. If the input is null or not recognized,
  /// the method returns null.
  ///
  /// Supported [APIParameterLocation] values and their string representations:
  /// - [APIParameterLocation.query] returns "query"
  /// - [APIParameterLocation.header] returns "header"
  /// - [APIParameterLocation.path] returns "path"
  /// - [APIParameterLocation.cookie] returns "cookie"
  ///
  /// Parameters:
  ///   [location] - An [APIParameterLocation] enum value to be encoded.
  ///
  /// Returns:
  ///   A [String] representation of the [APIParameterLocation], or null if not recognized.
  static String? encode(APIParameterLocation? location) {
    switch (location) {
      case APIParameterLocation.query:
        return "query";
      case APIParameterLocation.header:
        return "header";
      case APIParameterLocation.path:
        return "path";
      case APIParameterLocation.cookie:
        return "cookie";
      default:
        return null;
    }
  }
}

/// Describes a single operation parameter in an API specification.
///
/// A unique parameter is defined by a combination of a [name] and [location].
class APIParameter extends APIObject {
  /// Creates an [APIParameter] instance.
  ///
  /// Parameters:
  /// - [name]: The name of the parameter.
  /// - [location]: The location of the parameter (query, header, path, or cookie).
  /// - [description]: A brief description of the parameter.
  /// - [schema]: The schema defining the type used for the parameter.
  /// - [content]: A map containing the representations for the parameter.
  /// - [style]: Describes how the parameter value will be serialized.
  /// - [isRequired]: Determines whether this parameter is mandatory.
  /// - [deprecated]: Specifies that a parameter is deprecated.
  /// - [allowEmptyValue]: Sets the ability to pass empty-valued parameters.
  /// - [explode]: When true, generates separate parameters for each value of array or object.
  /// - [allowReserved]: Determines whether the parameter value should allow reserved characters.
  APIParameter(
    this.name,
    this.location, {
    this.description,
    this.schema,
    this.content,
    this.style,
    bool? isRequired,
    this.deprecated,
    this.allowEmptyValue,
    this.explode,
    this.allowReserved,
  }) : _required = isRequired;

  /// Creates an empty [APIParameter] instance.
  ///
  /// This constructor initializes an [APIParameter] without setting any properties.
  /// It can be useful when you need to create a parameter object and set its
  /// properties later, or when you want to create a placeholder parameter.
  ///
  /// Example usage:
  /// ```dart
  /// var emptyParameter = APIParameter.empty();
  /// // Properties can be set later
  /// emptyParameter.name = 'exampleParam';
  /// emptyParameter.location = APIParameterLocation.query;
  /// ```
  APIParameter.empty();

  /// Creates an [APIParameter] instance for a header parameter.
  ///
  /// This constructor initializes an [APIParameter] with the location set to [APIParameterLocation.header].
  ///
  /// Parameters:
  /// - [name]: The name of the header parameter.
  /// - [description]: Optional. A brief description of the parameter.
  /// - [schema]: Optional. The schema defining the type used for the parameter.
  /// - [content]: Optional. A map containing the representations for the parameter.
  /// - [style]: Optional. Describes how the parameter value will be serialized.
  /// - [isRequired]: Optional. Determines whether this parameter is mandatory.
  /// - [deprecated]: Optional. Specifies that a parameter is deprecated.
  /// - [allowEmptyValue]: Optional. Sets the ability to pass empty-valued parameters.
  /// - [explode]: Optional. When true, generates separate parameters for each value of array or object.
  /// - [allowReserved]: Optional. Determines whether the parameter value should allow reserved characters.
  APIParameter.header(
    this.name, {
    this.description,
    this.schema,
    this.content,
    this.style,
    bool? isRequired,
    this.deprecated,
    this.allowEmptyValue,
    this.explode,
    this.allowReserved,
  }) : _required = isRequired {
    location = APIParameterLocation.header;
  }

  /// Creates an [APIParameter] instance for a query parameter.
  ///
  /// This constructor initializes an [APIParameter] with the location set to [APIParameterLocation.query].
  ///
  /// Parameters:
  /// - [name]: The name of the query parameter.
  /// - [description]: Optional. A brief description of the parameter.
  /// - [schema]: Optional. The schema defining the type used for the parameter.
  /// - [content]: Optional. A map containing the representations for the parameter.
  /// - [style]: Optional. Describes how the parameter value will be serialized.
  /// - [isRequired]: Optional. Determines whether this parameter is mandatory.
  /// - [deprecated]: Optional. Specifies that a parameter is deprecated.
  /// - [allowEmptyValue]: Optional. Sets the ability to pass empty-valued parameters.
  /// - [explode]: Optional. When true, generates separate parameters for each value of array or object.
  /// - [allowReserved]: Optional. Determines whether the parameter value should allow reserved characters.
  APIParameter.query(
    this.name, {
    this.description,
    this.schema,
    this.content,
    this.style,
    bool? isRequired,
    this.deprecated,
    this.allowEmptyValue,
    this.explode,
    this.allowReserved,
  }) : _required = isRequired {
    location = APIParameterLocation.query;
  }

  /// Creates an [APIParameter] instance for a path parameter.
  ///
  /// This constructor initializes an [APIParameter] with the following properties:
  /// - [location] is set to [APIParameterLocation.path]
  /// - [schema] is set to a string schema using [APISchemaObject.string()]
  /// - [_required] is set to true, as path parameters are always required
  ///
  /// Parameters:
  /// - [name]: The name of the path parameter.
  ///
  /// Usage:
  /// ```dart
  /// var pathParam = APIParameter.path('userId');
  /// ```
  APIParameter.path(this.name)
      : location = APIParameterLocation.path,
        schema = APISchemaObject.string(),
        _required = true;

  /// Creates an [APIParameter] instance for a cookie parameter.
  ///
  /// This constructor initializes an [APIParameter] with the location set to [APIParameterLocation.cookie].
  ///
  /// Parameters:
  /// - [name]: The name of the cookie parameter.
  /// - [description]: Optional. A brief description of the parameter.
  /// - [schema]: Optional. The schema defining the type used for the parameter.
  /// - [content]: Optional. A map containing the representations for the parameter.
  /// - [style]: Optional. Describes how the parameter value will be serialized.
  /// - [isRequired]: Optional. Determines whether this parameter is mandatory.
  /// - [deprecated]: Optional. Specifies that a parameter is deprecated.
  /// - [allowEmptyValue]: Optional. Sets the ability to pass empty-valued parameters.
  /// - [explode]: Optional. When true, generates separate parameters for each value of array or object.
  /// - [allowReserved]: Optional. Determines whether the parameter value should allow reserved characters.
  APIParameter.cookie(
    this.name, {
    this.description,
    this.schema,
    this.content,
    this.style,
    bool? isRequired,
    this.deprecated,
    this.allowEmptyValue,
    this.explode,
    this.allowReserved,
  }) : _required = isRequired {
    location = APIParameterLocation.cookie;
  }

  /// The name of the parameter.
  ///
  /// This property is REQUIRED for all parameters. The name is case sensitive and must be unique within the parameter list.
  ///
  /// Specific behavior based on the parameter location:
  /// - If [location] is "path", the name MUST correspond to a path segment in the [APIDocument.paths] field.
  /// - If [location] is "header" and the name is "Accept", "Content-Type", or "Authorization", the parameter definition will be ignored.
  /// - For all other cases, the name corresponds to the parameter name used by the [location] property.
  ///
  /// See Path Templating in the OpenAPI Specification for more information on path parameters.
  ///
  /// Note: This field is nullable in the class definition, but should be non-null when used in a valid API specification.
  String? name;

  /// A brief description of the parameter.
  ///
  /// This property provides a short explanation of the parameter's purpose, usage, or any other relevant information.
  /// It can include examples to illustrate how the parameter should be used.
  ///
  /// The description supports CommonMark syntax, allowing for rich text formatting such as bold, italic, lists, and more.
  /// This enables clear and structured documentation of the parameter.
  ///
  /// Example:
  /// ```
  /// description: "The **user's age** in years. Must be a positive integer."
  /// ```
  ///
  /// Note: This property is optional but highly recommended for clear API documentation.
  String? description;

  /// Determines whether this parameter is mandatory.
  ///
  /// This property is implemented as a getter and setter pair.
  ///
  /// The getter:
  /// - Returns true if the parameter location is "path", regardless of the value of _required.
  /// - Otherwise, returns the value of _required.
  ///
  /// The setter:
  /// - Sets the value of _required to the provided boolean value.
  ///
  /// Note: If the parameter location is "path", this property is REQUIRED and its value MUST be true.
  /// For other locations, the property MAY be included and its default value is false.
  bool? get isRequired =>
      location == APIParameterLocation.path ? true : _required;

  set isRequired(bool? f) {
    _required = f;
  }

  /// Stores the required status of the parameter.
  ///
  /// This private field is used to back the [isRequired] property.
  /// It's nullable to allow for cases where the required status is not explicitly set.
  ///
  /// Note: For path parameters, this value is ignored as they are always required.
  /// For other parameter types, if not set, it defaults to false.
  bool? _required;

  /// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage.
  ///
  /// When set to true, it indicates that the parameter is deprecated and consumers of the API
  /// should refrain from using it. This allows API providers to gradually phase out parameters
  /// while maintaining backward compatibility.
  ///
  /// Default value is false (not deprecated) when not specified.
  ///
  /// Example usage:
  /// ```dart
  /// var parameter = APIParameter('oldParam', APIParameterLocation.query);
  /// parameter.deprecated = true;
  /// ```
  bool? deprecated;

  /// The location of the parameter.
  ///
  /// This property specifies where the parameter is expected to be found in the API request.
  /// It is a REQUIRED field for all parameter objects.
  ///
  /// The value must be one of the following:
  /// - "query": The parameter is part of the query string in the URL.
  /// - "header": The parameter is included as an HTTP header.
  /// - "path": The parameter is part of the URL path.
  /// - "cookie": The parameter is sent as an HTTP cookie.
  ///
  /// This field uses the [APIParameterLocation] enum to ensure type safety and
  /// to restrict the possible values to the allowed set.
  ///
  /// Note: Although this field is nullable in the class definition, it should always
  /// be set to a non-null value when used in a valid API specification.
  APIParameterLocation? location;

  /// The schema defining the type used for the parameter.
  ///
  /// This property defines the structure and constraints of the parameter value.
  /// It can specify the data type, format, validation rules, and other characteristics
  /// of the parameter.
  ///
  /// The schema is represented by an [APISchemaObject], which allows for detailed
  /// specification of simple types (like strings or integers) as well as complex
  /// structures (like objects or arrays).
  ///
  /// This property is mutually exclusive with the [content] property. When using
  /// [schema], the serialization rules for the parameter are defined by the
  /// [style] and [explode] fields.
  ///
  /// Example usage:
  /// ```dart
  /// parameter.schema = APISchemaObject.string(format: 'email');
  /// ```
  APISchemaObject? schema;

  /// Sets the ability to pass empty-valued parameters.
  ///
  /// This property is only applicable for query parameters and allows sending a parameter with an empty value.
  /// The default value is false.
  ///
  /// Note: If [style] is used, and if the behavior is not applicable (cannot be serialized),
  /// the value of [allowEmptyValue] SHALL be ignored.
  ///
  /// Example usage:
  /// ```dart
  /// var parameter = APIParameter('queryParam', APIParameterLocation.query);
  /// parameter.allowEmptyValue = true;
  /// ```
  bool? allowEmptyValue = false;

  /// Describes how the parameter value will be serialized depending on the type of the parameter value.
  ///
  /// This property determines the format in which the parameter value should be serialized when sent in the request.
  /// The appropriate serialization method depends on both the parameter's location and its data type.
  ///
  /// Default values (based on the value of 'in' property):
  /// - For query parameters: "form"
  /// - For path parameters: "simple"
  /// - For header parameters: "simple"
  /// - For cookie parameters: "form"
  ///
  /// Possible values include:
  /// - "matrix"
  /// - "label"
  /// - "form"
  /// - "simple"
  /// - "spaceDelimited"
  /// - "pipeDelimited"
  /// - "deepObject"
  ///
  /// The exact behavior and applicability of each style depend on the parameter's location and data type.
  /// Refer to the OpenAPI Specification for detailed information on how each style affects serialization.
  String? style;

  /// Specifies whether array or object parameters should be expanded into multiple parameters.
  ///
  /// For other types of parameters this property has no effect. When style is form, the default value is true. For all other styles, the default value is false.
  bool? explode = false;

  /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding.
  ///
  /// This property only applies to parameters with an 'in' value of query. The default value is false.
  ///
  /// When set to true, reserved characters in the parameter value are allowed to be included without percent-encoding.
  /// This can be useful in cases where you want to pass special characters directly in the query string.
  ///
  /// Example:
  /// If allowReserved is true, a query parameter like "filter=name:John/age:30" could be sent as-is.
  /// If false, it would need to be encoded as "filter=name%3AJohn%2Fage%3A30".
  ///
  /// Note: Use this property with caution, as it may affect how the server interprets the parameter value.
  /// It's recommended to keep this false unless you have a specific reason to allow reserved characters.
  bool? allowReserved = false;

  /// A map containing the representations for the parameter.
  ///
  /// The key is a media type and the value describes it. The map MUST only contain one entry.
  ///
  /// This property is mutually exclusive with the [schema] property. It can be used to describe
  /// complex parameter structures or to specify alternative representations of the parameter value.
  ///
  /// The media type (key) should be a string representing the MIME type of the content,
  /// such as "application/json" or "text/plain".
  ///
  /// Each [APIMediaType] value provides detailed information about the content,
  /// including its schema, examples, and encoding properties.
  ///
  /// Example usage:
  /// ```dart
  /// parameter.content = {
  ///   'application/json': APIMediaType(
  ///     schema: APISchemaObject.object({
  ///       'name': APISchemaObject.string(),
  ///       'age': APISchemaObject.integer(),
  ///     })
  ///   )
  /// };
  /// ```
  ///
  /// Note: While the map allows for multiple entries, according to the OpenAPI Specification,
  /// it MUST only contain one entry for parameter objects.
  Map<String, APIMediaType?>? content;

  /// Decodes an [APIParameter] object from a [KeyedArchive].
  ///
  /// This method populates the properties of the [APIParameter] instance
  /// by decoding values from the provided [KeyedArchive] object.
  ///
  /// The following properties are decoded:
  /// - name: The name of the parameter
  /// - description: A brief description of the parameter
  /// - location: The location of the parameter (query, header, path, or cookie)
  /// - _required: Whether the parameter is required
  /// - deprecated: Whether the parameter is deprecated
  /// - allowEmptyValue: Whether empty values are allowed for this parameter
  /// - schema: The schema defining the type used for the parameter
  /// - style: Describes how the parameter value will be serialized
  /// - explode: Whether to expand array or object parameters
  /// - allowReserved: Whether the parameter value should allow reserved characters
  /// - content: A map containing the representations for the parameter
  ///
  /// Note: This method does not currently decode 'example' and 'examples' properties.
  ///
  /// Parameters:
  ///   object: The [KeyedArchive] containing the encoded [APIParameter] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name");
    description = object.decode("description");
    location = APIParameterLocationCodec.decode(object.decode("in"));
    _required = object.decode("required");

    deprecated = object.decode("deprecated");
    allowEmptyValue = object.decode("allowEmptyValue");

    schema = object.decodeObject("schema", () => APISchemaObject());
    style = object.decode("style");
    explode = object.decode("explode");
    allowReserved = object.decode("allowReserved");
    content = object.decodeObjectMap("content", () => APIMediaType());
  }

  /// Encodes the [APIParameter] object into a [KeyedArchive].
  ///
  /// This method serializes the properties of the [APIParameter] instance
  /// into the provided [KeyedArchive] object for storage or transmission.
  ///
  /// The following properties are encoded:
  /// - name: The name of the parameter
  /// - description: A brief description of the parameter
  /// - location: The location of the parameter (query, header, path, or cookie)
  /// - required: Whether the parameter is required (always true for path parameters)
  /// - deprecated: Whether the parameter is deprecated
  /// - allowEmptyValue: Whether empty values are allowed (only for query parameters)
  /// - schema: The schema defining the type used for the parameter
  /// - style: Describes how the parameter value will be serialized
  /// - explode: Whether to expand array or object parameters
  /// - allowReserved: Whether the parameter value should allow reserved characters
  /// - content: A map containing the representations for the parameter
  ///
  /// This method also performs a validation check to ensure that both 'name'
  /// and 'location' properties are non-null. If either of these properties
  /// is null, it throws an [ArgumentError].
  ///
  /// Parameters:
  ///   object: The [KeyedArchive] where the encoded data will be stored.
  ///
  /// Throws:
  ///   ArgumentError: If either 'name' or 'location' is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (name == null || location == null) {
      throw ArgumentError(
        "APIParameter must have non-null values for: 'name', 'location'.",
      );
    }

    object.encode("name", name);
    object.encode("description", description);
    object.encode("in", APIParameterLocationCodec.encode(location));

    if (location == APIParameterLocation.path) {
      object.encode("required", true);
    } else {
      object.encode("required", _required);
    }

    object.encode("deprecated", deprecated);

    if (location == APIParameterLocation.query) {
      object.encode("allowEmptyValue", allowEmptyValue);
    }

    object.encodeObject("schema", schema);
    object.encode("style", style);
    object.encode("explode", explode);
    object.encode("allowReserved", allowReserved);
    object.encodeObjectMap("content", content);
  }
}
