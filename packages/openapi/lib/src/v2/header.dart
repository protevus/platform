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

/// A class representing an API header in the OpenAPI specification.
///
/// This class extends [APIProperty] and provides additional functionality
/// specific to API headers. It includes properties for description and items
/// (for array types), as well as methods for encoding and decoding the header
/// object.
///
/// Properties:
///   - description: A string describing the header.
///   - items: An [APIProperty] object representing the items in an array (only used when type is array).
///
/// The class overrides the [decode] and [encode] methods from [APIProperty]
/// to handle the specific properties of an API header.
class APIHeader extends APIProperty {
  /// Default constructor for the APIHeader class.
  ///
  /// Creates a new instance of APIHeader without initializing any properties.
  /// Properties can be set after instantiation or through the decode method.
  APIHeader();

  /// A string that provides a brief description of the header.
  ///
  /// This property can be used to give more context or explanation about
  /// the purpose and usage of the header in the API documentation.
  String? description;

  /// An [APIProperty] object representing the items in an array.
  ///
  /// This property is only used when the [type] is set to [APIType.array].
  /// It describes the structure and properties of the individual items
  /// within the array. The [items] property can be null if not applicable.
  APIProperty? items;

  /// Decodes the APIHeader object from a [KeyedArchive].
  ///
  /// This method overrides the [decode] method from [APIProperty] to handle
  /// the specific properties of an API header.
  ///
  /// It performs the following operations:
  /// 1. Calls the superclass decode method to handle common properties.
  /// 2. Decodes the 'description' field from the archive.
  /// 3. If the header type is an array, it decodes the 'items' field as an APIProperty.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] containing the encoded header data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);
    description = object.decode("description");
    if (type == APIType.array) {
      items = object.decodeObject("items", () => APIProperty());
    }
  }

  /// Encodes the APIHeader object into a [KeyedArchive].
  ///
  /// This method overrides the [encode] method from [APIProperty] to handle
  /// the specific properties of an API header.
  ///
  /// It performs the following operations:
  /// 1. Calls the superclass encode method to handle common properties.
  /// 2. Encodes the 'description' field into the archive.
  /// 3. If the header type is an array, it encodes the 'items' field as an APIProperty.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] where the encoded header data will be stored.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);
    object.encode("description", description);
    if (type == APIType.array) {
      object.encodeObject("items", items);
    }
  }
}
