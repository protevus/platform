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

/// Represents the different types of security schemes available in the OpenAPI specification.
///
/// - [apiKey]: API key-based security scheme.
/// - [http]: HTTP authentication scheme.
/// - [oauth2]: OAuth 2.0 authentication scheme.
/// - [openID]: OpenID Connect authentication scheme.
enum APISecuritySchemeType { apiKey, http, oauth2, openID }

/// A utility class for encoding and decoding [APISecuritySchemeType] values.
///
/// This class provides static methods to convert between [APISecuritySchemeType] enum values
/// and their corresponding string representations as defined in the OpenAPI specification.
class APISecuritySchemeTypeCodec {
  /// Decodes a string representation of an API security scheme type into an [APISecuritySchemeType] enum value.
  ///
  /// This method takes a [String] parameter `type` and returns the corresponding
  /// [APISecuritySchemeType] enum value. If the input string doesn't match any
  /// known security scheme type, the method returns `null`.
  ///
  /// Parameters:
  ///   - type: A [String] representing the security scheme type.
  ///
  /// Returns:
  ///   The corresponding [APISecuritySchemeType] enum value, or `null` if no match is found.
  static APISecuritySchemeType? decode(String? type) {
    switch (type) {
      case "apiKey":
        return APISecuritySchemeType.apiKey;
      case "http":
        return APISecuritySchemeType.http;
      case "oauth2":
        return APISecuritySchemeType.oauth2;
      case "openID":
        return APISecuritySchemeType.openID;
      default:
        return null;
    }
  }

  /// Encodes an [APISecuritySchemeType] enum value into its corresponding string representation.
  ///
  /// This method takes an [APISecuritySchemeType] parameter `type` and returns the corresponding
  /// string representation as defined in the OpenAPI specification. If the input is `null` or
  /// doesn't match any known security scheme type, the method returns `null`.
  ///
  /// Parameters:
  ///   - type: An [APISecuritySchemeType] enum value to be encoded.
  ///
  /// Returns:
  ///   A [String] representing the security scheme type, or `null` if the input is `null` or invalid.
  static String? encode(APISecuritySchemeType? type) {
    switch (type) {
      case APISecuritySchemeType.apiKey:
        return "apiKey";
      case APISecuritySchemeType.http:
        return "http";
      case APISecuritySchemeType.oauth2:
        return "oauth2";
      case APISecuritySchemeType.openID:
        return "openID";
      default:
        return null;
    }
  }
}

/// Defines a security scheme that can be used by the operations.
///
/// Supported schemes are HTTP authentication, an API key (either as a header or as a query parameter),
/// OAuth2's common flows (implicit, password, application and access code) as defined in RFC6749,
/// and OpenID Connect Discovery.
///
/// This class represents different types of security schemes:
/// - HTTP authentication (using [APISecurityScheme.http])
/// - API Key (using [APISecurityScheme.apiKey])
/// - OAuth2 (using [APISecurityScheme.oauth2])
/// - OpenID Connect (using [APISecurityScheme.openID])
///
/// The [type] property determines which security scheme is being used, and the corresponding
/// properties should be set based on the chosen type.
///
/// When encoding or decoding, the class ensures that the required properties for each type
/// are present and correctly formatted.
class APISecurityScheme extends APIObject {
  /// Default constructor for APISecurityScheme.
  ///
  /// Creates an instance of APISecurityScheme with no initial values set.
  /// Use this constructor when you need to create an empty security scheme
  /// that will be populated later or when you want to manually set all properties.
  APISecurityScheme();

  /// Creates an empty instance of APISecurityScheme.
  ///
  /// This named constructor initializes an APISecurityScheme with no pre-set values.
  /// It can be used when you need to create a security scheme object that will be
  /// populated with data later or when you want to manually set all properties.
  APISecurityScheme.empty();

  /// Creates an instance of APISecurityScheme for HTTP authentication.
  ///
  /// This constructor initializes a security scheme of type [APISecuritySchemeType.http]
  /// with the specified [scheme].
  ///
  /// Parameters:
  ///   - scheme: A [String] representing the name of the HTTP Authorization scheme
  ///     to be used in the Authorization header as defined in RFC7235.
  ///
  /// Example:
  ///   ```dart
  ///   var httpScheme = APISecurityScheme.http('bearer');
  ///   ```
  APISecurityScheme.http(this.scheme) : type = APISecuritySchemeType.http;

