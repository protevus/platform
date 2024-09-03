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
///
/// This class extends [APIObject] and provides properties and methods to handle
/// various aspects of an API operation, including:
/// - Tags associated with the operation
/// - Summary and description of the operation
/// - Consumes and produces content types
/// - Deprecated status
/// - Parameters and responses
/// - Security requirements
///
/// The class implements [Codable] interface through [APIObject], allowing
/// for easy encoding and decoding of the operation data.
class APIOperation extends APIObject {
  /// Creates a new instance of [APIOperation].
  ///
  /// This constructor initializes a new [APIOperation] object without any
  /// predefined values. Properties can be set after initialization.
  APIOperation();

  /// Defines the type casting rules for specific properties of the [APIOperation] class.
  ///
  /// This getter method returns a [Map] where the keys are property names and the values
  /// are [cast.Cast] objects that define how these properties should be type-casted.
  ///
  /// The map includes the following castings:
  /// - "tags": A list of strings
  /// - "consumes": A list of strings
  /// - "produces": A list of strings
  /// - "schemes": A list of strings
  /// - "security": A list of maps, where each map has string keys and list of string values
  ///
  /// This casting information is used to ensure type safety when decoding JSON data
  /// into [APIOperation] objects.
  @override
  Map<String, cast.Cast> get castMap => {
        "tags": const cast.List(cast.string),
        "consumes": const cast.List(cast.string),
        "produces": const cast.List(cast.string),
        "schemes": const cast.List(cast.string),
        "security":
            const cast.List(cast.Map(cast.string, cast.List(cast.string))),
      };

  /// A brief summary of the operation.
  ///
  /// This property provides a short description of what the operation does.
  /// It's typically used to give a quick overview of the operation's purpose
  /// in API documentation or user interfaces.
  String? summary = "";

  /// A detailed description of the operation.
  ///
  /// This property provides a more comprehensive explanation of what the operation does,
  /// how it works, and any important details that users or developers should know.
  /// It can include information about request/response formats, authentication requirements,
  /// or any other relevant details about the operation's behavior.
  String? description = "";

  /// The unique identifier for this operation.
  ///
  /// This property represents the operationId as defined in the OpenAPI specification.
  /// It's used to uniquely identify an operation within an API. The operationId is often
  /// used as a reference point in documentation, client libraries, and other tooling.
  String? id;

  /// Indicates whether this operation is deprecated.
  ///
  /// If set to `true`, it means that the operation is still functional but its
  /// use is discouraged. Clients should migrate away from using this operation.
  /// If `false` or `null`, the operation is considered active and recommended for use.
  bool? deprecated;

  /// A list of tags associated with this operation.
  ///
  /// Tags are used to group operations in the OpenAPI specification. They can be used
  /// for logical grouping of operations by resources or any other qualifier.
  /// This property is nullable and can be an empty list if no tags are specified.
  List<String?>? tags = [];

  /// A list of transfer protocols supported by this operation.
  ///
  /// This property specifies the schemes (such as 'http', 'https', 'ws', 'wss')
  /// that the operation supports. It's typically used to indicate which
  /// protocols can be used to access the API endpoint.
  /// The list can be empty if no specific schemes are defined.
  List<String?>? schemes = [];

  /// A list of MIME types the operation can consume.
  ///
  /// This property specifies the MIME types of the request payload that the operation
  /// can process. It indicates the content types that the client can send in the request body.
  /// Common values include 'application/json', 'application/xml', 'multipart/form-data', etc.
  /// The list can be empty if the operation doesn't consume any specific MIME types.
  List<String?>? consumes = [];

  /// A list of MIME types the operation can produce.
  ///
  /// This property specifies the MIME types of the response payload that the operation
  /// can generate. It indicates the content types that the server will send in the response body.
  /// Common values include 'application/json', 'application/xml', 'text/plain', etc.
  /// The list can be empty if the operation doesn't produce any specific MIME types.
  List<String?>? produces = [];

  /// A list of parameters for this operation.
  ///
  /// This property contains a list of [APIParameter] objects that define the
  /// parameters accepted by the operation. These parameters can include path
  /// parameters, query parameters, header parameters, and body parameters.
  /// Each parameter specifies details such as name, location (in), type, and
  /// whether it's required.
  ///
  /// The list can be empty if the operation doesn't require any parameters.
  /// It's nullable to allow for cases where parameters are not specified.
  List<APIParameter?>? parameters = [];

  /// A list of security requirements for this operation.
  ///
  /// This property defines the security schemes that apply to this operation.
  /// Each item in the list is a map where:
  /// - The key is the name of a security scheme defined in the global 'securityDefinitions'.
  /// - The value is a list of scopes required for this operation (can be an empty list if no scopes are required).
  ///
  /// Multiple items in the list indicate that multiple security schemes can be used (OR relationship).
  /// An empty list means that no security is required for this operation.
  /// If this property is null, it inherits the global security requirements.
  List<Map<String, List<String>>?>? security = [];

  /// A map of possible responses from this operation.
  ///
  /// The keys of this map are HTTP status codes (as strings), and the values
  /// are [APIResponse] objects describing the response for that status code.
  ///
  /// For example, '200' might map to a successful response, '400' to a bad request
  /// response, and so on. The map can include a 'default' key to describe the
  /// response for any undocumented status codes.
  ///
  /// This property is nullable, allowing for operations that don't specify
  /// their responses explicitly.
  Map<String, APIResponse?>? responses = {};

  /// Decodes the [APIOperation] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIOperation]
  /// instance from the provided [KeyedArchive] object. It decodes various fields
  /// such as tags, summary, description, operationId, consumes, produces, deprecated
  /// status, parameters, responses, schemes, and security requirements.
  ///
  /// The method first calls the superclass's decode method to handle any base
  /// properties, then proceeds to decode specific [APIOperation] properties.
  ///
  /// For complex properties like parameters and responses, it uses specialized
  /// decoding methods that create new instances of [APIParameter] and [APIResponse]
  /// respectively.
  ///
  /// @param object The [KeyedArchive] containing the encoded data to be decoded.
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

  /// Encodes the [APIOperation] object into a [KeyedArchive].
  ///
  /// This method is responsible for encoding the properties of the [APIOperation]
  /// instance into the provided [KeyedArchive] object. It encodes various fields
  /// such as tags, summary, description, operationId, consumes, produces, deprecated
  /// status, parameters, responses, and security requirements.
  ///
  /// The method first calls the superclass's encode method to handle any base
  /// properties, then proceeds to encode specific [APIOperation] properties.
  ///
  /// For complex properties like parameters and responses, it uses specialized
  /// encoding methods that handle lists of objects and object maps respectively.
  ///
  /// @param object The [KeyedArchive] where the encoded data will be stored.
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
