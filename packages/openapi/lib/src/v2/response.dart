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
class APIResponse extends APIObject {
  APIResponse();

  String? description = "";
  APISchemaObject? schema;
  Map<String, APIHeader?>? headers = {};

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    description = object.decode("description");
    schema = object.decodeObject("schema", () => APISchemaObject());
    headers = object.decodeObjectMap("headers", () => APIHeader());
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObjectMap("headers", headers);
    object.encodeObject("schema", schema);
    object.encode("description", description);
  }
}