  /// Creates an instance of APISecurityScheme for API Key authentication.
  ///
  /// This constructor initializes a security scheme of type [APISecuritySchemeType.apiKey]
  /// with the specified [name] and [location].
  ///
  /// Parameters:
  ///   - name: A [String] representing the name of the API key to be used.
  ///   - location: An [APIParameterLocation] specifying where the API key is expected
  ///     (e.g., query parameter, header, or cookie).
  ///
  /// Example:
  ///   ```dart
  ///   var apiKeyScheme = APISecurityScheme.apiKey('api_key', APIParameterLocation.header);
  ///   ```
  APISecurityScheme.apiKey(this.name, this.location)
      : type = APISecuritySchemeType.apiKey;

  /// Creates an instance of APISecurityScheme for OAuth2 authentication.
  ///
  /// This constructor initializes a security scheme of type [APISecuritySchemeType.oauth2]
  /// with the specified [flows].
  ///
  /// Parameters:
  ///   - flows: A [Map<String, APISecuritySchemeOAuth2Flow?>] representing the OAuth2 flows
  ///     supported by this security scheme. The keys should be flow types
  ///     (e.g., "implicit", "authorizationCode", "clientCredentials", "password"),
  ///     and the values should be instances of [APISecuritySchemeOAuth2Flow].
  ///
  /// Example:
  ///   ```dart
  ///   var oauth2Scheme = APISecurityScheme.oauth2({
  ///     'implicit': APISecuritySchemeOAuth2Flow.implicit(
  ///       Uri.parse('https://example.com/oauth/authorize'),
  ///       Uri.parse('https://example.com/oauth/token'),
  ///       {'read:api': 'Read access to protected resources'},
  ///     ),
  ///   });
  ///   ```
  APISecurityScheme.oauth2(this.flows) : type = APISecuritySchemeType.oauth2;

  /// Creates an instance of APISecurityScheme for OpenID Connect authentication.
  ///
  /// This constructor initializes a security scheme of type [APISecuritySchemeType.openID]
  /// with the specified [connectURL].
  ///
  /// Parameters:
  ///   - connectURL: A [Uri] representing the OpenID Connect URL used to discover
  ///     OAuth2 configuration values. This MUST be in the form of a URL.
  ///
  /// Example:
  ///   ```dart
  ///   var openIDScheme = APISecurityScheme.openID(
  ///     Uri.parse('https://example.com/.well-known/openid-configuration')
  ///   );
  ///   ```
  APISecurityScheme.openID(this.connectURL)
      : type = APISecuritySchemeType.openID;

  /// The type of the security scheme.
  ///
  /// This property defines the type of security scheme used, which determines
  /// how the security is enforced and what additional properties are required.
  ///
  /// REQUIRED. Valid values are:
  /// - "apiKey": For API key-based authentication
  /// - "http": For HTTP authentication schemes
  /// - "oauth2": For OAuth2 authentication
  /// - "openIdConnect": For OpenID Connect Discovery-based authentication
  ///
  /// The value of this property affects which other properties of the
  /// [APISecurityScheme] are required or applicable.
  APISecuritySchemeType? type;

  /// A short description for the security scheme.
  ///
  /// This property provides a brief explanation of the security scheme's purpose or usage.
  /// It can be used to give additional context or details about how the security mechanism works.
  ///
  /// The description MAY use CommonMark syntax for rich text representation, allowing
  /// for formatted text, links, and other markdown features to enhance readability.
  ///
  /// This field is optional but recommended to improve the documentation of the API's security measures.
  String? description;

  /// The name of the header, query or cookie parameter to be used.
  ///
  /// This property specifies the name of the parameter that will be used to pass the API key.
  /// It is applicable only when the security scheme type is [APISecuritySchemeType.apiKey].
  ///
  /// The value of this property depends on the [location] property:
  /// - If [location] is [APIParameterLocation.header], this is the name of the header.
  /// - If [location] is [APIParameterLocation.query], this is the name of the query parameter.
  /// - If [location] is [APIParameterLocation.cookie], this is the name of the cookie.
  ///
  /// This property is REQUIRED when the security scheme type is [APISecuritySchemeType.apiKey].
  String? name;

