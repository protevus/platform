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
import 'package:protevus_openapi/object.dart';
import 'package:protevus_openapi/v2.dart';

/// Represents a HTTP operation (a path/method pair) in the OpenAPI specification.
class APIOperation extends APIObject {
  APIOperation();

  @override
  Map<String, cast.Cast> get castMap => {
        "tags": const cast.List(cast.string),
        "consumes": const cast.List(cast.string),
        "produces": const cast.List(cast.string),
        "schemes": const cast.List(cast.string),
        "security":
            const cast.List(cast.Map(cast.string, cast.List(cast.string))),
      };

  String? summary = "";
  String? description = "";
  String? id;
  bool? deprecated;

  List<String?>? tags = [];
  List<String?>? schemes = [];
  List<String?>? consumes = [];
  List<String?>? produces = [];
  List<APIParameter?>? parameters = [];
  List<Map<String, List<String>>?>? security = [];
  Map<String, APIResponse?>? responses = {};

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    tags = object.decode("tags");
    summary = object.decode("summary");
    description = object.decode("description");
    id = object.decode("operationId");
    consumes = object.decode("consumes");
    produces = object.decode("produces");
    deprecated = object.decode("deprecated");
    parameters = object.decodeObjects("parameters", () => APIParameter());
    responses = object.decodeObjectMap("responses", () => APIResponse());
    schemes = object.decode("schemes");
    security = object.decode("security");
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("tags", tags);
    object.encode("summary", summary);
    object.encode("description", description);
    object.encode("operationId", id);
    object.encode("consumes", consumes);
    object.encode("produces", produces);
    object.encode("deprecated", deprecated);

    object.encodeObjects("parameters", parameters);
    object.encodeObjectMap("responses", responses);
    object.encode("security", security);
  }
}
