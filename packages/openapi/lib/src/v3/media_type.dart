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

/// Represents a media type in an API specification.
///
/// An [APIMediaType] object provides schema and encoding information for a specific media type.
/// It is typically used in OpenAPI specifications to describe the structure and format of request
/// or response bodies for different content types.
///
/// The [schema] property defines the structure of the media type content, while the [encoding]
/// property provides additional information about how to encode specific properties, particularly
/// useful for multipart and application/x-www-form-urlencoded media types.
///
/// This class extends [APIObject] and implements [Codable] for serialization and deserialization.
/// The [decode] and [encode] methods are overridden to handle the specific properties of this class.
/// Each [APIMediaType] provides schema and examples for the media type identified by its key.
class APIMediaType extends APIObject {
  /// Creates an [APIMediaType] instance.
  ///
  /// [schema] is an optional [APISchemaObject] that defines the structure of the media type content.
  /// [encoding] is an optional [Map] that provides additional information about how to encode specific properties.
  ///
  /// This constructor allows for the creation of an [APIMediaType] with or without a schema and encoding information.
  APIMediaType({this.schema, this.encoding});

  /// Creates an empty [APIMediaType] instance.
  ///
  /// This constructor initializes an [APIMediaType] with no schema or encoding information.
  /// It can be used when you need to create a placeholder or default media type object
  /// that will be populated later.
  APIMediaType.empty();

  /// The schema defining the type used for the request body.
  ///
  /// This property holds an optional [APISchemaObject] that describes the structure
  /// and constraints of the data for this media type. It defines the expected format,
  /// types, and validation rules for the request body when this media type is used.
  /// If not specified, it indicates that the structure of the request body is not strictly defined
  /// or is described elsewhere in the API specification.
  APISchemaObject? schema;

  /// A map between a property name and its encoding information.
  ///
  /// This property holds an optional [Map] where each key is a property name and each value
  /// is an [APIEncoding] object providing encoding information for that property.
  ///
  /// The key, being the property name, MUST exist in the schema as a property. The encoding
  /// object SHALL only apply to requestBody objects when the media type is multipart or
  /// application/x-www-form-urlencoded.
  ///
  /// This map is particularly useful for specifying additional metadata about the encoding
  /// of specific properties within the media type, such as content type, headers, or style
  /// when dealing with complex data structures in request bodies.
  ///
  /// If this property is null or empty, it indicates that no specific encoding information
  /// is provided for the properties of this media type.
  Map<String, APIEncoding?>? encoding;

  /// Decodes the [APIMediaType] object from a [KeyedArchive].
  ///
  /// This method overrides the [decode] method from the superclass and is responsible for
  /// populating the properties of the [APIMediaType] object from the given [KeyedArchive].
  ///
  /// It performs the following operations:
  /// 1. Calls the superclass's decode method to handle any inherited properties.
  /// 2. Decodes the "schema" field into an [APISchemaObject], if present.
  /// 3. Decodes the "encoding" field into a Map of [String] to [APIEncoding], if present.
  ///
  /// [object] is the [KeyedArchive] containing the encoded data for this [APIMediaType].
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    schema = object.decodeObject("schema", () => APISchemaObject());
    encoding = object.decodeObjectMap("encoding", () => APIEncoding());
  }

  /// Encodes the [APIMediaType] object into a [KeyedArchive].
  ///
  /// This method overrides the [encode] method from the superclass and is responsible for
  /// serializing the properties of the [APIMediaType] object into the given [KeyedArchive].
  ///
  /// It performs the following operations:
  /// 1. Calls the superclass's encode method to handle any inherited properties.
  /// 2. Encodes the "schema" field from the [APISchemaObject], if present.
  /// 3. Encodes the "encoding" field as a Map of [String] to [APIEncoding], if present.
  ///
  /// [object] is the [KeyedArchive] where the encoded data for this [APIMediaType] will be stored.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObject("schema", schema);
    object.encodeObjectMap("encoding", encoding);
  }
}
