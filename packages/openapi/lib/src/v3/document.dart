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

/// This class represents the root document object of the OpenAPI document.
///
/// It contains all the necessary fields to describe an API according to the OpenAPI Specification.
/// The class provides methods to create an empty specification, create from a map,
/// encode to and decode from a KeyedArchive, and convert to a map.
///
/// Required fields:
/// - version: The semantic version number of the OpenAPI Specification.
/// - info: Metadata about the API.
/// - paths: Available paths and operations for the API.
///
/// Optional fields:
/// - servers: Connectivity information to target servers.
/// - components: Reusable schemas for the specification.
/// - security: Declaration of security mechanisms that can be used across the API.
/// - tags: List of tags used by the specification with additional metadata.
///
/// This class extends APIObject and implements encoding and decoding logic
/// to work with the KeyedArchive serialization system.
class APIDocument extends APIObject {
  /// Creates an empty APIDocument instance.
  ///
  /// This constructor initializes a new APIDocument with default values for all fields.
  /// It can be used as a starting point for building a new OpenAPI specification document.
  APIDocument();

  /// Creates an APIDocument instance from a decoded JSON or YAML document object.
  ///
  /// This constructor initializes a new APIDocument by decoding the provided [map].
  /// The [map] should contain key-value pairs representing the structure of an OpenAPI document.
  ///
  /// It uses [KeyedArchive.unarchive] to convert the map into a KeyedArchive object,
  /// which is then decoded to populate the fields of the APIDocument.
  ///
  /// The [allowReferences] parameter is set to true, allowing the decoding process
  /// to handle references within the document.
  ///
  /// Example:
  /// ```dart
  /// var document = APIDocument.fromMap({
  ///   'openapi': '3.0.0',
  ///   'info': {'title': 'Sample API', 'version': '1.0.0'},
  ///   'paths': {}
  /// });
  /// ```
  APIDocument.fromMap(Map<String, dynamic> map) {
    decode(KeyedArchive.unarchive(map, allowReferences: true));
  }

  /// The semantic version number of the OpenAPI Specification that this document uses.
  ///
  /// REQUIRED. The openapi field SHOULD be used by tooling specifications and clients to interpret the OpenAPI document. This is not related to the API info.version string.
  String version = "3.0.0";

  /// Provides metadata about the API.
  ///
  /// REQUIRED. The metadata MAY be used by tooling as required.
  ///
  /// This field is of type [APIInfo] and is initialized with an empty instance
  /// using [APIInfo.empty()]. It contains essential information about the API,
  /// such as its title, version, description, and other relevant metadata.
  /// This information is crucial for API documentation and client generation tools.
  APIInfo info = APIInfo.empty();

  /// An array of [APIServerDescription] objects that provide connectivity information to target servers.
  ///
  /// If the servers property is not provided, or is an empty array, the default value would be a [APIServerDescription] with a url value of /.
  List<APIServerDescription?>? servers;

  /// The available paths and operations for the API.
  ///
  /// REQUIRED. This field is a map where each key represents a unique path in the API,
  /// and the corresponding value is an [APIPath] object describing the operations
  /// available on that path.
  ///
  /// The paths field is a crucial part of the OpenAPI specification as it defines
  /// the structure and endpoints of the API. Each path may support multiple HTTP
  /// methods (GET, POST, PUT, DELETE, etc.), each with its own operation details.
  ///
  /// Example:
  /// ```dart
  /// {
  ///   "/users": APIPath(...),
  ///   "/products": APIPath(...),
  /// }
  /// ```
  ///
  /// Note: This field is nullable, but it's required for a valid OpenAPI document.
  /// An empty map should be used instead of null for APIs with no paths.
  Map<String, APIPath?>? paths;

  /// An element to hold various schemas for the specification.
  ///
  /// This field allows the definition of various reusable objects for different aspects of the OAS.
  /// It can include schemas, responses, parameters, examples, and more.
  /// These components can be referenced throughout the specification, promoting reusability and reducing duplication.
  /// The field is optional but can significantly improve the organization and maintainability of large API specifications.
  ///
  /// Example usage:
  /// ```dart
  /// components = APIComponents()
  ///   ..schemas = {'User': APISchemaObject()}
  ///   ..responses = {'NotFound': APIResponse()};
  /// ```
  APIComponents? components;