  /// The location of the API key.
  ///
  /// This property specifies where the API key should be sent in the request.
  /// It is only applicable and REQUIRED when the security scheme type is [APISecuritySchemeType.apiKey].
  ///
  /// For apiKey only. REQUIRED if so.
  APIParameterLocation? location;

  /// The name of the HTTP Authorization scheme to be used in the Authorization header as defined in RFC7235.
  ///
  /// This property specifies the name of the HTTP Authorization scheme that will be used
  /// in the Authorization header for requests. It is only applicable and REQUIRED when
  /// the security scheme type is [APISecuritySchemeType.http].
  ///
  /// Common values include:
  /// - "basic": for Basic Authentication
  /// - "bearer": for Bearer Token Authentication
  /// - "digest": for Digest Access Authentication
  ///
  /// The value of this property should correspond to the authentication scheme
  /// as defined in RFC7235 and should be registered in the IANA Authentication Scheme Registry.
  ///
  /// For http only. REQUIRED if so.
  String? scheme;

  /// A hint to the client to identify how the bearer token is formatted.
  ///
  /// This property provides additional information about the format of the bearer token
  /// when using HTTP authentication with a 'bearer' scheme. It is typically used for
  /// documentation purposes to help API consumers understand the expected token format.
  ///
  /// For http only.
  String? format;

  /// An object containing configuration information for the flow types supported in OAuth2 authentication.
  ///
  /// Fixed keys are implicit, password, clientCredentials and authorizationCode.
  ///
  /// For oauth2 only. REQUIRED if so.
  Map<String, APISecuritySchemeOAuth2Flow?>? flows;

  /// OpenId Connect URL to discover OAuth2 configuration values.
  ///
  /// This MUST be in the form of a URL.
  ///
  /// For openID only. REQUIRED if so.
  ///
  /// This property specifies the OpenID Connect URL used to discover OAuth2 configuration values.
  /// It is only applicable and REQUIRED when the security scheme type is [APISecuritySchemeType.openID].
  ///
  /// The URL should point to the OpenID Connect discovery endpoint, typically ending with
  /// '.well-known/openid-configuration'. This endpoint provides information about the OpenID Provider's
  /// configuration, including the OAuth 2.0 endpoint locations.
  ///
  /// Example:
  ///   ```dart
  ///   connectURL = Uri.parse('https://example.com/.well-known/openid-configuration');
  ///   ```
  ///
  /// Note: This URL must be a valid URI and should be accessible to clients for retrieving
  /// the necessary configuration information to initiate the OpenID Connect authentication flow.
  Uri? connectURL;

