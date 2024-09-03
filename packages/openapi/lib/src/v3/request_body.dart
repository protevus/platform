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

/// Describes a single request body in an API specification.
///
/// This class represents a request body as defined in the OpenAPI Specification.
/// It includes information about the content of the request body, an optional
/// description, and whether the request body is required.
///
/// The class provides three constructors:
/// - A default constructor that takes content, description, and isRequired.
/// - An empty constructor.
/// - A schema constructor that creates a request body from a schema object.
///
/// The class also implements encoding and decoding methods for serialization.
class APIRequestBody extends APIObject {
  /// Creates a new [APIRequestBody] instance.
  ///
  /// [content] is a required parameter that represents the content of the request body.
  /// It's a map where keys are media types and values are [APIMediaType] objects.
  ///
  /// [description] is an optional parameter that provides a brief description of the request body.
  ///
  /// [isRequired] is an optional parameter that determines if the request body is required in the request.
  /// It defaults to false if not specified.
  APIRequestBody(this.content, {this.description, this.isRequired = false});

  /// Creates an empty [APIRequestBody] instance.
  ///
  /// This constructor initializes a new [APIRequestBody] with no content,
  /// description, or required status. It can be used as a placeholder or
  /// when you need to create an instance that will be populated later.
  APIRequestBody.empty();

  /// Creates an [APIRequestBody] instance from a schema object.
  ///
  /// This constructor initializes a new [APIRequestBody] using an [APISchemaObject].
  ///
  /// Parameters:
  /// - [schema]: An [APISchemaObject] that defines the structure of the request body.
  /// - [contentTypes]: An iterable of strings representing the content types for the request body.
  ///   Defaults to ["application/json"].
  /// - [description]: An optional description of the request body.
  /// - [isRequired]: A boolean indicating whether the request body is required. Defaults to false.
  ///
  /// The constructor creates a [content] map where each content type in [contentTypes]
  /// is associated with an [APIMediaType] object containing the provided [schema].
  APIRequestBody.schema(
    APISchemaObject schema, {
    Iterable<String> contentTypes = const ["application/json"],
    this.description,
    this.isRequired = false,
  }) {
    content = contentTypes.fold({}, (prev, elem) {
      prev![elem] = APIMediaType(schema: schema);
      return prev;
    });
  }

  /// A brief description of the request body.
  ///
  /// This property provides a short explanation of the request body's purpose or content.
  /// It can include examples of how to use the request body.
  ///
  /// The description supports CommonMark syntax for rich text formatting,
  /// allowing for more detailed and structured explanations.
  ///
  /// This field is optional and can be null if no description is provided.
  String? description;

  /// The content of the request body.
  ///
  /// This property is a map where the keys are media types or media type ranges,
  /// and the values are [APIMediaType] objects describing the content.
  ///
  /// REQUIRED. The content must be provided for the request body to be valid.
  ///
  /// For requests that match multiple keys, only the most specific key is applicable.
  /// For example, 'text/plain' would override 'text/*'.
  ///
  /// Example:
  /// ```dart
  /// content = {
  ///   'application/json': APIMediaType(...),
  ///   'text/plain': APIMediaType(...),
  /// };
  /// ```
  ///
  /// Note: Despite being marked as nullable (Map<String, APIMediaType?>?),
  /// this property is required for a valid APIRequestBody. The nullability
  /// is likely for serialization purposes.
  Map<String, APIMediaType?>? content;

  /// Determines if the request body is required in the request.
  ///
  /// This boolean property indicates whether the request body is mandatory for the API request.
  /// When set to true, the client must include the request body in the API call.
  /// When set to false, the request body is optional.
  ///
  /// In the OpenAPI Specification, this corresponds to the 'required' field of the Request Body Object.
  ///
  /// Defaults to false, meaning the request body is optional unless explicitly set to true.
  bool isRequired = false;

  /// Decodes the [APIRequestBody] object from a [KeyedArchive].
  ///
  /// This method overrides the [decode] method from the superclass and is responsible
  /// for populating the properties of the [APIRequestBody] instance from the provided
  /// [KeyedArchive] object.
  ///
  /// The method performs the following actions:
  /// 1. Calls the superclass's decode method.
  /// 2. Decodes the 'description' field from the archive.
  /// 3. Decodes the 'required' field, defaulting to false if not present.
  /// 4. Decodes the 'content' field as an object map of [APIMediaType] instances.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] containing the encoded [APIRequestBody] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    description = object.decode("description");
    isRequired = object.decode("required") ?? false;
    content = object.decodeObjectMap("content", () => APIMediaType());
  }

  /// Encodes the [APIRequestBody] object into a [KeyedArchive].
  ///
  /// This method overrides the [encode] method from the superclass and is responsible
  /// for encoding the properties of the [APIRequestBody] instance into the provided
  /// [KeyedArchive] object.
  ///
  /// The method performs the following actions:
  /// 1. Calls the superclass's encode method.
  /// 2. Checks if the 'content' property is null, throwing an ArgumentError if it is.
  /// 3. Encodes the 'description' field into the archive.
  /// 4. Encodes the 'required' field into the archive.
  /// 5. Encodes the 'content' field as an object map into the archive.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] where the encoded [APIRequestBody] data will be stored.
  ///
  /// Throws:
  /// - [ArgumentError]: If the 'content' property is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (content == null) {
      throw ArgumentError(
        "APIRequestBody must have non-null values for: 'content'.",
      );
    }

    object.encode("description", description);
    object.encode("required", isRequired);
    object.encodeObjectMap("content", content);
  }
}
