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

/// Represents an HTTP response in the OpenAPI specification.
///
/// This class extends [APIObject] and provides properties and methods to
/// handle the response description, schema, and headers.
///
/// Properties:
/// - [description]: A string describing the response.
/// - [schema]: An [APISchemaObject] representing the structure of the response body.
/// - [headers]: A map of response headers, where keys are header names and values are [APIHeader] objects.
///
/// The class includes methods for encoding and decoding the response object
/// to and from a [KeyedArchive].
class APIResponse extends APIObject {
  /// Creates a new instance of [APIResponse].
  ///
  /// This constructor initializes a new [APIResponse] object with default values.
  /// The [description] is set to an empty string, [schema] is null,
  /// and [headers] is an empty map.
  APIResponse();

  /// A string describing the response.
  ///
  /// This property holds a brief description of the API response.
  /// It provides context about what the response represents or contains.
  /// The description is optional and defaults to an empty string if not specified.
  String? description = "";

  /// Represents the structure of the response body.
  ///
  /// This property is of type [APISchemaObject] and defines the schema
  /// for the response payload. It describes the structure, types, and
  /// constraints of the data returned in the response body.
  ///
  /// The schema can be null if the response doesn't have a body or if
  /// the schema is not defined in the API specification.
  APISchemaObject? schema;

  /// A map of response headers.
  ///
  /// This property is a [Map] where the keys are header names (strings) and the values
  /// are [APIHeader] objects or null. It represents the headers that are expected
  /// to be included in the API response.
  ///
  /// The map is nullable and initialized as an empty map by default. Each header
  /// in the map can also be null, allowing for optional headers in the response.
  Map<String, APIHeader?>? headers = {};

  /// Decodes the [APIResponse] object from a [KeyedArchive].
  ///
  /// This method overrides the [decode] method from the superclass and is responsible
  /// for populating the properties of the [APIResponse] object from the given [KeyedArchive].
  ///
  /// It performs the following actions:
  /// 1. Calls the superclass's decode method.
  /// 2. Decodes the 'description' field into the [description] property.
  /// 3. Decodes the 'schema' field into the [schema] property, creating a new [APISchemaObject] if necessary.
  /// 4. Decodes the 'headers' field into the [headers] property, creating new [APIHeader] objects as needed.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] containing the encoded data for the [APIResponse].
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    description = object.decode("description");
    schema = object.decodeObject("schema", () => APISchemaObject());
    headers = object.decodeObjectMap("headers", () => APIHeader());
  }

  /// Encodes the [APIResponse] object into a [KeyedArchive].
  ///
  /// This method overrides the [encode] method from the superclass and is responsible
  /// for encoding the properties of the [APIResponse] object into the given [KeyedArchive].
  ///
  /// It performs the following actions:
  /// 1. Calls the superclass's encode method.
  /// 2. Encodes the [headers] property into the 'headers' field of the archive.
  /// 3. Encodes the [schema] property into the 'schema' field of the archive.
  /// 4. Encodes the [description] property into the 'description' field of the archive.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] to store the encoded data of the [APIResponse].
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObjectMap("headers", headers);
    object.encodeObject("schema", schema);
    object.encode("description", description);
  }
}
