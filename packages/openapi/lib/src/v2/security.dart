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

/// Represents a OAuth 2.0 security scheme flow in the OpenAPI specification.
///
/// This enum defines the different types of OAuth 2.0 flows that can be used
/// in an OpenAPI security scheme. The available flows are:
///
/// - [implicit]: The implicit grant flow.
/// - [password]: The resource owner password credentials grant flow.
/// - [application]: The client credentials grant flow.
/// - [authorizationCode]: The authorization code grant flow.
///
/// These flows correspond to the standard OAuth 2.0 grant types as defined
/// in RFC 6749.
enum APISecuritySchemeFlow {
  implicit,
  password,
  application,
  authorizationCode
}

/// A utility class for encoding and decoding [APISecuritySchemeFlow] values.
///
/// This class provides static methods to convert between [APISecuritySchemeFlow] enum values
/// and their corresponding string representations used in the OpenAPI specification.
class APISecuritySchemeFlowCodec {
  /// Decodes a string representation of an OAuth 2.0 flow into an [APISecuritySchemeFlow] enum value.
  ///
  /// This method takes a [String] parameter [flow] and returns the corresponding
  /// [APISecuritySchemeFlow] enum value. If the input string doesn't match any
  /// known flow, the method returns null.
  ///
  /// The mapping is as follows:
  /// - "accessCode" -> [APISecuritySchemeFlow.authorizationCode]
  /// - "password" -> [APISecuritySchemeFlow.password]
  /// - "implicit" -> [APISecuritySchemeFlow.implicit]
  /// - "application" -> [APISecuritySchemeFlow.application]
  ///
  /// Parameters:
  ///   [flow]: A string representation of the OAuth 2.0 flow.
  ///
  /// Returns:
  ///   The corresponding [APISecuritySchemeFlow] enum value, or null if no match is found.
  static APISecuritySchemeFlow? decode(String? flow) {
    switch (flow) {
      case "accessCode":
        return APISecuritySchemeFlow.authorizationCode;
      case "password":
        return APISecuritySchemeFlow.password;
      case "implicit":
        return APISecuritySchemeFlow.implicit;
      case "application":
        return APISecuritySchemeFlow.application;
      default:
        return null;
    }
  }

  /// Encodes an [APISecuritySchemeFlow] enum value into its string representation.
  ///
  /// This method takes an [APISecuritySchemeFlow] enum value as input and returns
  /// the corresponding string representation used in the OpenAPI specification.
  /// If the input is null or doesn't match any known flow, the method returns null.
  ///
  /// The mapping is as follows:
  /// - [APISecuritySchemeFlow.authorizationCode] -> "accessCode"
  /// - [APISecuritySchemeFlow.password] -> "password"
  /// - [APISecuritySchemeFlow.implicit] -> "implicit"
  /// - [APISecuritySchemeFlow.application] -> "application"
  ///
  /// Parameters:
  ///   [flow]: An [APISecuritySchemeFlow] enum value to be encoded.
  ///
  /// Returns:
  ///   The string representation of the OAuth 2.0 flow, or null if no match is found.
  static String? encode(APISecuritySchemeFlow? flow) {
    switch (flow) {
      case APISecuritySchemeFlow.authorizationCode:
        return "accessCode";
      case APISecuritySchemeFlow.password:
        return "password";
      case APISecuritySchemeFlow.implicit:
        return "implicit";
      case APISecuritySchemeFlow.application:
        return "application";
      default:
        return null;
    }
  }
}

/// Represents a security scheme in the OpenAPI specification.
///
/// This class defines various types of security schemes that can be used in an OpenAPI document.
/// It supports three main types of security schemes:
/// 1. Basic Authentication
/// 2. API Key
/// 3. OAuth2
///
/// The class provides constructors for each type of security scheme and methods to encode and decode
/// the security scheme information to and from a KeyedArchive object.
///
/// Properties:
/// - [type]: The type of the security scheme (e.g., "basic", "apiKey", "oauth2").
/// - [description]: An optional description of the security scheme.
/// - [apiKeyName]: The name of the API key (for API Key type).
/// - [apiKeyLocation]: The location of the API key (for API Key type).
/// - [oauthFlow]: The OAuth2 flow type (for OAuth2 type).
/// - [authorizationURL]: The authorization URL (for OAuth2 type).
/// - [tokenURL]: The token URL (for OAuth2 type).
/// - [scopes]: A map of available scopes (for OAuth2 type).
///
/// The class also includes utility methods and properties:
/// - [isOAuth2]: A getter that returns true if the security scheme is OAuth2.
/// - [castMap]: Provides casting information for the 'scopes' property.
/// - [decode]: Decodes the security scheme information from a KeyedArchive object.
/// - [encode]: Encodes the security scheme information into a KeyedArchive object.
class APISecurityScheme extends APIObject {
  /// Default constructor for the [APISecurityScheme] class.
  ///
  /// This constructor creates an instance of [APISecurityScheme] without initializing any specific properties.
  /// It's typically used when you want to create a security scheme object and set its properties manually later.
  APISecurityScheme();

