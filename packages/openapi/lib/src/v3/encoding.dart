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

/// A single encoding definition applied to a single schema property.
///
/// This class represents an encoding definition as specified in the OpenAPI Specification.
/// It provides details about how a specific property should be serialized when sent as
/// part of a request body, particularly for multipart requests or application/x-www-form-urlencoded
/// request bodies.
///
/// Properties:
/// - [contentType]: Specifies the Content-Type for encoding a specific property.
/// - [headers]: Additional headers that may be sent with the request.
/// - [allowReserved]: Determines if reserved characters should be percent-encoded.
/// - [explode]: Controls how arrays and objects are serialized.
/// - [style]: Describes how a specific property value will be serialized.
///
/// This class extends [APIObject] and implements [Codable] for serialization and deserialization.
class APIEncoding extends APIObject {
  /// Creates a new [APIEncoding] instance.
  ///
  /// Parameters:
  /// - [contentType]: The Content-Type for encoding a specific property.
  /// - [headers]: A map of additional headers to be included with the request.
  /// - [style]: Describes how a specific property value will be serialized.
  /// - [allowReserved]: Determines if reserved characters should be percent-encoded. Defaults to false.
  /// - [explode]: Controls how arrays and objects are serialized. Defaults to false.
  APIEncoding({
    this.contentType,
    this.headers,
    this.style,
    this.allowReserved = false,
    this.explode = false,
  });

  /// Creates an empty [APIEncoding] instance with default values.
  ///
  /// This constructor initializes an [APIEncoding] with [allowReserved] and [explode]
  /// set to false. All other properties are left uninitialized.
  APIEncoding.empty()
      : allowReserved = false,
        explode = false;

  /// The Content-Type for encoding a specific property.
  ///
  /// Specifies the media type to be used for encoding this property when sending the request body.
  /// The default value depends on the property type:
  /// - For string with format being binary: application/octet-stream
  /// - For other primitive types: text/plain
  /// - For object: application/json
  /// - For array: defined based on the inner type
  ///
  /// The value can be:
  /// - A specific media type (e.g., application/json)
  /// - A wildcard media type (e.g., image/*)
  /// - A comma-separated list of the above types
  ///
  /// This property is particularly relevant for multipart request bodies and
  /// application/x-www-form-urlencoded request bodies.
  String? contentType;

  /// A map allowing additional information to be provided as headers, for example Content-Disposition.
  ///
  /// Content-Type is described separately and SHALL be ignored in this section. This property SHALL be ignored if the request body media type is not a multipart.
  ///
  /// This map represents a collection of headers associated with the encoding. Each key in the map
  /// is a header name, and the corresponding value is an [APIHeader] object that defines the header's
  /// properties. These headers provide supplementary information for the encoded content.
  ///
  /// Note:
  /// - The Content-Type header is handled separately and should not be included in this map.
  /// - This property is only applicable for multipart request body media types. It will be ignored
  ///   for other media types.
  ///
  /// Example usage:
  /// ```dart
  /// headers = {
  ///   "Content-Disposition": APIHeader(description: "Specifies the filename for the uploaded file"),
  ///   "X-Custom-Header": APIHeader(description: "A custom header for additional metadata")
  /// };
  /// ```
  Map<String, APIHeader?>? headers;

  /// Determines whether the parameter value should allow reserved characters without percent-encoding.
  ///
  /// The default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
  bool? allowReserved;

  /// Determines how array and object properties are serialized in form-style parameters.
  ///
  /// For other types of properties this property has no effect. When style is form, the default value is true. For all other styles, the default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
  bool? explode;

  /// Describes how a specific property value will be serialized depending on its type.
  ///
  /// This property specifies the serialization style for the encoded value. It follows the same
  /// behavior and values as the style property for query parameters in [APIParameter].
  ///
  /// The style affects how the property is serialized, especially for complex types like arrays
  /// and objects. Common values include:
  /// - 'form': comma-separated values for arrays (default for application/x-www-form-urlencoded)
  /// - 'spaceDelimited': space-separated values for arrays
  /// - 'pipeDelimited': pipe-separated values for arrays
  /// - 'deepObject': for nested objects
  ///
  /// Note:
  /// - This property is only applicable when the request body media type is
  ///   application/x-www-form-urlencoded. It will be ignored for other media types.
  /// - If not specified, the default style depends on the parameter type and the media type
  ///   of the request body.
  ///
  /// See [APIParameter] for more detailed information on style values and their effects.
  String? style;

  /// Decodes the [APIEncoding] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIEncoding]
  /// instance from the provided [KeyedArchive] object. It decodes each property
  /// using the appropriate key and method from the archive.
  ///
  /// The following properties are decoded:
  /// - [contentType]: The Content-Type for encoding a specific property.
  /// - [headers]: A map of additional headers to be included with the request.
  /// - [allowReserved]: Determines if reserved characters should be percent-encoded.
  /// - [explode]: Controls how arrays and objects are serialized.
  /// - [style]: Describes how a specific property value will be serialized.
  ///
  /// This method also calls the superclass's decode method to handle any inherited properties.
  ///
  /// Parameters:
  /// - [object]: The [KeyedArchive] containing the encoded data for this [APIEncoding] instance.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    contentType = object.decode("contentType");
    headers = object.decodeObjectMap("headers", () => APIHeader());
    allowReserved = object.decode("allowReserved");
    explode = object.decode("explode");
    style = object.decode("style");
  }

  /// Encodes the [APIEncoding] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APIEncoding]
  /// instance into the provided [KeyedArchive] object. It encodes each property
  /// using the appropriate key and method for the archive.
  ///
  /// The following properties are encoded:
  /// - [contentType]: The Content-Type for encoding a specific property.
  /// - [headers]: A map of additional headers to be included with the request.
  /// - [allowReserved]: Determines if reserved characters should be percent-encoded.
  /// - [explode]: Controls how arrays and objects are serialized.
  /// - [style]: Describes how a specific property value will be serialized.
  ///
  /// This method also calls the superclass's encode method to handle any inherited properties.
  ///
  /// Parameters:
  /// - [object]: The [KeyedArchive] where the encoded data for this [APIEncoding] instance will be stored.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("contentType", contentType);
    object.encodeObjectMap("headers", headers);
    object.encode("allowReserved", allowReserved);
    object.encode("explode", explode);
    object.encode("style", style);
  }
}
