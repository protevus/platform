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
import 'package:protevus_openapi/v3.dart';

/// Describes a single API operation on a path.
///
/// This class represents an operation (HTTP method) in an OpenAPI specification.
/// It contains information about the operation such as tags, summary, description,
/// parameters, security requirements, request body, responses, and more.
///
/// The class provides methods to add parameters, security requirements, and responses,
/// as well as to retrieve specific parameters by name.
///
/// This class extends [APIObject] and implements [Codable] for serialization and deserialization.
class APIOperation extends APIObject {
  /// Creates a new [APIOperation] instance.
  ///
  /// [id] is the unique string used to identify the operation.
  /// [responses] is a map of possible responses as they are returned from executing this operation.
  ///
  /// Optional parameters:
  /// - [tags]: A list of tags for API documentation control.
  /// - [summary]: A short summary of what the operation does.
  /// - [description]: A verbose explanation of the operation behavior.
  /// - [parameters]: A list of parameters that are applicable for this operation.
  /// - [security]: A declaration of which security mechanisms can be used for this operation.
  /// - [requestBody]: The request body applicable for this operation.
  /// - [callbacks]: A map of possible out-of band callbacks related to the parent operation.
  /// - [deprecated]: Declares this operation to be deprecated.
  APIOperation(
    this.id,
    this.responses, {
    this.tags,
    this.summary,
    this.description,
    this.parameters,
    this.security,
    this.requestBody,
    this.callbacks,
    this.deprecated,
  });

  /// Creates an empty [APIOperation] instance.
  ///
  /// This constructor initializes an [APIOperation] with no properties set,
  /// allowing for manual population of fields after creation.
  APIOperation.empty();

  /// A list of tags for API documentation control.
  ///
  /// Tags can be used for logical grouping of operations by resources or any other qualifier.
  /// These tags are used to categorize and organize API operations in documentation tools and clients.
  /// Each tag is a string that represents a specific category or group.
  /// Tags are optional but can greatly improve the organization and discoverability of API operations.
  /// Multiple tags can be applied to a single operation, allowing for flexible categorization.
  List<String>? tags;

  /// A short summary of what the operation does.
  ///
  /// This property provides a concise description of the operation's purpose.
  /// It should be brief, typically a single sentence or short paragraph.
  /// The summary is often used in API documentation to give users a quick
  /// understanding of what the operation does without needing to read the
  /// full description.
  String? summary;

  /// A verbose explanation of the operation behavior.
  ///
  /// This property provides a detailed description of what the operation does,
  /// how it works, and any important information that users or developers should
  /// know about its behavior. It can include information about:
  /// - The purpose of the operation
  /// - Expected input and output
  /// - Possible side effects
  /// - Usage examples
  /// - Any limitations or constraints
  ///
  /// The description can be more extensive than the summary and is meant to provide
  /// a comprehensive understanding of the operation.
  ///
  /// CommonMark syntax MAY be used for rich text representation, allowing for
  /// formatted text, lists, code blocks, and other Markdown features to enhance
  /// readability and organization of the description.
  String? description;

  /// Unique string used to identify the operation.
  ///
  /// The id MUST be unique among all operations described in the API. Tools and libraries MAY use the operationId to uniquely identify an operation, therefore, it is RECOMMENDED to follow common programming naming conventions.
  ///
  /// This property serves as a unique identifier for the operation within the API specification.
  /// It is crucial for:
  /// - Distinguishing between different operations
  /// - Enabling tools and libraries to reference specific operations
  /// - Maintaining consistency and clarity in API documentation
  ///
  /// Best practices for assigning an operationId:
  /// - Use camelCase naming convention
  /// - Make it descriptive of the operation's purpose
  /// - Ensure it's unique across all operations in the API
  /// - Keep it concise while still being meaningful
  ///
  /// Example: 'getUserProfile', 'createOrder', 'updateItemInventory'
  ///
  /// Note: While optional in the OpenAPI specification, providing an operationId
  /// is strongly recommended for better API organization and tooling support.
  String? id;