  /// Creates a basic authentication security scheme.
  ///
  /// This constructor initializes an [APISecurityScheme] instance
  /// with the type set to "basic", representing HTTP Basic Authentication.
  /// Basic Authentication allows API clients to authenticate by providing
  /// their username and password.
  ///
  /// Example usage:
  /// ```dart
  /// var basicAuth = APISecurityScheme.basic();
  /// ```
  APISecurityScheme.basic() {
    type = "basic";
  }

  /// Creates an API Key security scheme.
  ///
  /// This constructor initializes an [APISecurityScheme] instance
  /// with the type set to "apiKey". It requires two parameters:
  ///
  /// - [apiKeyName]: The name of the API key to be used for authentication.
  /// - [apiKeyLocation]: The location where the API key should be included in the request,
  ///   typically specified as a value from the [APIParameterLocation] enum.
  ///
  /// API Key authentication allows API clients to authenticate by including a specific
  /// key in their requests, either in the header, query parameters, or cookies.
  ///
  /// Example usage:
  /// ```dart
  /// var apiKeyAuth = APISecurityScheme.apiKey('X-API-Key', APIParameterLocation.header);
  /// ```
  APISecurityScheme.apiKey(this.apiKeyName, this.apiKeyLocation) {
    type = "apiKey";
  }

  /// Creates an OAuth2 security scheme.
  ///
  /// This constructor initializes an [APISecurityScheme] instance
  /// with the type set to "oauth2". It requires one mandatory parameter:
  ///
  /// - [oauthFlow]: The OAuth2 flow type, specified as an [APISecuritySchemeFlow] enum value.
  ///
  /// Optional parameters include:
  ///
  /// - [authorizationURL]: The authorization URL for the OAuth2 flow.
  /// - [tokenURL]: The token URL for the OAuth2 flow.
  /// - [scopes]: A map of available scopes for the OAuth2 flow. Defaults to an empty map.
  ///
  /// OAuth2 allows API clients to obtain limited access to user accounts on an HTTP service,
  /// either on behalf of a user or on behalf of the client itself.
  ///
  /// Example usage:
  /// ```dart
  /// var oauth2Auth = APISecurityScheme.oauth2(
  ///   APISecuritySchemeFlow.authorizationCode,
  ///   authorizationURL: 'https://example.com/oauth/authorize',
  ///   tokenURL: 'https://example.com/oauth/token',
  ///   scopes: {'read': 'Read access', 'write': 'Write access'}
  /// );
  /// ```
  APISecurityScheme.oauth2(
    this.oauthFlow, {
    this.authorizationURL,
    this.tokenURL,
    this.scopes = const {},
  }) {
    type = "oauth2";
  }

  /// The type of the security scheme.
  ///
  /// This property specifies the type of the security scheme. It can be one of:
  /// - "basic" for Basic Authentication
  /// - "apiKey" for API Key Authentication
  /// - "oauth2" for OAuth2 Authentication
  ///
  /// This field is required and must be set for the security scheme to be valid.
  late String type;

  /// A description of the security scheme.
  ///
  /// This optional property provides additional information about the security scheme.
  /// It can be used to explain how the security scheme works, its purpose, or any
  /// specific requirements for using it.
  ///
  /// The value is a string that can contain multiple lines of text if needed.
  /// If not specified, this property will be null.
  String? description;

  /// The name of the API key for API Key authentication.
  ///
  /// This property is used when the security scheme type is "apiKey".
  /// It specifies the name of the API key that should be used in the request.
  /// For example, if set to "X-API-Key", the client would need to include
  /// this header in their request: "X-API-Key: <actual-api-key-value>".
  ///
  /// This property is nullable and will be null for non-API Key security schemes.
  String? apiKeyName;

  /// The location of the API key in the request.
  ///
  /// This property specifies where the API key should be included in the request
  /// when using API Key authentication. It can be one of the following:
  /// - [APIParameterLocation.query] for including the key in the query parameters
  /// - [APIParameterLocation.header] for including the key in the request headers
  /// - [APIParameterLocation.cookie] for including the key in a cookie
  ///
  /// This property is nullable and will be null for non-API Key security schemes.
  /// It is typically used in conjunction with [apiKeyName] to define how an API key
  /// should be sent with requests.
  APIParameterLocation? apiKeyLocation;

