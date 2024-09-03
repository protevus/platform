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

/// Represents an API response as defined in the OpenAPI Specification.
///
/// This class models a single response from an API operation, including its description,
/// headers, and content. It provides methods to add headers and content, as well as
/// functionality to encode and decode the response object.
///
/// The [description] field is required and provides a short description of the response.
/// The [headers] field is a map of header names to their definitions.
/// The [content] field is a map of media types to their corresponding media type objects.
///
/// This class also includes utility methods:
/// - [addHeader]: Adds a header to the response
/// - [addContent]: Adds content to the response for a specific content type
///
/// The class implements [Codable] for easy serialization and deserialization.
class APIResponse extends APIObject {
  /// Creates a new [APIResponse] instance.
  ///
  /// [description] is a required parameter that provides a short description of the response.
  /// [content] is an optional parameter that represents a map of media types to their corresponding media type objects.
  /// [headers] is an optional parameter that represents a map of header names to their definitions.
  ///
  /// Example:
  /// ```dart
  /// var response = APIResponse(
  ///   'Successful response',
  ///   content: {'application/json': APIMediaType(schema: someSchema)},
  ///   headers: {'X-Rate-Limit': APIHeader()},
  /// );
  /// ```
  APIResponse(this.description, {this.content, this.headers});

  /// Creates an empty [APIResponse] instance.
  ///
  /// This constructor initializes an [APIResponse] without any predefined values.
  /// It can be useful when you need to create an empty response object that will be
  /// populated later or when you want to start with a blank slate.
  ///
  /// Example:
  /// ```dart
  /// var emptyResponse = APIResponse.empty();
  /// // Later, populate the response as needed
  /// emptyResponse.description = 'A description';
  /// emptyResponse.addContent('application/json', someSchemaObject);
  /// ```
  APIResponse.empty();

  /// Creates an [APIResponse] instance with a schema.
  ///
  /// This constructor initializes an [APIResponse] with a given [description] and [schema].
  /// It allows specifying multiple content types for the same schema.
  ///
  /// [description] is a required parameter that provides a short description of the response.
  /// [schema] is the [APISchemaObject] that defines the structure of the response body.
  /// [contentTypes] is an optional iterable of content type strings. It defaults to ["application/json"].
  /// [headers] is an optional parameter that represents a map of header names to their definitions.
  ///
  /// The constructor creates a [content] map where each content type in [contentTypes]
  /// is associated with an [APIMediaType] containing the provided [schema].
  ///
  /// Example:
  /// ```dart
  /// var response = APIResponse.schema(
  ///   'Successful response',
  ///   someSchemaObject,
  ///   contentTypes: ['application/json', 'application/xml'],
  ///   headers: {'X-Rate-Limit': APIHeader()},
  /// );
  /// ```
  APIResponse.schema(
    this.description,
    APISchemaObject schema, {
    Iterable<String> contentTypes = const ["application/json"],
    this.headers,
  }) {
    content = contentTypes.fold({}, (prev, elem) {
      prev![elem] = APIMediaType(schema: schema);
      return prev;
    });
  }

  /// A short description of the response.
  ///
  /// This property is REQUIRED according to the OpenAPI Specification.
  /// It provides a brief explanation of the API response.
  ///
  /// The description can use CommonMark syntax for rich text representation,
  /// allowing for formatted text, links, and other markup features.
  ///
  /// Example:
  /// ```dart
  /// var response = APIResponse('Successful response with user data');
  /// ```
  ///
  /// Note: While the property is marked as nullable (String?), it is a required
  /// field in the OpenAPI Specification and should be provided when creating
  /// an APIResponse object.
  String? description;

  /// Maps a header name to its definition.
  ///
  /// This property represents a map of HTTP headers that may be part of the API response.
  /// Each key in the map is a header name (case-insensitive), and the corresponding value
  /// is an [APIHeader] object that defines the header's properties.
  ///
  /// According to RFC7230, header names are case-insensitive. It's important to note that
  /// if a response header is defined with the name "Content-Type", it SHALL be ignored.
  /// This is because the content type is typically handled separately in API specifications.
  ///
  /// The map is nullable, allowing for responses that don't include any custom headers.
  ///
  /// Example:
  /// ```dart
  /// var response = APIResponse('Success');
  /// response.headers = {
  ///   'X-Rate-Limit': APIHeader(description: 'Calls per hour allowed by the user'),
  ///   'X-Expires-After': APIHeader(description: 'Date in UTC when token expires')
  /// };
  /// ```
  Map<String, APIHeader?>? headers;