  /// A list of parameters that are applicable for this operation.
  ///
  /// This property defines the parameters that are specific to this operation.
  /// These parameters can be in addition to or overriding the parameters defined
  /// at the path level.
  ///
  /// Key points:
  /// - If a parameter is already defined at the Path Item level, the definition
  ///   here will override it, but cannot remove it entirely.
  /// - The list MUST NOT include duplicated parameters. A unique parameter is
  ///   defined by a combination of a name and location.
  /// - The list can use the Reference Object to link to parameters that are
  ///   defined in the OpenAPI Object's components/parameters section.
  /// - Parameters defined here are specific to this operation and may not apply
  ///   to other operations, even within the same path.
  ///
  /// This property allows for fine-grained control over the parameters for each
  /// individual operation, enabling precise API documentation and client generation.
  List<APIParameter>? parameters;

  /// A declaration of which security mechanisms can be used for this operation.
  ///
  /// This property defines the security requirements for the specific operation.
  /// It is represented as a list of [APISecurityRequirement] objects.
  ///
  /// Key points:
  /// - Each element in the list represents an alternative security requirement.
  /// - Only one of the security requirement objects needs to be satisfied to authorize a request.
  /// - This definition overrides any declared top-level security for the API.
  /// - To remove a top-level security declaration, an empty array can be used.
  /// - If not specified, the security requirements defined at the API level apply.
  ///
  /// The security requirements can include various authentication schemes such as:
  /// - API keys
  /// - OAuth2 flows
  /// - OpenID Connect Discovery
  /// - HTTP authentication schemes (e.g., Basic, Bearer)
  ///
  /// By specifying security at the operation level, you can have fine-grained
  /// control over the security requirements for different API endpoints.
  List<APISecurityRequirement>? security;

  /// The request body applicable for this operation.
  ///
  /// This property specifies the request body content for this operation. It is represented
  /// by an [APIRequestBody] object, which describes a single request body.
  ///
  /// Key points:
  /// - The requestBody is only supported in HTTP methods where the HTTP 1.1 specification
  ///   RFC7231 has explicitly defined semantics for request bodies.
  /// - In cases where the HTTP spec is vague about request bodies, this property SHALL be
  ///   ignored by consumers.
  /// - It can be used to describe the content, format, and schema of the request body.
  /// - This property is particularly useful for POST, PUT, and PATCH operations.
  /// - It can specify multiple content types that the API can consume.
  /// - If null, it indicates that the operation does not expect a request body.
  ///
  /// Note: The actual support and behavior regarding request bodies may vary depending on
  /// the specific HTTP method used and how strictly the implementation follows the HTTP
  /// specifications.
  APIRequestBody? requestBody;

  /// The list of possible responses as they are returned from executing this operation.
  ///
  /// This property is a map where the keys are HTTP status codes (as strings) and the values
  /// are [APIResponse] objects describing the response for that status code.
  ///
  /// Key points:
  /// - This property is REQUIRED in the OpenAPI specification.
  /// - It must contain at least one response object, which may be the 'default' response.
  /// - The map can use the wildcard HTTP status code '2XX', '3XX', '4XX', or '5XX' to describe
  ///   multiple status codes at once.
  /// - The 'default' key can be used to describe the response for all undeclared status codes.
  ///
  /// Example:
  /// ```
  /// "responses": {
  ///   "200": { ... },  // Successful response
  ///   "400": { ... },  // Bad request response
  ///   "default": { ... }  // Unexpected error response
  /// }
  /// ```
  ///
  /// Each [APIResponse] object in this map provides details about the response such as
  /// description, headers, content, and links.
  Map<String, APIResponse?>? responses;

  /// A map of possible out-of-band callbacks related to the parent operation.
  ///
  /// The key is a unique identifier for the [APICallback]. Each value in the map is a [APICallback] that describes a request that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
  Map<String, APICallback?>? callbacks;