  /// Decodes the security scheme information from a [KeyedArchive] object.
  ///
  /// This method is responsible for populating the properties of the [APISecurityScheme]
  /// instance based on the data stored in the provided [KeyedArchive] object. It handles
  /// the decoding process for different security scheme types, including API key, OAuth2,
  /// HTTP authentication, and OpenID Connect.
  ///
  /// The method performs the following steps:
  /// 1. Calls the superclass's decode method.
  /// 2. Decodes the 'type' and 'description' fields.
  /// 3. Based on the security scheme type, decodes additional fields specific to that type:
  ///    - For API key: decodes 'name' and 'in' (location) fields.
  ///    - For OAuth2: decodes the 'flows' object.
  ///    - For HTTP: decodes 'scheme' and 'bearerFormat' fields.
  ///    - For OpenID Connect: decodes the 'openIdConnectUrl' field.
  ///
  /// If the security scheme type is not recognized, it throws an [ArgumentError].
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] containing the encoded security scheme data.
  ///
  /// Throws:
  ///   - [ArgumentError] if the security scheme type is null or not recognized.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    type = APISecuritySchemeTypeCodec.decode(object.decode("type"));
    description = object.decode("description");

    switch (type) {
      case APISecuritySchemeType.apiKey:
        {
          name = object.decode("name");
          location = APIParameterLocationCodec.decode(object.decode("in"));
        }
        break;
      case APISecuritySchemeType.oauth2:
        {
          flows = object.decodeObjectMap(
            "flows",
            () => APISecuritySchemeOAuth2Flow.empty(),
          );
        }
        break;
      case APISecuritySchemeType.http:
        {
          scheme = object.decode("scheme");
          format = object.decode("bearerFormat");
        }
        break;
      case APISecuritySchemeType.openID:
        {
          connectURL = object.decode("openIdConnectUrl");
        }
        break;
      default:
        throw ArgumentError(
          "APISecurityScheme must have non-null values for: 'type'.",
        );
    }
  }

  /// Encodes the security scheme information into a [KeyedArchive] object.
  ///
  /// This method is responsible for encoding the properties of the [APISecurityScheme]
  /// instance into the provided [KeyedArchive] object. It handles the encoding process
  /// for different security scheme types, including API key, OAuth2, HTTP authentication,
  /// and OpenID Connect.
  ///
  /// The method performs the following steps:
  /// 1. Calls the superclass's encode method.
  /// 2. Checks if the 'type' property is set, throwing an [ArgumentError] if it's null.
  /// 3. Encodes the 'type' and 'description' fields.
  /// 4. Based on the security scheme type, encodes additional fields specific to that type:
  ///    - For API key: encodes 'name' and 'in' (location) fields.
  ///    - For OAuth2: encodes the 'flows' object.
  ///    - For HTTP: encodes 'scheme' and 'bearerFormat' fields.
  ///    - For OpenID Connect: encodes the 'openIdConnectUrl' field.
  ///
  /// For each type, it checks if the required properties are non-null and throws
  /// an [ArgumentError] if any required property is missing.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] to store the encoded security scheme data.
  ///
  /// Throws:
  ///   - [ArgumentError] if the security scheme type is null or if any required
  ///     property for a specific type is missing.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (type == null) {
      throw ArgumentError(
        "APISecurityScheme must have non-null values for: 'type'.",
      );
    }

    object.encode("type", APISecuritySchemeTypeCodec.encode(type));
    object.encode("description", description);

    switch (type) {
      case APISecuritySchemeType.apiKey:
        {
          if (name == null || location == null) {
            throw ArgumentError(
              "APISecurityScheme with 'apiKey' type must have non-null values for: 'name', 'location'.",
            );
          }

          object.encode("name", name);
          object.encode("in", APIParameterLocationCodec.encode(location));
        }
        break;
      case APISecuritySchemeType.oauth2:
        {
          if (flows == null) {
            throw ArgumentError(
              "APISecurityScheme with 'oauth2' type must have non-null values for: 'flows'.",
            );
          }

          object.encodeObjectMap("flows", flows);
        }
        break;
      case APISecuritySchemeType.http:
        {
          if (scheme == null) {
            throw ArgumentError(
              "APISecurityScheme with 'http' type must have non-null values for: 'scheme'.",
            );
          }

          object.encode("scheme", scheme);
          object.encode("bearerFormat", format);
        }
        break;
      case APISecuritySchemeType.openID:
        {
          if (connectURL == null) {
            throw ArgumentError(
              "APISecurityScheme with 'openID' type must have non-null values for: 'connectURL'.",
            );
          }
          object.encode("openIdConnectUrl", connectURL);
        }
        break;
      default:
        throw ArgumentError(
          "APISecurityScheme must have non-null values for: 'type'.",
        );
    }
  }
}

/// This class represents the configuration for different OAuth 2.0 flows as defined in the OpenAPI specification.
/// It supports the following OAuth 2.0 flows:
/// - Authorization Code
/// - Implicit
/// - Resource Owner Password Credentials
/// - Client Credentials
///
/// Each flow type has its own constructor with the required parameters:
/// - [APISecuritySchemeOAuth2Flow.code]: For Authorization Code flow
/// - [APISecuritySchemeOAuth2Flow.implicit]: For Implicit flow
/// - [APISecuritySchemeOAuth2Flow.password]: For Resource Owner Password Credentials flow
/// - [APISecuritySchemeOAuth2Flow.client]: For Client Credentials flow
///
/// The class provides properties for configuring the OAuth 2.0 endpoints and available scopes:
/// - [authorizationURL]: The authorization endpoint URL (required for Authorization Code and Implicit flows)
/// - [tokenURL]: The token endpoint URL (required for Authorization Code, Password, and Client Credentials flows)
/// - [refreshURL]: The refresh token endpoint URL (optional)
/// - [scopes]: A map of available scopes and their descriptions (required for all flows)
///
/// This class extends [APIObject] and provides methods for encoding and decoding its properties
/// to and from a [KeyedArchive] object, which is used for serialization and deserialization.
class APISecuritySchemeOAuth2Flow extends APIObject {
  /// Creates an empty instance of APISecuritySchemeOAuth2Flow.
  ///
  /// This constructor initializes an APISecuritySchemeOAuth2Flow with no pre-set values.
  /// It can be used when you need to create an OAuth2 flow object that will be
  /// populated with data later or when you want to manually set all properties.
  APISecuritySchemeOAuth2Flow.empty();

