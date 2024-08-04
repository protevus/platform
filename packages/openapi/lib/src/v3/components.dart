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

/// Represents the Components Object as defined in the OpenAPI Specification.
///
/// All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
class APIComponents extends APIObject {
  /// Default constructor for APIComponents.
  ///
  /// Creates a new instance of APIComponents with default (empty) values for all properties.
  APIComponents();

  /// Creates an empty instance of APIComponents.
  ///
  /// This constructor initializes an APIComponents object with no pre-defined components.
  /// All component maps (schemas, responses, parameters, etc.) will be empty.
  APIComponents.empty();

  /// An object to hold reusable [APISchemaObject?] instances.
  ///
  /// This map stores reusable schema objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the schemas, and the values are the corresponding [APISchemaObject] instances.
  /// These schemas can be referenced throughout the API specification using $ref syntax.
  Map<String, APISchemaObject> schemas = {};

  /// An object to hold reusable [APIResponse?] instances.
  ///
  /// This map stores reusable response objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the responses, and the values are the corresponding [APIResponse] instances.
  /// These responses can be referenced throughout the API specification using $ref syntax.
  Map<String, APIResponse> responses = {};

  /// An object to hold reusable [APIParameter?] instances.
  ///
  /// This map stores reusable parameter objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the parameters, and the values are the corresponding [APIParameter] instances.
  /// These parameters can be referenced throughout the API specification using $ref syntax.
  Map<String, APIParameter> parameters = {};

  /// remove?
  ///Map<String, APIExample> examples = {};

  /// An object to hold reusable [APIRequestBody] instances.
  ///
  /// This map stores reusable request body objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the request bodies, and the values are the corresponding [APIRequestBody] instances.
  /// These request bodies can be referenced throughout the API specification using $ref syntax.
  Map<String, APIRequestBody> requestBodies = {};

  /// An object to hold reusable [APIHeader] instances.
  ///
  /// This map stores reusable header objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the headers, and the values are the corresponding [APIHeader] instances.
  /// These headers can be referenced throughout the API specification using $ref syntax.
  Map<String, APIHeader> headers = {};

  /// An object to hold reusable [APISecurityScheme] instances.
  ///
  /// This map stores reusable security scheme objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the security schemes, and the values are the corresponding [APISecurityScheme] instances.
  /// These security schemes can be referenced throughout the API specification using $ref syntax.
  /// They define the security mechanisms that can be used across the API.
  Map<String, APISecurityScheme> securitySchemes = {};

  /// remove?
  ///Map<String, APILink> links = {};

  /// An object to hold reusable [APICallback] instances.
  ///
  /// This map stores reusable callback objects defined in the components section of an OpenAPI document.
  /// The keys are unique names for the callbacks, and the values are the corresponding [APICallback] instances.
  /// These callbacks can be referenced throughout the API specification using $ref syntax.
  /// Callbacks are used to define webhook-like behavior where the API can make calls back to the client.
  Map<String, APICallback> callbacks = {};

  /// Resolves a component definition based on the provided URI.
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

  /// Resolves a reference object to its corresponding component in the API specification.
  ///
  /// This method takes a reference object of type [T] (which must extend [APIObject])
  /// and resolves it to the actual component it refers to within the API components.
  ///
  /// Parameters:
  ///   [refObject]: The reference object to resolve. Must have a non-null [referenceURI].
  ///
  /// Returns:
  ///   The resolved component object of type [T], or null if the reference couldn't be resolved.
  ///
  /// Throws:
  ///   [ArgumentError] if the provided [refObject] is not a reference (i.e., has a null [referenceURI]).
  T? resolve<T extends APIObject>(T refObject) {
    if (refObject.referenceURI == null) {
      throw ArgumentError("APIObject is not a reference to a component.");
    }

    return resolveUri(refObject.referenceURI!) as T?;
  }

  /// Decodes the APIComponents object from a KeyedArchive.
  ///
  /// This method overrides the decode method from the superclass and populates
  /// the various component maps of the APIComponents object. It decodes each
  /// component type (schemas, responses, parameters, etc.) from the provided
  /// KeyedArchive object.
  ///
  /// The method uses removeNullsFromMap to ensure that no null values are
  /// present in the decoded maps. Each component type is decoded using a
  /// specific factory function to create new instances of the appropriate type.
  ///
  /// Note: The 'examples' and 'links' components are currently commented out
  /// and not being decoded.
  ///
  /// Parameters:
  ///   object: A KeyedArchive containing the encoded APIComponents data.
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

  /// Encodes the APIComponents object into a KeyedArchive.
  ///
  /// This method overrides the encode method from the superclass and serializes
  /// the various component maps of the APIComponents object. It encodes each
  /// non-empty component type (schemas, responses, parameters, etc.) into the
  /// provided KeyedArchive object.
  ///
  /// The method only encodes non-empty maps to avoid creating unnecessary empty
  /// objects in the resulting OpenAPI specification. Each component type is
  /// encoded using the encodeObjectMap method of the KeyedArchive.
  ///
  /// Note: The 'examples' and 'links' components are currently commented out
  /// and not being encoded.
  ///
  /// Parameters:
  ///   object: A KeyedArchive to which the APIComponents data will be encoded.
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