  /// An alternative server array to service this operation.
  ///
  /// If an alternative server object is specified at the [APIPath] or [APIDocument] level, it will be overridden by this value.
  ///
  /// This property allows specifying operation-specific servers, which take precedence over servers defined at the path or document level.
  /// Each [APIServerDescription] in the list represents a server that can handle requests for this specific operation.
  ///
  /// Key points:
  /// - If specified, this array overrides any server configurations defined at higher levels (path, document).
  /// - It allows for fine-grained control over which servers can handle specific operations.
  /// - Useful for scenarios where certain operations are only available on specific servers.
  /// - Can be used to specify different environments (e.g., production, staging) for different operations.
  ///
  /// The list can be null if no operation-specific servers are defined, in which case the servers defined at higher levels will be used.
  List<APIServerDescription?>? servers;

  /// Declares this operation to be deprecated.
  ///
  /// This property indicates whether the operation is deprecated and should be avoided in future use.
  ///
  /// Key points:
  /// - When set to true, it signals that the operation is no longer recommended for use.
  /// - Consumers of the API SHOULD refrain from using deprecated operations.
  /// - It helps in managing API lifecycle by indicating which operations are being phased out.
  /// - Can be used to guide API users towards newer or preferred alternatives.
  /// - The default value is false if not explicitly set.
  ///
  /// Note: Even when an operation is marked as deprecated, it may still be functional.
  /// However, it's a strong indication that the operation may be removed or altered in future versions of the API.
  bool? deprecated;

  /// Returns the parameter named [name] or null if it doesn't exist.
  ///
  /// This method searches the [parameters] list for a parameter with the specified [name].
  /// If found, it returns the matching [APIParameter] object.
  /// If no parameter with the given name is found, or if [parameters] is null, it returns null.
  ///
  /// Parameters:
  ///   [name]: The name of the parameter to search for.
  ///
  /// Returns:
  ///   An [APIParameter] object if a parameter with the specified name is found, otherwise null.
  APIParameter? parameterNamed(String name) =>
      parameters?.firstWhere((p) => p.name == name);

  /// Adds a parameter to the list of parameters for this operation.
  ///
  /// If [parameters] is null, invoking this method will set it to a list containing [parameter].
  /// Otherwise, [parameter] is added to [parameters].
  void addParameter(APIParameter parameter) {
    parameters ??= [];
    parameters!.add(parameter);
  }

  /// Adds a security requirement to the operation's security list.
  ///
  /// If [security] is null, invoking this method will set it to a list containing [requirement].
  /// Otherwise, [requirement] is added to [security].
  void addSecurityRequirement(APISecurityRequirement requirement) {
    security ??= [];

    security!.add(requirement);
  }

  /// Adds [response] to [responses], merging schemas if necessary.
  ///
  /// This method adds the given [response] to the [responses] map using the [statusCode] as the key.
  /// If a response already exists for the given [statusCode], it merges the new response with the existing one.
  ///
  /// Parameters:
  ///   [statusCode]: The HTTP status code for the response.
  ///   [response]: The APIResponse object to be added or merged.
  ///
  /// Behavior:
  /// - If [responses] is null, it initializes it as an empty map.
  /// - If no response exists for the given [statusCode], it simply adds the new response.
  /// - If a response already exists:
  ///   - The descriptions are concatenated.
  ///   - Headers from the new response are added to the existing response.
  ///   - Content from the new response is added to the existing response.
  ///
  /// Note: This method modifies the [responses] property of the current object.
  ///
  /// Example:
  /// ```dart
  /// var operation = APIOperation.empty();
  /// var response = APIResponse(...);
  /// operation.addResponse(200, response);
  /// ```
  ///
  /// This method is useful for building or updating the responses of an API operation,
  /// allowing for the gradual construction of complex response structures or the
  /// modification of existing responses without overwriting all information.
  void addResponse(int statusCode, APIResponse? response) {
    responses ??= {};

    final key = "$statusCode";

    final existingResponse = responses![key];
    if (existingResponse == null) {
      responses![key] = response;
      return;
    }

    existingResponse.description =
        "${existingResponse.description ?? ""}\n${response!.description}";
    response.headers?.forEach((name, header) {
      existingResponse.addHeader(name, header);
    });
    response.content?.forEach((contentType, mediaType) {
      existingResponse.addContent(contentType, mediaType?.schema);
    });
  }

