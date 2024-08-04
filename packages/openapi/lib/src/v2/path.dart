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

/// Represents a path (also known as a route) in the OpenAPI specification.
class APIPath extends APIObject {
  APIPath();

  List<APIParameter?> parameters = [];
  Map<String, APIOperation?> operations = {};

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

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encodeObjects("parameters", parameters);
    operations.forEach((opName, op) {
      object.encodeObject(opName, op);
    });
  }
}