  /// A declaration of which security mechanisms can be used across the API.
  ///
  /// This field is an optional list of [APISecurityRequirement] objects that define
  /// the security schemes applicable to the entire API. Each object in the list
  /// represents an alternative set of security requirements.
  ///
  /// Key features:
  /// - Multiple security requirement objects can be specified.
  /// - Only one of the security requirement objects needs to be satisfied to authorize a request.
  /// - Individual operations can override this global definition.
  /// - If the list is empty, it means that there are no global security requirements.
  ///
  /// The security schemes referenced in this list must be defined in the
  /// [components.securitySchemes] section of the OpenAPI document.
  ///
  /// Example usage:
  /// ```dart
  /// security = [
  ///   APISecurityRequirement()..addRequirement("api_key", []),
  ///   APISecurityRequirement()
  ///     ..addRequirement("oauth2", ["read:api"])
  ///     ..addRequirement("userPassword", []),
  /// ];
  /// ```
  ///
  /// In this example, a request can be authorized using either an API key,
  /// or a combination of OAuth2 with "read:api" scope and user password.
  List<APISecurityRequirement?>? security;

  /// A list of tags used by the specification with additional metadata.
  ///
  /// The order of the tags can be used to reflect on their order by the parsing tools.
  /// Not all tags that are used by the Operation Object must be declared.
  /// The tags that are not declared MAY be organized randomly or based on the tools' logic.
  /// Each tag name in the list MUST be unique.
  ///
  /// This field is optional and can be null. When provided, it contains a list of [APITag] objects.
  /// Each [APITag] typically includes a name and description, and can be used to categorize and
  /// group related operations across the API.
  ///
  /// Tags defined here can be referenced by [APIOperation] objects throughout the specification,
  /// allowing for logical grouping and organization of API endpoints.
  ///
  /// Example usage:
  /// ```dart
  /// tags = [
  ///   APITag()
  ///     ..name = "users"
  ///     ..description = "Operations about users",
  ///   APITag()
  ///     ..name = "products"
  ///     ..description = "Product-related operations",
  /// ];
  /// ```
  ///
  /// Note: While this field is optional, using tags can significantly improve the structure
  /// and readability of API documentation generated from the OpenAPI specification.
  List<APITag?>? tags;

  /// Converts this APIDocument instance to a Map<String, dynamic>.
  ///
  /// This method uses KeyedArchive.archive to serialize the APIDocument object
  /// into a Map representation. The resulting map can be used for JSON/YAML
  /// serialization or other purposes where a dictionary-like structure is needed.
  ///
  /// The allowReferences parameter is set to true, which means that object
  /// references within the document will be preserved during the archiving process.
  ///
  /// Returns:
  ///   A Map<String, dynamic> representation of this APIDocument instance.
  Map<String, dynamic> asMap() {
    return KeyedArchive.archive(this, allowReferences: true);
  }

  /// Decodes the APIDocument from a KeyedArchive object.
  ///
  /// This method populates the fields of the APIDocument instance using data
  /// from the provided [object]. It decodes various components of the OpenAPI
  /// specification, including version, info, servers, paths, components,
  /// security requirements, and tags.
  ///
  /// The method uses default values or empty instances for optional fields
  /// if they are not present in the archive.
  ///
  /// Parameters:
  ///   - object: A KeyedArchive containing the encoded APIDocument data.
  ///
  /// Note: This method overrides the decode method from the superclass and
  /// calls the superclass implementation before decoding specific fields.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    version = object.decode("openapi") ?? "3.0.0";
    info =
        object.decodeObject("info", () => APIInfo.empty()) ?? APIInfo.empty();
    servers =
        object.decodeObjects("servers", () => APIServerDescription.empty());
    paths = object.decodeObjectMap("paths", () => APIPath());
    components = object.decodeObject("components", () => APIComponents());
    security =
        object.decodeObjects("security", () => APISecurityRequirement.empty());
    tags = object.decodeObjects("tags", () => APITag.empty());
  }

  /// Encodes the APIDocument into a KeyedArchive object.
  ///
  /// This method serializes the APIDocument instance into the provided [object],
  /// which is a KeyedArchive. It encodes all the fields of the APIDocument,
  /// including version, info, servers, paths, components, security, and tags.
  ///
  /// Before encoding, it checks if the required fields 'info' and 'paths' are valid.
  /// If these are not valid or missing, it throws an ArgumentError.
  ///
  /// Parameters:
  ///   - object: A KeyedArchive to encode the APIDocument data into.
  ///
  /// Throws:
  ///   - ArgumentError: If 'info' is not valid or 'paths' is null.
  ///
  /// Note: This method overrides the encode method from the superclass and
  /// calls the superclass implementation before encoding specific fields.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (!info.isValid || paths == null) {
      throw ArgumentError(
        "APIDocument must have values for: 'version', 'info' and 'paths'.",
      );
    }

    object.encode("openapi", version);
    object.encodeObject("info", info);
    object.encodeObjects("servers", servers);
    object.encodeObjectMap("paths", paths);
    object.encodeObject("components", components);
    object.encodeObjects("security", security);
    object.encodeObjects("tags", tags);
  }
}