  /// Defines the casting rules for specific properties of this class.
  ///
  /// This getter provides a map where the keys are property names and the values
  /// are [cast.Cast] objects that define how these properties should be cast
  /// when being decoded or encoded.
  ///
  /// In this case, it specifies that the 'tags' property should be cast as a
  /// List of strings. This ensures that when the 'tags' property is processed,
  /// it will be treated as a list of string values.
  ///
  /// Returns:
  ///   A Map<String, cast.Cast> where:
  ///   - The key 'tags' is associated with a cast.List(cast.string) value,
  ///     indicating that 'tags' should be cast as a list of strings.
  @override
  Map<String, cast.Cast> get castMap => {"tags": const cast.List(cast.string)};

  /// Decodes the properties of this [APIOperation] from a [KeyedArchive] object.
  ///
  /// This method is responsible for populating the properties of the [APIOperation]
  /// instance from the provided [KeyedArchive] object. It decodes various fields
  /// such as tags, summary, description, parameters, responses, and more.
  ///
  /// The method handles different types of properties:
  /// - Simple properties like 'tags', 'summary', 'description' are directly decoded.
  /// - Complex properties like 'parameters', 'security', 'servers' are decoded as lists of objects.
  /// - Map properties like 'responses' and 'callbacks' are decoded as object maps.
  /// - Objects like 'requestBody' are decoded as single instances.
  ///
  /// Some decoded properties (like 'parameters' and 'security') are filtered to remove null values.
  ///
  /// This method overrides the 'decode' method from a superclass and calls the superclass
  /// implementation before performing its own decoding.
  ///
  /// Parameters:
  ///   [object]: The [KeyedArchive] containing the encoded data to be decoded.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    tags = object.decode("tags");
    summary = object.decode("summary");
    description = object.decode("description");
    id = object.decode("operationId");
    parameters = object
        .decodeObjects("parameters", () => APIParameter.empty())
        ?.nonNulls
        .toList();
    requestBody =
        object.decodeObject("requestBody", () => APIRequestBody.empty());
    responses = object.decodeObjectMap("responses", () => APIResponse.empty());
    callbacks = object.decodeObjectMap("callbacks", () => APICallback());
    deprecated = object.decode("deprecated");
    security = object
        .decodeObjects("security", () => APISecurityRequirement.empty())
        ?.nonNulls
        .toList();
    servers =
        object.decodeObjects("servers", () => APIServerDescription.empty());
  }

  /// Encodes the properties of this [APIOperation] into a [KeyedArchive] object.
  ///
  /// This method is responsible for serializing the properties of the [APIOperation]
  /// instance into the provided [KeyedArchive] object. It encodes various fields
  /// such as tags, summary, description, parameters, responses, and more.
  ///
  /// The method handles different types of properties:
  /// - Simple properties like 'tags', 'summary', 'description' are directly encoded.
  /// - Complex properties like 'parameters', 'security', 'servers' are encoded as lists of objects.
  /// - Map properties like 'responses' and 'callbacks' are encoded as object maps.
  /// - Objects like 'requestBody' are encoded as single instances.
  ///
  /// This method throws an [ArgumentError] if the 'responses' property is null,
  /// as it is a required field in the OpenAPI specification.
  ///
  /// This method overrides the 'encode' method from a superclass and calls the superclass
  /// implementation before performing its own encoding.
  ///
  /// Parameters:
  ///   [object]: The [KeyedArchive] where the encoded data will be stored.
  ///
  /// Throws:
  ///   [ArgumentError]: If the 'responses' property is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (responses == null) {
      throw ArgumentError(
        "Invalid specification. APIOperation must have non-null values for: 'responses'.",
      );
    }

    object.encode("tags", tags);
    object.encode("summary", summary);
    object.encode("description", description);
    object.encode("operationId", id);
    object.encodeObjects("parameters", parameters);
    object.encodeObject("requestBody", requestBody);
    object.encodeObjectMap("responses", responses);
    object.encodeObjectMap("callbacks", callbacks);
    object.encode("deprecated", deprecated);
    object.encodeObjects("security", security);
    object.encodeObjects("servers", servers);
  }
}
