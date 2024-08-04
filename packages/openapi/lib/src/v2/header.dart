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

/// Represents a header in the OpenAPI specification.
class APIHeader extends APIProperty {
  APIHeader();

  String? description;
  APIProperty? items;

  @override
  void decode(KeyedArchive object) {
    super.decode(object);
    description = object.decode("description");
    if (type == APIType.array) {
      items = object.decodeObject("items", () => APIProperty());
    }
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);
    object.encode("description", description);
    if (type == APIType.array) {
      object.encodeObject("items", items);
    }
  }
}
