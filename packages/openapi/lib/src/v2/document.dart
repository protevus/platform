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
import 'package:protevus_openapi/util.dart';
import 'package:protevus_openapi/v2.dart';

/// Represents an OpenAPI 2.0 specification document.
///
/// This class encapsulates the structure and content of an OpenAPI 2.0 (formerly known as Swagger) specification.
/// It provides methods for creating, parsing, and serializing OpenAPI documents.
///
/// Key features:
/// - Supports creation of empty documents or parsing from JSON/YAML maps.
/// - Implements the OpenAPI 2.0 structure, including info, paths, definitions, etc.
/// - Provides serialization to and deserialization from map representations.
/// - Includes type casting rules for proper data handling.
///
/// Usage:
/// - Create an empty document: `var doc = APIDocument();`
/// - Parse from a map: `var doc = APIDocument.fromMap(jsonMap);`
/// - Serialize to a map: `var map = doc.asMap();`
///
/// This class is part of the Protevus Platform and adheres to the OpenAPI 2.0 specification.
class APIDocument extends APIObject {
  /// Creates an empty APIDocument instance.
  ///
  /// This constructor initializes a new APIDocument object with default values
  /// for all its properties. It can be used as a starting point for building
  /// an OpenAPI 2.0 specification programmatically.
  APIDocument();

  /// Creates an APIDocument instance from a decoded JSON or YAML document object.
  ///
  /// This constructor takes a Map<String, dynamic> representation of an OpenAPI 2.0
  /// specification and initializes an APIDocument object with its contents.
  ///
  /// The method uses KeyedArchive.unarchive to convert the map into a KeyedArchive,
  /// allowing references within the document. It then calls the decode method to
  /// populate the APIDocument instance with the data from the KeyedArchive.
  ///
  /// @param map A Map<String, dynamic> containing the decoded JSON or YAML data
  ///            of an OpenAPI 2.0 specification.
  APIDocument.fromMap(Map<String, dynamic> map) {
    decode(KeyedArchive.unarchive(map, allowReferences: true));
  }

  /// The OpenAPI Specification version that this document adheres to.
  ///
  /// This field is required and should always be set to "2.0" for OpenAPI 2.0
  /// (Swagger) specifications. It indicates that this APIDocument instance
  /// represents an OpenAPI 2.0 specification.
  String version = "2.0";

  /// The metadata about the API.
  ///
  /// This property contains information such as the API title, description,
  /// version, and other relevant metadata. It is represented by an instance
  /// of the APIInfo class.
  ///
  /// The field is nullable, but initialized with a default APIInfo instance.
  APIInfo? info = APIInfo();

  /// The host (name or IP) serving the API.
  ///
  /// This optional field represents the host (name or IP) serving the API.
  /// It must include the host name only and should not include the scheme
  /// or sub-paths. It may include a port. If not specified, the host serving
  /// the documentation is assumed to be the same as the host serving the API.
  /// The value MAY be null to indicate that the host is not yet known.
  String? host;

  /// The base path on which the API is served, relative to the host.
  ///
  /// This optional field represents the base path for all API operations.
  /// If specified, it must start with a forward slash ("/"). If not specified,
  /// the API is served directly under the host. The value MAY be null to
  /// indicate that the base path is not yet known or is the root ("/").
  String? basePath;

  /// A list of tags used by the specification with additional metadata.
  ///
  /// The order of the tags can be used to reflect on their order by the parsing tools.
  /// Not all tags that are used by the [Operation Object](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/2.0.md#operationObject)
  /// must be declared. The tags that are not declared may be organized randomly or
  /// based on the tools' logic. Each tag name in the list MUST be unique.
  ///
  /// This field is nullable and initialized as an empty list.
  List<APITag?>? tags = [];

  /// The transfer protocol(s) used by the API.
  ///
  /// This list specifies the transfer protocol(s) that the API supports.
  /// Common values include "http", "https", "ws" (WebSocket), and "wss" (secure WebSocket).
  /// The order of the protocols does not matter.
  ///
  /// If the schemes is not included, the default scheme to be used is the one used to access
  /// the OpenAPI definition itself.
  ///
  /// This field is nullable and initialized as an empty list.
  List<String>? schemes = [];

  /// The MIME types that the API can consume.
  ///
  /// This list specifies the MIME types of the request payloads that the API can process.
  /// Common values might include "application/json", "application/xml", "application/x-www-form-urlencoded", etc.
  ///
  /// If this field is not specified, it is assumed that the API can consume any MIME type.
  ///
  /// This field is nullable and initialized as an empty list.
  List<String>? consumes = [];

