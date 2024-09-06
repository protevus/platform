/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:io';

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_auth/auth.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';

/// Controller for issuing and refreshing OAuth 2.0 access tokens.
///
/// This controller issues and refreshes access tokens. Access tokens are issued for valid username and password (resource owner password grant)
/// or for an authorization code (authorization code grant) from a [AuthRedirectController].
///
/// See operation method [grant] for more details.
///
/// Usage:
///
///       router
///         .route("/auth/token")
///         .link(() => new AuthController(authServer));
///
class AuthController extends ResourceController {
  /// Creates a new instance of an [AuthController].
  ///
  /// [authServer] is the isRequired authorization server that grants tokens.
  AuthController(this.authServer) {
    acceptedContentTypes = [
      ContentType("application", "x-www-form-urlencoded")
    ];
  }

  /// A reference to the [AuthServer] this controller uses to grant tokens.
  final AuthServer authServer;

  /// Required basic authentication Authorization header containing client ID and secret for the authenticating client.
  ///
  /// Requests must contain the client ID and client secret in the authorization header,
  /// using the basic authentication scheme. If the client is a public client - i.e., no client secret -
  /// the client secret is omitted from the Authorization header.
  ///
  /// Example: com.stablekernel.public is a public client. The Authorization header should be constructed
  /// as so:
  ///
  ///         Authorization: Basic base64("com.stablekernel.public:")
  ///
  /// Notice the trailing colon indicates that the client secret is the empty string.
  @Bind.header(HttpHeaders.authorizationHeader)
  String? authHeader;

  final AuthorizationBasicParser _parser = const AuthorizationBasicParser();

