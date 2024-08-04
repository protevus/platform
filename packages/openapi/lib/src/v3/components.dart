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
import 'package:protevus_openapi/util.dart';
import 'package:protevus_openapi/v3.dart';

/// Holds a set of reusable objects for different aspects of the OAS.
///
/// All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
class APIComponents extends APIObject {
  APIComponents();

  APIComponents.empty();

  /// An object to hold reusable [APISchemaObject?].
  Map<String, APISchemaObject> schemas = {};

  /// An object to hold reusable [APIResponse?].
  Map<String, APIResponse> responses = {};

  /// An object to hold reusable [APIParameter?].
  Map<String, APIParameter> parameters = {};

  //Map<String, APIExample> examples = {};

  /// An object to hold reusable [APIRequestBody?].
  Map<String, APIRequestBody> requestBodies = {};

  /// An object to hold reusable [APIHeader].
  Map<String, APIHeader> headers = {};

  /// An object to hold reusable [APISecurityScheme?].
  Map<String, APISecurityScheme> securitySchemes = {};

  //Map<String, APILink> links = {};

  /// An object to hold reusable [APICallback?].
  Map<String, APICallback> callbacks = {};

  /// Returns a component definition for [uri].
  ///
  /// Construct [uri] as a path, e.g. `Uri(path: /components/schemas/name)`.
  APIObject? resolveUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 3) {
      throw ArgumentError(
        "Invalid reference URI. Must be a path URI of the form: '/components/<type>/<name>'",
      );
    }

    if (segments.first != "components") {
      throw ArgumentError(
        "Invalid reference URI: does not begin with /components/",
      );
    }

    Map<String, APIObject?>? namedMap;
    switch (segments[1]) {
      case "schemas":
        namedMap = schemas;
        break;
      case "responses":
        namedMap = responses;
        break;
      case "parameters":
        namedMap = parameters;
        break;
      case "requestBodies":
        namedMap = requestBodies;
        break;
      case "headers":
        namedMap = headers;
        break;
      case "securitySchemes":
        namedMap = securitySchemes;
        break;
      case "callbacks":
        namedMap = callbacks;
        break;
    }

    if (namedMap == null) {
      throw ArgumentError(
        "Invalid reference URI: component type '${segments[1]}' does not exist.",
      );
    }

    final result = namedMap[segments.last];

    return result;
  }

  T? resolve<T extends APIObject>(T refObject) {
    if (refObject.referenceURI == null) {
      throw ArgumentError("APIObject is not a reference to a component.");
    }

    return resolveUri(refObject.referenceURI!) as T?;
  }

  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    schemas = removeNullsFromMap(
      object.decodeObjectMap("schemas", () => APISchemaObject()),
    );
    responses = removeNullsFromMap(
      object.decodeObjectMap("responses", () => APIResponse.empty()),
    );
    parameters = removeNullsFromMap(
      object.decodeObjectMap("parameters", () => APIParameter.empty()),
    );
//    examples = object.decodeObjectMap("examples", () => APIExample());
    requestBodies = removeNullsFromMap(
      object.decodeObjectMap("requestBodies", () => APIRequestBody.empty()),
    );
    headers = removeNullsFromMap(
      object.decodeObjectMap("headers", () => APIHeader()),
    );

    securitySchemes = removeNullsFromMap(
      object.decodeObjectMap("securitySchemes", () => APISecurityScheme()),
    );
//    links = object.decodeObjectMap("links", () => APILink());
    callbacks = removeNullsFromMap(
      object.decodeObjectMap("callbacks", () => APICallback()),
    );
  }

  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (schemas.isNotEmpty) object.encodeObjectMap("schemas", schemas);
    if (responses.isNotEmpty) object.encodeObjectMap("responses", responses);
    if (parameters.isNotEmpty) object.encodeObjectMap("parameters", parameters);
//    object.encodeObjectMap("examples", examples);
    if (requestBodies.isNotEmpty) {
      object.encodeObjectMap("requestBodies", requestBodies);
    }
    if (headers.isNotEmpty) object.encodeObjectMap("headers", headers);
    if (securitySchemes.isNotEmpty) {
      object.encodeObjectMap("securitySchemes", securitySchemes);
    }

//    object.encodeObjectMap("links", links);
    if (callbacks.isNotEmpty) object.encodeObjectMap("callbacks", callbacks);
  }
}