  /// The OAuth2 flow type for this security scheme.
  ///
  /// This property specifies the type of OAuth2 flow used when the security scheme
  /// is of type "oauth2". It is represented by the [APISecuritySchemeFlow] enum,
  /// which can have one of the following values:
  /// - [APISecuritySchemeFlow.implicit]
  /// - [APISecuritySchemeFlow.password]
  /// - [APISecuritySchemeFlow.application]
  /// - [APISecuritySchemeFlow.authorizationCode]
  ///
  /// This property is nullable and will be null for non-OAuth2 security schemes.
  /// It is used in conjunction with other OAuth2-specific properties like
  /// [authorizationURL], [tokenURL], and [scopes] to fully define the OAuth2 flow.
  APISecuritySchemeFlow? oauthFlow;
  String? authorizationURL;
  String? tokenURL;
  Map<String, String>? scopes;

  bool get isOAuth2 {
    return type == "oauth2";
  }

  /// Provides a mapping of property names to their respective casting functions.
  ///
  /// This getter overrides the base class implementation to specify custom casting
  /// behavior for the 'scopes' property of the [APISecurityScheme] class.
  ///
  /// Returns:
  ///   A [Map] where the key is the property name ('scopes') and the value is a [cast.Cast]
  ///   object that defines how to cast the property's value. In this case, it specifies
  ///   that 'scopes' should be cast as a Map with string keys and string values.
  @override
  Map<String, cast.Cast> get castMap =>
      {"scopes": const cast.Map(cast.string, cast.string)};

  /// Decodes the security scheme information from a [KeyedArchive] object.
  ///
  /// This method populates the properties of the [APISecurityScheme] instance
  /// based on the data stored in the provided [KeyedArchive] object. It handles
  /// different types of security schemes (basic, OAuth2, and API key) and
  /// decodes their specific properties accordingly.
  ///
  /// The method performs the following tasks:
  /// 1. Calls the superclass's decode method.
  /// 2. Decodes the 'type' and 'description' properties.
  /// 3. Based on the 'type', decodes additional properties:
  ///    - For 'basic', no additional properties are decoded.
  ///    - For 'oauth2', decodes 'flow', 'authorizationUrl', 'tokenUrl', and 'scopes'.
  ///    - For 'apiKey', decodes 'name' and 'in' (location) properties.
  ///
  /// Parameters:
  ///   [object]: A [KeyedArchive] containing the encoded security scheme information.
  ///
  /// Note: This method assumes that the 'scopes' property, when present, is
  /// a non-null Map<String, String>. It will throw an error if this assumption
  /// is not met.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    type = object.decode("type") ?? "oauth2";
    description = object.decode("description");

    if (type == "basic") {
    } else if (type == "oauth2") {
      oauthFlow = APISecuritySchemeFlowCodec.decode(object.decode("flow"));
      authorizationURL = object.decode("authorizationUrl");
      tokenURL = object.decode("tokenUrl");
      final scopeMap = object.decode<Map<String, String>>("scopes")!;
      scopes = Map<String, String>.from(scopeMap);
    } else if (type == "apiKey") {
      apiKeyName = object.decode("name");
      apiKeyLocation = APIParameterLocationCodec.decode(object.decode("in"));
    }
  }

  /// Encodes the security scheme information into a [KeyedArchive] object.
  ///
  /// This method serializes the properties of the [APISecurityScheme] instance
  /// into the provided [KeyedArchive] object. It handles different types of
  /// security schemes (basic, OAuth2, and API key) and encodes their specific
  /// properties accordingly.
  ///
  /// The method performs the following tasks:
  /// 1. Calls the superclass's encode method.
  /// 2. Encodes the 'type' and 'description' properties.
  /// 3. Based on the 'type', encodes additional properties:
  ///    - For 'basic', no additional properties are encoded.
  ///    - For 'apiKey', encodes 'name' and 'in' (location) properties.
  ///    - For 'oauth2', encodes 'flow', 'authorizationUrl', 'tokenUrl', and 'scopes'.
  ///
  /// Parameters:
  ///   [object]: A [KeyedArchive] to store the encoded security scheme information.
  ///
  /// Note: This method assumes that all required properties for each security
  /// scheme type are properly set. It's the responsibility of the caller to
  /// ensure that the object is in a valid state before encoding.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("type", type);
    object.encode("description", description);

    if (type == "basic") {
      /* nothing to do */
    } else if (type == "apiKey") {
      object.encode("name", apiKeyName);
      object.encode("in", APIParameterLocationCodec.encode(apiKeyLocation));
    } else if (type == "oauth2") {
      object.encode("flow", APISecuritySchemeFlowCodec.encode(oauthFlow));

      object.encode("authorizationUrl", authorizationURL);
      object.encode("tokenUrl", tokenURL);
      object.encode("scopes", scopes);
    }
  }
}
