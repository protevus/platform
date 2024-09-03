/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/v3.dart';

/// Represents an API Header in OpenAPI specifications.
///
/// name MUST NOT be specified, it is given in the corresponding headers map.
/// in MUST NOT be specified, it is implicitly in header.
/// All traits that are affected by the location MUST be applicable to a location of header (for example, style).
class APIHeader extends APIParameter {
  /// Creates an [APIHeader] instance.
  ///
  /// This constructor initializes an [APIHeader] with an optional [schema].
  /// The [schema] parameter is of type [APISchemaObject] and defines the
  /// structure and constraints of the header value.
  ///
  /// The constructor calls the superclass constructor [super.header] with
  /// a null name and the provided schema.
  APIHeader({APISchemaObject? schema}) : super.header(null, schema: schema);

  /// Creates an empty [APIHeader] instance.
  ///
  /// This constructor initializes an [APIHeader] without specifying a schema.
  /// It calls the superclass constructor [super.header] with a null name and
  /// no schema, resulting in an empty header definition.
  APIHeader.empty() : super.header(null);

  /// Encodes the [APIHeader] object into a [KeyedArchive].
  ///
  /// This method overrides the superclass's encode method to handle the specific
  /// encoding requirements of an API header. It performs the following steps:
  /// 1. Temporarily sets the 'name' property to "temporary".
  /// 2. Calls the superclass's encode method to perform the base encoding.
  /// 3. Removes the "name" and "in" keys from the encoded object, as these
  ///    are not required for API headers in OpenAPI specifications.
  /// 4. Resets the 'name' property to null.
  ///
  /// This approach ensures that the header is correctly encoded while adhering
  /// to OpenAPI specifications for headers.
  ///
  /// [object] The [KeyedArchive] to encode the header information into.
  @override
  void encode(KeyedArchive object) {
    name = "temporary";
    super.encode(object);
    object.remove("name");
    object.remove("in");
    name = null;
  }
}
