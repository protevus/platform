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

/// Represents an API path in the OpenAPI specification.
///
/// This class extends [APIObject] and provides functionality to decode and encode
/// API path information, including parameters and operations.
///
/// Properties:
/// - [parameters]: A list of [APIParameter] objects associated with this path.
/// - [operations]: A map of operation names to [APIOperation] objects for this path.
///
/// The [decode] method populates the object from a [KeyedArchive], handling parameters
/// and operations separately. The [encode] method serializes the object back into
/// a [KeyedArchive].
///
/// Note: The handling of '$ref' keys is currently a todo item.
class APIPath extends APIObject {
  /// Creates a new instance of [APIPath].
  ///
  /// This constructor initializes an empty [APIPath] object.
  /// The [parameters] list and [operations] map are initialized as empty
  /// and can be populated later using the [decode] method or by directly
  /// adding elements.
  APIPath();

  /// A list of API parameters associated with this path.
  ///
  /// This list contains [APIParameter] objects that define the parameters
  /// applicable to all operations on this path. These parameters can include
  /// path parameters, query parameters, header parameters, etc.
  ///
  /// Note: The list can contain null values, hence the use of [APIParameter?].
  List<APIParameter?> parameters = [];

  /// A map of operation names to [APIOperation] objects for this path.
  ///
  /// This map contains the HTTP methods (e.g., 'get', 'post', 'put', 'delete')
  /// as keys, and their corresponding [APIOperation] objects as values.
  ///
  /// Each [APIOperation] describes the details of the API operation for that
  /// specific HTTP method on this path.
  ///
  /// The use of [APIOperation?] allows for null values in the map.
  Map<String, APIOperation?> operations = {};

  /// Decodes the [APIPath] object from a [KeyedArchive].
  ///
  /// This method populates the [APIPath] object with data from the provided [KeyedArchive].
  /// It handles the following cases:
  /// - If a key is "$ref", it's currently not implemented (todo).
  /// - If a key is "parameters", it decodes a list of [APIParameter] objects.
  /// - For all other keys, it assumes they are operation names and decodes them as [APIOperation] objects.
  ///
  /// The decoded parameters are stored in the [parameters] list, while the operations
  /// are stored in the [operations] map with their corresponding keys.
  ///
  /// [object] is the [KeyedArchive] containing the encoded [APIPath] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    for (final k in object.keys) {
      if (k == r"$ref") {
        // todo: reference
      } else if (k == "parameters") {
        parameters = object.decodeObjects(k, () => APIParameter())!;
      } else {
        operations[k] = object.decodeObject(k, () => APIOperation());
      }
    }
  }

  /// Encodes the [APIPath] object into a [KeyedArchive].
  ///
  /// This method serializes the [APIPath] object's data into the provided [KeyedArchive].
  /// It performs the following operations:
  /// - Calls the superclass's encode method to handle any base class properties.
  /// - Encodes the [parameters] list into the archive under the key "parameters".
  /// - Iterates through the [operations] map, encoding each operation into the archive
  ///   using its operation name as the key.
  ///
  /// [object] is the [KeyedArchive] where the encoded data will be stored.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObjects("parameters", parameters);
    operations.forEach((opName, op) {
      object.encodeObject(opName, op);
    });
  }
}