  /// This class, AuthController, is responsible for handling OAuth 2.0 token operations.
  /// It provides functionality for issuing and refreshing access tokens using various grant types.
  ///
  /// Key features:
  /// - Supports 'password', 'refresh_token', and 'authorization_code' grant types
  /// - Handles client authentication via Basic Authorization header
  /// - Processes token requests and returns RFC6749 compliant responses
  /// - Includes error handling for various authentication scenarios
  /// - Provides OpenAPI documentation support
  ///
  /// The main method, 'grant', processes token requests based on the provided grant type.
  /// It interacts with an AuthServer to perform the actual authentication and token generation.
  ///
  /// This controller also includes methods for generating API documentation,
  /// including operation parameters, request body, and responses.
  ///
  /// Usage:
  ///   router
  ///     .route("/auth/token")
  ///     .link(() => new AuthController(authServer));
  ///
  /// Note: This controller expects client credentials to be provided in the Authorization header
  /// using the Basic authentication scheme.
  ///
  /// Creates or refreshes an authentication token.
  ///
  /// When grant_type is 'password', there must be username and password values.
  /// When grant_type is 'refresh_token', there must be a refresh_token value.
  /// When grant_type is 'authorization_code', there must be a authorization_code value.
  ///
  /// This endpoint requires client_id authentication. The Authorization header must
  /// include a valid Client ID and Secret in the Basic authorization scheme format.
  @Operation.post()
  Future<Response> grant({
    /// The username of the user attempting to authenticate.
    ///
    /// This parameter is typically used with the 'password' grant type.
    /// It should be provided as a query parameter in the request.
    @Bind.query("username") String? username,

    /// The password of the user attempting to authenticate.
    ///
    /// This parameter is typically used with the 'password' grant type.
    /// It should be provided as a query parameter in the request.
    /// Note: Sending passwords as query parameters is not recommended for production environments due to security concerns.
    @Bind.query("password") String? password,

    /// The refresh token used to obtain a new access token.
    ///
    /// This parameter is typically used with the 'refresh_token' grant type.
    /// It should be provided as a query parameter in the request.
    /// The refresh token is used to request a new access token when the current one has expired.
    ///
    /// Example:
    ///     curl -X POST -d "grant_type=refresh_token&refresh_token=<refresh_token>" https://example.com/auth/token
    ///
    /// Note: The refresh token should be securely stored and managed by the client application.
    /// It is important to handle refresh tokens with care to prevent unauthorized access to user resources.
    ///
    /// See also:
    /// - [RFC 6749, Section 6](https://tools.ietf.org/html/rfc6749#section-6) for more details on the refresh token grant type.
    /// - [OAuth 2.0 Refresh Token Grant](https://oauth.net/2/grant-types/refresh-token/) for a detailed explanation of the refresh token grant type.
    /// - [OAuth 2.0 Security Best Current Practice](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-13#section-2.1) for security considerations when implementing OAuth 2.0.
    @Bind.query("refresh_token") String? refreshToken,

    /// The authorization code obtained from the authorization server.
    ///
    /// This parameter is typically used with the 'authorization_code' grant type.
    /// It should be provided as a query parameter in the request.
    /// The authorization code is used to request an access token after the user has granted permission to the client application.
    ///
    /// Example:
    ///     curl -X POST -d "grant_type=authorization_code&code=<authorization_code>&redirect_uri=<redirect_uri>" https://example.com/auth/token
    ///
    /// Note: The authorization code should be securely transmitted and used only once to prevent replay attacks.
    /// It is important to handle authorization codes with care to protect user data and ensure the security of the OAuth 2.0 flow.
    ///
    /// See also:
    /// - [RFC 6749, Section 4.1.3](https://tools.ietf.org/html/rfc6749#section-4.1.3) for more details on the authorization code grant type.
    /// - [OAuth 2.0 Authorization Code Grant](https://oauth.net/2/grant-types/authorization-code/) for a detailed explanation of the authorization code grant type.
    /// - [OAuth 2.0 Security Best Current Practice](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-13#section-2.1) for security considerations when implementing OAuth 2.0.
    @Bind.query("code") String? authCode,

    /// The URI to which the authorization server will redirect the user-agent after obtaining authorization.
    ///
    /// This parameter is typically used with the 'authorization_code' grant type.
    /// It should be provided as a query parameter in the request.
    /// The redirect URI is used to ensure that the authorization code is sent to the correct client application.
    ///
    /// Example:
    ///     curl -X POST -d "grant_type=authorization_code&code=<authorization_code>&redirect_uri=https://example.com/callback" https://example.com/auth/token
    ///
    /// Note: The redirect URI should be registered with the authorization server and should match the URI used during the authorization request.
    /// It is important to handle redirect URIs with care to prevent unauthorized access to user resources.
    ///
    /// See also:
    /// - [RFC 6749, Section 4.1.3](https://tools.ietf.org/html/rfc6749#section-4.1.3) for more details on the authorization code grant type.
    /// - [OAuth 2.0 Authorization Code Grant](https://oauth.net/2/grant-types/authorization-code/) for a detailed explanation of the authorization code grant type.
    /// - [OAuth 2.0 Security Best Current Practice](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-13#section-2.1) for security considerations when implementing OAuth 2.0.
    @Bind.query("grant_type") String? grantType,

    /// The scope of the access request, which defines the resources and permissions that the client application is requesting.
    ///
    /// This parameter is optional and should be provided as a query parameter in the request.
    /// The scope value is a space-delimited list of scope identifiers, which indicate the specific resources and permissions that the client application needs to access.
    ///
    /// Example:
    ///     curl -X POST -d "grant_type=authorization_code&code=<authorization_code>&redirect_uri=<redirect_uri>&scope=read write" https://example.com/auth/token
    ///
    /// Note: The scope parameter should be used to limit the access granted to the client application to only the necessary resources and permissions.
    /// It is important to handle scope values with care to ensure that the client application does not have unintended access to user resources.
    ///
    /// See also:
    /// - [RFC 6749, Section 3.3](https://tools.ietf.org/html/rfc6749#section-3.3) for more details on the scope parameter.
    /// - [OAuth 2.0 Security Best Current Practice](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-13#section-2.2) for security considerations when implementing OAuth 2.0 scope.
    /// - [OAuth 2.0 Scope](https://oauth.net/2/scope/) for a detailed explanation of the scope parameter and its usage.
    @Bind.query("scope") String? scope,
  }) async {
    AuthBasicCredentials basicRecord;
    try {
      basicRecord = _parser.parse(authHeader);
    } on AuthorizationParserException {
      return _responseForError(AuthRequestError.invalidClient);
    }

    try {
      final scopes = scope?.split(" ").map((s) => AuthScope(s)).toList();

      if (grantType == "password") {
        final token = await authServer.authenticate(
          username,
          password,
          basicRecord.username,
          basicRecord.password,
          requestedScopes: scopes,
        );

        return AuthController.tokenResponse(token);
      } else if (grantType == "refresh_token") {
        final token = await authServer.refresh(
          refreshToken,
          basicRecord.username,
          basicRecord.password,
          requestedScopes: scopes,
        );

        return AuthController.tokenResponse(token);
      } else if (grantType == "authorization_code") {
        if (scope != null) {
          return _responseForError(AuthRequestError.invalidRequest);
        }

        final token = await authServer.exchange(
            authCode, basicRecord.username, basicRecord.password);

        return AuthController.tokenResponse(token);
      } else if (grantType == null) {
        return _responseForError(AuthRequestError.invalidRequest);
      }
    } on FormatException {
      return _responseForError(AuthRequestError.invalidScope);
    } on AuthServerException catch (e) {
      return _responseForError(e.reason);
    }

    return _responseForError(AuthRequestError.unsupportedGrantType);
  }