  /// The MIME types that the API can produce.
  ///
  /// This list specifies the MIME types of the response payloads that the API can generate.
  /// Common values might include "application/json", "application/xml", "text/plain", etc.
  ///
  /// If this field is not specified, it is assumed that the API can produce any MIME type.
  ///
  /// This field is nullable and initialized as an empty list.
  List<String>? produces = [];

  /// A list of security requirements for the API.
  ///
  /// Each item in this list is a map representing a security requirement.
  /// The keys of these maps are the names of security schemes (as defined in [securityDefinitions]),
  /// and their values are lists of scopes required for that scheme.
  ///
  /// An empty list means no security is required.
  /// Multiple items in the list represent AND conditions, while multiple entries in a single map represent OR conditions.
  ///
  /// Example:
  /// [
  ///   {"api_key": []},
  ///   {"oauth2": ["write:pets", "read:pets"]}
  /// ]
  /// This would require either an API key OR OAuth2 with both write:pets and read:pets scopes.
  ///
  /// This field is nullable and initialized as an empty list.
  List<Map<String, List<String?>>?>? security = [];

  /// A map of API paths, where each key is a path string and the value is an APIPath object.
  ///
  /// This property represents all the paths available in the API, including their operations,
  /// parameters, and responses. Each path is a relative path to an individual endpoint.
  /// The path is appended to the basePath in order to construct the full URL.
  ///
  /// The map is nullable and initialized as an empty map. Each APIPath object in the map
  /// is also nullable, allowing for flexible path definitions.
  ///
  /// Example:
  /// {
  ///   "/pets": APIPath(...),
  ///   "/users/{userId}": APIPath(...),
  /// }
  Map<String, APIPath?>? paths = {};

  /// A map of reusable responses that can be used across operations.
  ///
  /// This property defines response objects that can be referenced by multiple
  /// operations in the API. Each key in the map is a name for the response,
  /// and the corresponding value is an APIResponse object describing the response.
  ///
  /// These responses can be referenced using the '$ref' keyword in operation
  /// responses, allowing for reuse and consistency across the API specification.
  ///
  /// The map is nullable, and each APIResponse object within it is also nullable,
  /// providing flexibility in defining and referencing responses.
  ///
  /// Example:
  /// {
  ///   "NotFound": APIResponse(...),
  ///   "InvalidInput": APIResponse(...),
  /// }
  Map<String, APIResponse?>? responses = {};

  /// A map of reusable parameters that can be referenced from operations.
  ///
  /// This property defines parameter objects that can be used across multiple
  /// operations in the API. Each key in the map is a unique name for the parameter,
  /// and the corresponding value is an APIParameter object describing the parameter.
  ///
  /// These parameters can be referenced using the '$ref' keyword in operation
  /// parameters, allowing for reuse and consistency across the API specification.
  ///
  /// The map is nullable, and each APIParameter object within it is also nullable,
  /// providing flexibility in defining and referencing parameters.
  ///
  /// Example:
  /// {
  ///   "userId": APIParameter(...),
  ///   "apiKey": APIParameter(...),
  /// }
  Map<String, APIParameter?>? parameters = {};

  /// A map of reusable schema definitions that can be referenced throughout the API specification.
  ///
  /// This property defines schema objects that can be used to describe complex data structures
  /// used in request bodies, response payloads, or as nested properties of other schemas.
  /// Each key in the map is a unique name for the schema, and the corresponding value is an
  /// APISchemaObject that describes the structure and constraints of the schema.
  ///
  /// These schema definitions can be referenced using the '$ref' keyword in other parts of the
  /// API specification, allowing for reuse and simplification of complex data models.
  ///
  /// The map is nullable, and each APISchemaObject within it is also nullable, providing
  /// flexibility in defining and referencing schemas.
  ///
  /// Example:
  /// {
  ///   "User": APISchemaObject(...),
  ///   "Error": APISchemaObject(...),
  /// }
  Map<String, APISchemaObject?>? definitions = {};