  /// Creates an instance of APISecuritySchemeOAuth2Flow for the Authorization Code flow.
  ///
  /// This constructor initializes an OAuth2 flow configuration for the Authorization Code grant type.
  ///
  /// Parameters:
  ///   - authorizationURL: The authorization endpoint URL. REQUIRED.
  ///   - tokenURL: The token endpoint URL. REQUIRED.
  ///   - refreshURL: The refresh token endpoint URL. Optional.
  ///   - scopes: A map of available scopes and their descriptions. REQUIRED.
  ///
  /// All URL parameters should be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   var codeFlow = APISecuritySchemeOAuth2Flow.code(
  ///     Uri.parse('https://example.com/oauth/authorize'),
  ///     Uri.parse('https://example.com/oauth/token'),
  ///     Uri.parse('https://example.com/oauth/refresh'),
  ///     {'read:api': 'Read access to protected resources'},
  ///   );
  ///   ```
  APISecuritySchemeOAuth2Flow.code(
    this.authorizationURL,
    this.tokenURL,
    this.refreshURL,
    this.scopes,
  );

  /// Creates an instance of APISecuritySchemeOAuth2Flow for the Implicit flow.
  ///
  /// This constructor initializes an OAuth2 flow configuration for the Implicit grant type.
  ///
  /// Parameters:
  ///   - authorizationURL: The authorization endpoint URL. REQUIRED.
  ///   - refreshURL: The refresh token endpoint URL. Optional.
  ///   - scopes: A map of available scopes and their descriptions. REQUIRED.
  ///
  /// The authorizationURL should be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   var implicitFlow = APISecuritySchemeOAuth2Flow.implicit(
  ///     Uri.parse('https://example.com/oauth/authorize'),
  ///     Uri.parse('https://example.com/oauth/refresh'),
  ///     {'read:api': 'Read access to protected resources'},
  ///   );
  ///   ```
  APISecuritySchemeOAuth2Flow.implicit(
    this.authorizationURL,
    this.refreshURL,
    this.scopes,
  );

  /// Creates an instance of APISecuritySchemeOAuth2Flow for the Resource Owner Password Credentials flow.
  ///
  /// This constructor initializes an OAuth2 flow configuration for the Password grant type.
  ///
  /// Parameters:
  ///   - tokenURL: The token endpoint URL. REQUIRED.
  ///   - refreshURL: The refresh token endpoint URL. Optional.
  ///   - scopes: A map of available scopes and their descriptions. REQUIRED.
  ///
  /// The tokenURL should be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   var passwordFlow = APISecuritySchemeOAuth2Flow.password(
  ///     Uri.parse('https://example.com/oauth/token'),
  ///     Uri.parse('https://example.com/oauth/refresh'),
  ///     {'read:api': 'Read access to protected resources'},
  ///   );
  ///   ```
  APISecuritySchemeOAuth2Flow.password(
    this.tokenURL,
    this.refreshURL,
    this.scopes,
  );

  /// Creates an instance of APISecuritySchemeOAuth2Flow for the Client Credentials flow.
  ///
  /// This constructor initializes an OAuth2 flow configuration for the Client Credentials grant type.
  ///
  /// Parameters:
  ///   - tokenURL: The token endpoint URL. REQUIRED.
  ///   - refreshURL: The refresh token endpoint URL. Optional.
  ///   - scopes: A map of available scopes and their descriptions. REQUIRED.
  ///
  /// The tokenURL should be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   var clientFlow = APISecuritySchemeOAuth2Flow.client(
  ///     Uri.parse('https://example.com/oauth/token'),
  ///     Uri.parse('https://example.com/oauth/refresh'),
  ///     {'read:api': 'Read access to protected resources'},
  ///   );
  ///   ```
  APISecuritySchemeOAuth2Flow.client(
    this.tokenURL,
    this.refreshURL,
    this.scopes,
  );

