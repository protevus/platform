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

/// Each [APIMediaType] provides schema and examples for the media type identified by its key.
class APIMediaType extends APIObject {
  APIMediaType({this.schema, this.encoding});
  APIMediaType.empty();

  /// The schema defining the type used for the request body.
  APISchemaObject? schema;

  /// A map between a property name and its encoding information.
  ///
  /// The key, being the property name, MUST exist in the schema as a property. The encoding object SHALL only apply to requestBody objects when the media type is multipart or application/x-www-form-urlencoded.
  Map<String, APIEncoding?>? encoding;

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    schema = object.decodeObject("schema", () => APISchemaObject());
    encoding = object.decodeObjectMap("encoding", () => APIEncoding());
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObject("schema", schema);
    object.encodeObjectMap("encoding", encoding);
  }
}