  /// Transforms a [AuthToken] into a [Response] object with an RFC6749 compliant JSON token
  /// as the HTTP response body.
  ///
  /// This static method takes an [AuthToken] object and converts it into a [Response] object
  /// that adheres to the OAuth 2.0 specification (RFC6749). The response includes:
  /// - A status code of 200 (OK)
  /// - Headers to prevent caching of the token
  /// - A body containing the token information in JSON format
  ///
  /// Parameters:
  ///   - token: An [AuthToken] object containing the authentication token details
  ///
  /// Returns:
  ///   A [Response] object with the token information, ready to be sent to the client
  ///
  /// Example usage:
  ///   ```dart
  ///   AuthToken myToken = // ... obtain token
  ///   Response response = AuthController.tokenResponse(myToken);
  ///   ```
  ///
  /// See also:
  ///   - [RFC6749](https://tools.ietf.org/html/rfc6749) for the OAuth 2.0 specification
  ///   - [AuthToken] for the structure of the token object
  static Response tokenResponse(AuthToken token) {
    return Response(
      HttpStatus.ok,
      {"Cache-Control": "no-store", "Pragma": "no-cache"},
      token.asMap(),
    );
  }

  /// Processes the response before it is sent, specifically handling duplicate parameter errors.
  ///
  /// This method is called just before a response is sent. It checks for responses with a 400 status code
  /// and modifies the error message in case of duplicate parameters in the request, which violates the OAuth 2.0 specification.
  ///
  /// The method performs the following actions:
  /// 1. Checks if the response status code is 400 (Bad Request).
  /// 2. If the response body contains an "error" key with a string value, it examines the error message.
  /// 3. If the error message indicates multiple values (likely due to duplicate parameters), it replaces the error message
  ///    with a standard "invalid_request" error as defined in the OAuth 2.0 specification.
  ///
  /// This post-processing helps to maintain compliance with the OAuth 2.0 specification by providing a standard error
  /// response for invalid requests, even in the case of duplicate parameters which are not explicitly handled elsewhere.
  ///
  /// Parameters:
  ///   response: The Response object that will be sent to the client.
  ///
  /// Note: This method directly modifies the response object if conditions are met.
  @override
  void willSendResponse(Response response) {
    if (response.statusCode == 400) {
      // This post-processes the response in the case that duplicate parameters
      // were in the request, which violates oauth2 spec. It just adjusts the error message.
      // This could be hardened some.
      final body = response.body;
      if (body != null && body["error"] is String) {
        final errorMessage = body["error"] as String;
        if (errorMessage.startsWith("multiple values")) {
          response.body = {
            "error":
                AuthServerException.errorString(AuthRequestError.invalidRequest)
          };
        }
      }
    }
  }

  /// Modifies the list of API parameters documented for this operation.
  ///
  /// This method overrides the default behavior to remove the 'Authorization' header
  /// from the list of documented parameters. This is typically done because the
  /// Authorization header is handled separately in OAuth 2.0 flows and doesn't need
  /// to be explicitly documented as an operation parameter.
  ///
  /// Parameters:
  ///   - context: The current API documentation context.
  ///   - operation: The operation being documented (can be null).
  ///
  /// Returns:
  ///   A list of [APIParameter] objects representing the documented parameters
  ///   for this operation, with the Authorization header removed.
  @override
  List<APIParameter> documentOperationParameters(
    APIDocumentContext context,
    Operation? operation,
  ) {
    final parameters = super.documentOperationParameters(context, operation)!;
    parameters.removeWhere((p) => p.name == HttpHeaders.authorizationHeader);
    return parameters;
  }