  /// The authorization URL to be used for this flow.
  ///
  /// This property represents the authorization endpoint URL for OAuth 2.0 flows
  /// that require user interaction, such as the Authorization Code flow and the
  /// Implicit flow.
  ///
  /// The authorization URL is the endpoint where the resource owner (user) is
  /// redirected to grant authorization to the client application. It's typically
  /// used to initiate the OAuth 2.0 authorization process.
  ///
  /// This property is REQUIRED for flows that use an authorization endpoint
  /// (Authorization Code and Implicit flows). It MUST be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   authorizationURL = Uri.parse('https://example.com/oauth/authorize');
  ///   ```
  ///
  /// Note: This property should not be set for flows that don't use an
  /// authorization endpoint, such as the Client Credentials flow or the
  /// Resource Owner Password Credentials flow.
  Uri? authorizationURL;

  /// The token URL to be used for this flow.
  ///
  /// This property represents the token endpoint URL for OAuth 2.0 flows.
  /// The token URL is the endpoint where the client application exchanges
  /// an authorization grant for an access token.
  ///
  /// This property is REQUIRED for flows that use a token endpoint
  /// (Authorization Code, Resource Owner Password Credentials, and Client Credentials flows).
  /// It MUST be in the form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   tokenURL = Uri.parse('https://example.com/oauth/token');
  ///   ```
  ///
  /// Note: This property is not used in the Implicit flow, as the access token
  /// is returned directly from the authorization endpoint in that flow.
  Uri? tokenURL;

  /// The URL to be used for obtaining refresh tokens.
  ///
  /// This property represents the refresh token endpoint URL for OAuth 2.0 flows
  /// that support token refresh. The refresh URL is used to obtain a new access token
  /// using a refresh token, without requiring the user to re-authenticate.
  ///
  /// This property is OPTIONAL for all OAuth 2.0 flows. If provided, it MUST be in the
  /// form of a valid URL.
  ///
  /// Example:
  ///   ```dart
  ///   refreshURL = Uri.parse('https://example.com/oauth/refresh');
  ///   ```
  ///
  /// Note: Not all OAuth 2.0 implementations support refresh tokens. When supported,
  /// this URL allows clients to refresh their access tokens without user interaction,
  /// improving the user experience for long-lived applications.
  Uri? refreshURL;

  /// The available scopes for the OAuth2 security scheme.
  ///
  /// This property represents a map of OAuth 2.0 scopes available for the security scheme.
  /// Each key in the map is a scope name, and its corresponding value is a short description of that scope.
  ///
  /// Scopes are used to define and limit the level of access granted to a client application.
  /// They allow for fine-grained control over the permissions given to a client when accessing protected resources.
  ///
  /// This property is REQUIRED for all OAuth 2.0 flows defined in the OpenAPI specification.
  ///
  /// Example:
  ///   ```dart
  ///   scopes = {
  ///     'read:users': 'Read access to user information',
  ///     'write:users': 'Write access to user information',
  ///   };
  ///   ```
  ///
  /// Note: The descriptions should be concise yet informative, helping API consumers
  /// understand the purpose and implications of each scope.
  Map<String, String>? scopes;

  /// Encodes the OAuth2 flow configuration into a [KeyedArchive] object.
  ///
  /// This method is responsible for serializing the properties of the [APISecuritySchemeOAuth2Flow]
  /// instance into the provided [KeyedArchive] object. It encodes the following properties:
  ///
  /// - authorizationURL: The authorization endpoint URL (if applicable)
  /// - tokenURL: The token endpoint URL (if applicable)
  /// - refreshURL: The refresh token endpoint URL (if applicable)
  /// - scopes: A map of available scopes and their descriptions
  ///
  /// This method first calls the superclass's encode method to handle any inherited properties,
  /// then encodes the specific properties of the OAuth2 flow configuration.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] to store the encoded OAuth2 flow configuration data.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("authorizationUrl", authorizationURL);
    object.encode("tokenUrl", tokenURL);
    object.encode("refreshUrl", refreshURL);
    object.encode("scopes", scopes);
  }

  /// Decodes the OAuth2 flow configuration from a [KeyedArchive] object.
  ///
  /// This method is responsible for deserializing the properties of the [APISecuritySchemeOAuth2Flow]
  /// instance from the provided [KeyedArchive] object. It decodes the following properties:
  ///
  /// - authorizationURL: The authorization endpoint URL (if present)
  /// - tokenURL: The token endpoint URL (if present)
  /// - refreshURL: The refresh token endpoint URL (if present)
  /// - scopes: A map of available scopes and their descriptions
  ///
  /// This method first calls the superclass's decode method to handle any inherited properties,
  /// then decodes the specific properties of the OAuth2 flow configuration.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] containing the encoded OAuth2 flow configuration data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    authorizationURL = object.decode("authorizationUrl");

    tokenURL = object.decode("tokenUrl");
    refreshURL = object.decode("refreshUrl");
    scopes = object.decode<Map<String, String>>("scopes");
  }
}