  /// A map of security schemes that can be used across the API specification.
  ///
  /// This property defines security scheme objects that can be referenced by the
  /// [security] property or an operation's security property. Each key in the map
  /// is a unique name for the security scheme, and the corresponding value is an
  /// APISecurityScheme object describing the security scheme.
  ///
  /// These security definitions can be used to describe API keys, OAuth2 flows,
  /// or other custom security mechanisms required by the API.
  ///
  /// The map is nullable, and each APISecurityScheme object within it is also nullable,
  /// providing flexibility in defining and referencing security schemes.
  ///
  /// Example:
  /// {
  ///   "api_key": APISecurityScheme(...),
  ///   "oauth2": APISecurityScheme(...),
  /// }
  Map<String, APISecurityScheme?>? securityDefinitions = {};

  /// Converts the APIDocument object to a Map<String, dynamic>.
  ///
  /// This method serializes the current APIDocument instance into a Map
  /// representation. It uses the KeyedArchive.archive method to perform
  /// the serialization, with the allowReferences parameter set to true.
  ///
  /// @return A Map<String, dynamic> containing the serialized data of the APIDocument.
  Map<String, dynamic> asMap() {
    return KeyedArchive.archive(this, allowReferences: true);
  }

  /// Defines the type casting rules for specific properties of the APIDocument class.
  ///
  /// This map provides casting instructions for the following properties:
  /// - "schemes": A list of strings
  /// - "consumes": A list of strings
  /// - "produces": A list of strings
  /// - "security": A list of maps, where each map has string keys and list of string values
  ///
  /// These casting rules ensure that the data is properly typed when decoded from JSON or YAML.
  @override
  Map<String, cast.Cast> get castMap => {
        "schemes": const cast.List(cast.string),
        "consumes": const cast.List(cast.string),
        "produces": const cast.List(cast.string),
        "security":
            const cast.List(cast.Map(cast.string, cast.List(cast.string)))
      };

  /// Decodes the APIDocument object from a KeyedArchive.
  ///
  /// This method populates the properties of the APIDocument instance using
  /// data from the provided KeyedArchive object. It decodes various fields
  /// such as version, host, basePath, schemes, consumes, produces, security,
  /// info, tags, paths, responses, parameters, definitions, and
  /// securityDefinitions.
  ///
  /// The method also removes null values from certain list properties and
  /// creates instances of related API objects (e.g., APIInfo, APITag, APIPath)
  /// as needed.
  ///
  /// @param object The KeyedArchive containing the encoded APIDocument data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    version = object["swagger"] as String;
    host = object["host"] as String?;
    basePath = object["basePath"] as String?;
    schemes = removeNullsFromList(object["schemes"] as List<String?>?);

    /// remove
    consumes = removeNullsFromList(object["consumes"] as List<String?>?);
    produces = removeNullsFromList(object["produces"] as List<String?>?);
    security = object["security"] as List<Map<String, List<String?>>?>;

    info = object.decodeObject("info", () => APIInfo());
    tags = object.decodeObjects("tags", () => APITag());
    paths = object.decodeObjectMap("paths", () => APIPath());
    responses = object.decodeObjectMap("responses", () => APIResponse());
    parameters = object.decodeObjectMap("parameters", () => APIParameter());
    definitions =
        object.decodeObjectMap("definitions", () => APISchemaObject());
    securityDefinitions = object.decodeObjectMap(
      "securityDefinitions",
      () => APISecurityScheme(),
    );
  }

  /// Encodes the APIDocument object into a KeyedArchive.
  ///
  /// This method serializes the properties of the APIDocument instance into
  /// the provided KeyedArchive object. It encodes various fields such as
  /// version (as "swagger"), host, basePath, schemes, consumes, produces,
  /// paths, info, parameters, responses, securityDefinitions, security,
  /// tags, and definitions.
  ///
  /// The method uses different encoding techniques based on the property type:
  /// - Simple properties are encoded directly.
  /// - Object maps are encoded using encodeObjectMap.
  /// - Single objects (like info) are encoded using encodeObject.
  /// - Lists of objects (like tags) are encoded using encodeObjects.
  ///
  /// @param object The KeyedArchive to encode the APIDocument data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("swagger", version);
    object.encode("host", host);
    object.encode("basePath", basePath);
    object.encode("schemes", schemes);
    object.encode("consumes", consumes);
    object.encode("produces", produces);
    object.encodeObjectMap("paths", paths);
    object.encodeObject("info", info);
    object.encodeObjectMap("parameters", parameters);
    object.encodeObjectMap("responses", responses);
    object.encodeObjectMap("securityDefinitions", securityDefinitions);
    object.encode("security", security);
    object.encodeObjects("tags", tags);
    object.encodeObjectMap("definitions", definitions);
  }
}