  /// A map containing descriptions of potential response payloads.
  ///
  /// This property represents the content of the API response for different media types.
  /// The key is a media type or media type range (e.g., 'application/json', 'text/*'),
  /// and the value is an [APIMediaType] object describing the content for that media type.
  ///
  /// For responses that match multiple keys, only the most specific key is applicable.
  /// For example, 'text/plain' would override 'text/*'.
  ///
  /// This property is nullable, allowing for responses that don't include any content.
  ///
  /// Example:
  /// ```dart
  /// var response = APIResponse('Success');
  /// response.content = {
  ///   'application/json': APIMediaType(schema: someJsonSchema),
  ///   'application/xml': APIMediaType(schema: someXmlSchema)
  /// };
  /// ```
  Map<String, APIMediaType?>? content;

  // Currently missing:
  // links

  /// Adds a header to the [headers] map of the API response.
  ///
  /// If [headers] is null, it is created. If the key does not exist in [headers], [header] is added for the key.
  /// If the key exists, [header] is not added. (To replace a header, access [headers] directly.)
  void addHeader(String name, APIHeader? header) {
    headers ??= {};
    if (!headers!.containsKey(name)) {
      headers![name] = header;
    }
  }

  /// Adds a [bodyObject] to [content] for a specific content type.
  ///
  /// [contentType] must take the form 'primaryType/subType', e.g. 'application/json'. Do not include charsets.
  ///
  /// If [content] is null, it is created. If [contentType] does not exist in [content], [bodyObject] is added for [contentType].
  /// If [contentType] exists, the [bodyObject] is added the list of possible schemas that were previously added.
  void addContent(String contentType, APISchemaObject? bodyObject) {
    content ??= {};

    final key = contentType;
    final existingContent = content![key];
    if (existingContent == null) {
      content![key] = APIMediaType(schema: bodyObject);
      return;
    }

    final schema = existingContent.schema;
    if (schema?.oneOf != null) {
      schema!.oneOf!.add(bodyObject);
    } else {
      final container = APISchemaObject()..oneOf = [schema, bodyObject];
      existingContent.schema = container;
    }
  }

  /// Decodes the [APIResponse] object from a [KeyedArchive].
  ///
  /// This method is part of the [Codable] interface implementation. It populates
  /// the properties of the [APIResponse] object from a [KeyedArchive] object,
  /// which typically represents a serialized form of the response.
  ///
  /// The method performs the following actions:
  /// 1. Calls the superclass's decode method to handle any inherited properties.
  /// 2. Decodes the 'description' field from the archive.
  /// 3. Decodes the 'content' field as a map of [APIMediaType] objects.
  /// 4. Decodes the 'headers' field as a map of [APIHeader] objects.
  ///
  /// [object] is the [KeyedArchive] containing the encoded [APIResponse] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    description = object.decode("description");
    content = object.decodeObjectMap("content", () => APIMediaType());
    headers = object.decodeObjectMap("headers", () => APIHeader());
  }

  /// Encodes the [APIResponse] object into a [KeyedArchive].
  ///
  /// This method is part of the [Codable] interface implementation. It serializes
  /// the properties of the [APIResponse] object into a [KeyedArchive] object,
  /// which can then be used for storage or transmission.
  ///
  /// The method performs the following actions:
  /// 1. Calls the superclass's encode method to handle any inherited properties.
  /// 2. Checks if the 'description' field is non-null, throwing an [ArgumentError] if it's null.
  /// 3. Encodes the 'description' field into the archive.
  /// 4. Encodes the 'headers' field as a map of [APIHeader] objects.
  /// 5. Encodes the 'content' field as a map of [APIMediaType] objects.
  ///
  /// [object] is the [KeyedArchive] where the [APIResponse] data will be encoded.
  ///
  /// Throws an [ArgumentError] if the 'description' field is null, as it's a required field.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (description == null) {
      throw ArgumentError(
        "APIResponse must have non-null values for: 'description'.",
      );
    }

    object.encode("description", description);
    object.encodeObjectMap("headers", headers);
    object.encodeObjectMap("content", content);
  }
}