/// Represents a security requirement in the OpenAPI specification.
///
/// The name used for each property MUST correspond to a security scheme declared in [APIComponents.securitySchemes].
/// [APISecurityRequirement] that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.
/// When a list of [APISecurityRequirement] is defined on the [APIDocument] or [APIOperation], only one of [APISecurityRequirement] in the list needs to be satisfied to authorize the request.
class APISecurityRequirement extends APIObject {
  /// Creates an [APISecurityRequirement] instance with the specified security requirements.
  ///
  /// The [requirements] parameter is a map where each key corresponds to a security scheme
  /// declared in [APIComponents.securitySchemes], and the value is a list of scope names
  /// required for execution (for OAuth2 or OpenID schemes) or an empty list (for other schemes).
  ///
  /// Example:
  ///   ```dart
  ///   var securityRequirement = APISecurityRequirement({
  ///     'api_key': [],
  ///     'oauth2': ['read:api', 'write:api'],
  ///   });
  ///   ```
  ///
  /// Note: For security schemes other than OAuth2 or OpenID, the list should be empty.
  APISecurityRequirement(this.requirements);

  /// Creates an empty instance of APISecurityRequirement.
  ///
  /// This constructor initializes an APISecurityRequirement with no pre-set security requirements.
  /// It can be used when you need to create a security requirement object that will be
  /// populated with data later or when you want to manually set the requirements.
  APISecurityRequirement.empty();

  /// A map representing the security requirements for an API operation or the entire API.
  ///
  /// If the security scheme is of type [APISecuritySchemeType.oauth2] or [APISecuritySchemeType.openID], then the value is a list of scope names required for the execution. For other security scheme types, the array MUST be empty.
  Map<String, List<String>>? requirements;

  /// Encodes the security requirements into a [KeyedArchive] object.
  ///
  /// This method is responsible for serializing the [requirements] of the [APISecurityRequirement]
  /// instance into the provided [KeyedArchive] object. It performs the following steps:
  ///
  /// 1. Calls the superclass's encode method to handle any inherited properties.
  /// 2. If [requirements] is not null, it iterates through each key-value pair in the map.
  /// 3. For each pair, it encodes the key (security scheme name) and its corresponding value
  ///    (list of scope names or an empty list) into the [KeyedArchive] object.
  ///
  /// This encoding process allows the security requirements to be properly serialized
  /// for use in the OpenAPI specification.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] to store the encoded security requirement data.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (requirements != null) {
      requirements!.forEach((key, value) {
        object.encode(key, value);
      });
    }
  }

  /// Decodes the security requirements from a [KeyedArchive] object.
  ///
  /// This method is responsible for deserializing the security requirements stored in the
  /// provided [KeyedArchive] object into the [requirements] property of this [APISecurityRequirement]
  /// instance. It performs the following steps:
  ///
  /// 1. Calls the superclass's decode method to handle any inherited properties.
  /// 2. Iterates through all keys in the [KeyedArchive] object.
  /// 3. For each key, it attempts to decode the value as an [Iterable<dynamic>].
  /// 4. If successful, it converts the decoded value to a [List<String>].
  /// 5. If [requirements] is null, it initializes it as an empty map.
  /// 6. Adds the key-value pair to the [requirements] map, where the key is the security
  ///    scheme name and the value is the list of scope names or an empty list.
  ///
  /// This decoding process allows the security requirements to be properly deserialized
  /// from the OpenAPI specification format.
  ///
  /// Parameters:
  ///   - object: A [KeyedArchive] containing the encoded security requirement data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    for (final key in object.keys) {
      final decoded = object.decode<Iterable<dynamic>>(key);
      if (decoded != null) {
        final req = List<String>.from(decoded);
        requirements ??= <String, List<String>>{};
        requirements![key] = req;
      }
    }
  }
}