  /// Customizes the documentation for the request body of this operation.
  ///
  /// This method overrides the default behavior to add specific requirements
  /// and formatting for the OAuth 2.0 token endpoint:
  ///
  /// 1. It marks the 'grant_type' parameter as required in the request body.
  /// 2. It sets the format of the 'password' field to "password", indicating
  ///    that it should be treated as a sensitive input in API documentation tools.
  ///
  /// Parameters:
  ///   - context: The current API documentation context.
  ///   - operation: The operation being documented (can be null).
  ///
  /// Returns:
  ///   An [APIRequestBody] object with the customized schema for the request body.
  @override
  APIRequestBody documentOperationRequestBody(
    APIDocumentContext context,
    Operation? operation,
  ) {
    final body = super.documentOperationRequestBody(context, operation)!;
    body.content!["application/x-www-form-urlencoded"]!.schema!.isRequired = [
      "grant_type"
    ];
    body.content!["application/x-www-form-urlencoded"]!.schema!
        .properties!["password"]!.format = "password";
    return body;
  }

  /// Customizes the API documentation for the operations handled by this controller.
  ///
  /// This method overrides the default behavior to:
  /// 1. Add OAuth 2.0 client authentication security requirement to all operations.
  /// 2. Set the token and refresh URLs for the documented authorization code flow.
  /// 3. Set the token and refresh URLs for the documented password flow.
  ///
  /// Parameters:
  ///   - context: The current API documentation context.
  ///   - route: The route string for the current operations.
  ///   - path: The APIPath object representing the current path.
  ///
  /// Returns:
  ///   A map of operation names to APIOperation objects with the customized documentation.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    final operations = super.documentOperations(context, route, path);

    operations.forEach((_, op) {
      op.security = [
        APISecurityRequirement({"oauth2-client-authentication": []})
      ];
    });

    final relativeUri = Uri(path: route.substring(1));
    authServer.documentedAuthorizationCodeFlow.tokenURL = relativeUri;
    authServer.documentedAuthorizationCodeFlow.refreshURL = relativeUri;

    authServer.documentedPasswordFlow.tokenURL = relativeUri;
    authServer.documentedPasswordFlow.refreshURL = relativeUri;

    return operations;
  }

  /// Defines the API responses for the token operation in OpenAPI documentation.
  ///
  /// This method overrides the default behavior to provide custom documentation
  /// for the responses of the token endpoint. It describes two possible responses:
  ///
  /// 1. A successful response (200 OK) when credentials are successfully exchanged for a token.
  ///    This response includes details about the issued token such as access_token, token_type,
  ///    expiration time, refresh_token, and scope.
  ///
  /// 2. An error response (400 Bad Request) for cases of invalid credentials or missing parameters.
  ///    This response includes an error message.
  ///
  /// Parameters:
  ///   - context: The current API documentation context.
  ///   - operation: The operation being documented (can be null).
  ///
  /// Returns:
  ///   A map of status codes to APIResponse objects describing the possible
  ///   responses for this operation.
  @override
  Map<String, APIResponse> documentOperationResponses(
    APIDocumentContext context,
    Operation? operation,
  ) {
    return {
      "200": APIResponse.schema(
        "Successfully exchanged credentials for token",
        APISchemaObject.object({
          "access_token": APISchemaObject.string(),
          "token_type": APISchemaObject.string(),
          "expires_in": APISchemaObject.integer(),
          "refresh_token": APISchemaObject.string(),
          "scope": APISchemaObject.string()
        }),
        contentTypes: ["application/json"],
      ),
      "400": APIResponse.schema(
        "Invalid credentials or missing parameters.",
        APISchemaObject.object({"error": APISchemaObject.string()}),
        contentTypes: ["application/json"],
      )
    };
  }

  /// Creates a Response object for an authentication error.
  ///
  /// This method generates a standardized HTTP response for various authentication
  /// errors that may occur during the OAuth 2.0 flow. It uses the [AuthRequestError]
  /// enum to determine the specific error and creates a response with:
  /// - A status code of 400 (Bad Request)
  /// - A JSON body containing an "error" key with a description of the error
  ///
  /// Parameters:
  ///   - error: An [AuthRequestError] enum representing the specific authentication error.
  ///
  /// Returns:
  ///   A [Response] object with status code 400 and a JSON body describing the error.
  ///
  /// Example usage:
  ///   ```dart
  ///   Response errorResponse = _responseForError(AuthRequestError.invalidRequest);
  ///   ```
  ///
  /// The error string in the response body is generated using [AuthServerException.errorString],
  /// ensuring consistency with OAuth 2.0 error reporting standards.
  Response _responseForError(AuthRequestError error) {
    return Response.badRequest(
      body: {"error": AuthServerException.errorString(error)},
    );
  }
}
