/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/cast.dart' as cast;
import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/v2.dart';

/// Represents a schema object in the OpenAPI specification.
class APISchemaObject extends APIProperty {
  APISchemaObject();

  String? title;
  String? description;
  String? example;
  List<String?>? isRequired = [];
  bool readOnly = false;

  /// Valid when type == array
  APISchemaObject? items;

  /// Valid when type == null
  Map<String, APISchemaObject?>? properties;

  /// Valid when type == object
  APISchemaObject? additionalProperties;

  @override
  APISchemaRepresentation get representation {
    if (properties != null) {
      return APISchemaRepresentation.structure;
    }

    return super.representation;
  }

  @override
  Map<String, cast.Cast> get castMap =>
      {"required": const cast.List(cast.string)};

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    title = object.decode("title");
    description = object.decode("description");
    isRequired = object.decode("required");
    example = object.decode("example");
    readOnly = object.decode("readOnly") ?? false;

    items = object.decodeObject("items", () => APISchemaObject());
    additionalProperties =
        object.decodeObject("additionalProperties", () => APISchemaObject());
    properties = object.decodeObjectMap("properties", () => APISchemaObject());
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("title", title);
    object.encode("description", description);
    object.encode("required", isRequired);
    object.encode("example", example);
    object.encode("readOnly", readOnly);

    object.encodeObject("items", items);
    object.encodeObject("additionalProperties", additionalProperties);
    object.encodeObjectMap("properties", properties);
  }
}
