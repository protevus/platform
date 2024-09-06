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

/// Provides [AuthCodeController] with application-specific behavior.
///
/// This abstract class defines the interface for a delegate that can be used
/// with [AuthCodeController] to customize the rendering of the login form.
/// It is deprecated along with [AuthCodeController], and developers are
/// advised to see the documentation for alternative approaches.
///
/// The main responsibility of this delegate is to generate an HTML
/// representation of a login form when requested by the [AuthCodeController].
@Deprecated('AuthCodeController is deprecated. See docs.')
abstract class AuthCodeControllerDelegate {
  /// Returns an HTML representation of a login form.
  ///
  /// This method is responsible for generating the HTML content of a login form
  /// that will be displayed to the user when they attempt to authenticate.
  ///
  /// The form submission should include the values of [responseType], [clientID], [state], [scope]
  /// as well as user-entered username and password in `x-www-form-urlencoded` data, e.g.
  ///
  ///         POST https://example.com/auth/code
  ///         Content-Type: application/x-www-form-urlencoded
  ///
  ///         response_type=code&client_id=com.conduit.app&state=o9u3jla&username=bob&password=password
  ///
  ///
  /// If not null, [scope] should also be included as an additional form parameter.
  Future<String?> render(
    AuthCodeController forController,
    Uri requestUri,
    String? responseType,
    String clientID,
    String? state,
    String? scope,
  );
}

/// Controller for issuing OAuth 2.0 authorization codes.
///
/// This controller handles the authorization code grant flow of OAuth 2.0. It provides
/// endpoints for both initiating the flow (GET request) and completing it (POST request).
///
///         .route("/auth/code")
///         .link(() => new AuthCodeController(authServer));
@Deprecated('Use AuthRedirectController instead.')
class AuthCodeController extends ResourceController {
  /// Creates a new instance of an [AuthCodeController].
  ///
  /// This constructor initializes an [AuthCodeController] with the provided [authServer].
  /// It is marked as deprecated, and users are advised to use [AuthRedirectController] instead.
  ///
  /// Parameters:
  /// - [authServer]: The required authorization server used for handling authentication.
  /// - [delegate]: An optional [AuthCodeControllerDelegate] that, if provided, allows this controller
  ///   to return a login page for all GET requests.
  ///
  /// The constructor also sets the [acceptedContentTypes] to only accept
  /// "application/x-www-form-urlencoded" content type.
  ///
  /// This controller is part of the OAuth 2.0 authorization code flow and is used
  /// for issuing authorization codes. However, due to its deprecated status,
  /// it's recommended to transition to newer alternatives as specified in the documentation.
  @Deprecated('Use AuthRedirectController instead.')
  AuthCodeController(this.authServer, {this.delegate}) {
    acceptedContentTypes = [
      ContentType("application", "x-www-form-urlencoded")
    ];
  }

  /// A reference to the [AuthServer] used to grant authorization codes.
  ///
  /// This [AuthServer] instance is responsible for handling the authentication
  /// and authorization processes, including the generation and validation of
  /// authorization codes. It is a crucial component of the OAuth 2.0 flow
  /// implemented by this controller.
  final AuthServer authServer;

  /// A randomly generated value the client can use to verify the origin of the redirect.
  ///
  /// Clients must include this query parameter and verify that any redirects from this
  /// server have the same value for 'state' as passed in. This value is usually a randomly generated
  /// session identifier.
  ///
  /// This property is bound to the 'state' query parameter in the request URL.
  /// It plays a crucial role in preventing cross-site request forgery (CSRF) attacks
  /// by ensuring that the authorization request and response originate from the same client session.
  ///
  /// The 'state' parameter should be:
  /// - Unique for each authorization request
  /// - Securely generated to be unguessable
  /// - Stored by the client for later comparison
  ///
  /// When the authorization server redirects the user back to the client,
  /// it includes this state value, allowing the client to verify that the redirect
  /// is in response to its own authorization request.
  @Bind.query("state")
  String? state;

  /// The type of response expected from the authorization server.
  ///
  /// This parameter is bound to the 'response_type' query parameter in the request URL.
  /// For the authorization code flow, this value must be 'code'.
  ///
  /// The response type indicates to the authorization server which grant type
  /// is being utilized. In this case, 'code' signifies that the client expects
  /// to receive an authorization code that can be exchanged for an access token
  /// in a subsequent request.
  ///
  /// Must be 'code'.
  @Bind.query("response_type")
  String? responseType;

  /// The client ID of the authenticating client.
  ///
  /// This property is bound to the 'client_id' query parameter in the request URL.
  /// It represents the unique identifier of the client application requesting authorization.
  ///
  /// The client ID must be registered and valid according to the [authServer].
  /// It is used to identify the client during the OAuth 2.0 authorization process.
  ///
  /// This field is nullable, but typically required for most OAuth 2.0 flows.
  /// If not provided or invalid, the authorization request may be rejected.
  @Bind.query("client_id")
  String? clientID;

  /// Renders an HTML login form.
  final AuthCodeControllerDelegate? delegate;

  /// Returns an HTML login form for OAuth 2.0 authorization.
  ///
  /// A client that wishes to authenticate with this server should direct the user
  /// to this page. The user will enter their username and password that is sent as a POST
  /// request to this same controller.
  ///
  /// The 'client_id' must be a registered, valid client of this server. The client must also provide
  /// a [state] to this request and verify that the redirect contains the same value in its query string.
  @Operation.get()
  Future<Response> getAuthorizationPage({
    /// A space-delimited list of access scopes to be requested by the form submission on the returned page.
    @Bind.query("scope") String? scope,
  }) async {
    if (clientID == null) {
      return Response.badRequest();
    }

    if (delegate == null) {
      return Response(405, {}, null);
    }

    final renderedPage = await delegate!
        .render(this, request!.raw.uri, responseType, clientID!, state, scope);

    return Response.ok(renderedPage)..contentType = ContentType.html;
  }

  /// Creates a one-time use authorization code.
  ///
  /// This method handles the POST request for the OAuth 2.0 authorization code grant flow.
  /// It authenticates the user with the provided credentials and, if successful, generates
  /// a one-time use authorization code.
  ///
  /// This method is typically invoked by the login form returned from the GET to this controller.
  @Operation.post()
  Future<Response> authorize({
    /// The username of the authenticating user.
    ///
    /// This parameter is bound to the 'username' query parameter in the request URL.
    /// It represents the username of the user attempting to authenticate.
    ///
    /// The username is used in conjunction with the password to verify the user's identity
    /// during the OAuth 2.0 authorization code grant flow. It is a crucial part of the
    /// user authentication process.
    ///
    /// This field is nullable, but typically required for successful authentication.
    /// If not provided or invalid, the authorization request may be rejected.
    @Bind.query("username") String? username,

    /// The password of the authenticating user.
    ///
    /// This parameter is bound to the 'password' query parameter in the request URL.
    /// It represents the password of the user attempting to authenticate.
    ///
    /// The password is used in conjunction with the username to verify the user's identity
    /// during the OAuth 2.0 authorization code grant flow. It is a crucial part of the
    /// user authentication process.
    ///
    /// This field is nullable, but typically required for successful authentication.
    /// If not provided or invalid, the authorization request may be rejected.
    ///
    /// Note: Transmitting passwords as query parameters is not recommended for production
    /// environments due to security concerns. This approach should only be used in
    /// controlled, secure environments or for testing purposes.
    @Bind.query("password") String? password,

    /// A space-delimited list of access scopes being requested.
    ///
    /// This parameter is bound to the 'scope' query parameter in the request URL.
    /// It represents the permissions that the client is requesting access to.
    ///
    /// The scope is typically a string containing one or more space-separated
    /// scope values. Each scope value represents a specific permission or
    /// set of permissions that the client is requesting.
    ///
    /// For example, a scope might look like: "read_profile edit_profile"
    ///
    /// The authorization server can use this information to present
    /// the user with a consent screen, allowing them to approve or deny
    /// specific permissions requested by the client.
    ///
    /// This field is optional. If not provided, the authorization server
    /// may assign a default set of scopes or handle the request according
    /// to its own policies.
    @Bind.query("scope") String? scope,
  }) async {
    final client = await authServer.getClient(clientID!);

    if (state == null) {
      return _redirectResponse(
        null,
        null,
        error: AuthServerException(AuthRequestError.invalidRequest, client),
      );
    }

    if (responseType != "code") {
      if (client?.redirectURI == null) {
        return Response.badRequest();
      }

      return _redirectResponse(
        null,
        state,
        error: AuthServerException(AuthRequestError.invalidRequest, client),
      );
    }

    try {
      final scopes = scope?.split(" ").map((s) => AuthScope(s)).toList();

      final authCode = await authServer.authenticateForCode(
        username,
        password,
        clientID!,
        requestedScopes: scopes,
      );
      return _redirectResponse(client!.redirectURI, state, code: authCode.code);
    } on FormatException {
      return _redirectResponse(
        null,
        state,
        error: AuthServerException(AuthRequestError.invalidScope, client),
      );
    } on AuthServerException catch (e) {
      return _redirectResponse(null, state, error: e);
    }
  }

  /// Overrides the default documentation for the request body of this controller's operations.
  ///
  /// This method is called during the OpenAPI documentation generation process.
  /// It modifies the request body schema for POST operations to:
  /// 1. Set the format of the 'password' field to "password".
  /// 2. Mark certain fields as required in the request body.
  ///
  /// The method specifically targets the "application/x-www-form-urlencoded" content type
  /// in POST requests. It updates the schema to indicate that the 'password' field should
  /// be treated as a password input, and sets the following fields as required:
  /// - client_id
  /// - state
  /// - response_type
  /// - username
  /// - password
  ///
  /// Returns:
  ///   An [APIRequestBody] object representing the documented request body,
  ///   or null if there is no request body for the operation.
  @override
  APIRequestBody? documentOperationRequestBody(
    APIDocumentContext context,
    Operation? operation,
  ) {
    final body = super.documentOperationRequestBody(context, operation);
    if (operation!.method == "POST") {
      body!.content!["application/x-www-form-urlencoded"]!.schema!
          .properties!["password"]!.format = "password";
      body.content!["application/x-www-form-urlencoded"]!.schema!.isRequired = [
        "client_id",
        "state",
        "response_type",
        "username",
        "password"
      ];
    }
    return body;
  }

  /// Overrides the default documentation for operation parameters.
  ///
  /// This method is called during the OpenAPI documentation generation process.
  /// It modifies the parameter documentation for the controller's operations by:
  /// 1. Retrieving the default parameters using the superclass method.
  /// 2. Setting all parameters except 'scope' as required.
  ///
  /// Parameters:
  ///   context: The [APIDocumentContext] for the current documentation generation.
  ///   operation: The [Operation] being documented.
  ///
  /// Returns:
  ///   A List of [APIParameter] objects representing the documented parameters,
  ///   with updated 'isRequired' properties.
  @override
  List<APIParameter> documentOperationParameters(
    APIDocumentContext context,
    Operation? operation,
  ) {
    final params = super.documentOperationParameters(context, operation)!;
    params.where((p) => p.name != "scope").forEach((p) {
      p.isRequired = true;
    });
    return params;
  }

  /// Generates documentation for the operation responses of this controller.
  ///
  /// This method overrides the default behavior to provide custom documentation
  /// for the GET and POST operations of the AuthCodeController.
  ///
  /// For GET requests:
  /// - Defines a 200 OK response that serves a login form in HTML format.
  ///
  /// For POST requests:
  /// - Defines a 302 Found (Moved Temporarily) response for successful requests,
  ///   indicating that the 'code' query parameter in the redirect URI contains
  ///   the authorization code, or an 'error' parameter is present for errors.
  /// - Defines a 400 Bad Request response for cases where the 'client_id' is
  ///   invalid and the redirect URI cannot be verified.
  ///
  /// Parameters:
  ///   context: The API documentation context.
  ///   operation: The operation being documented.
  ///
  /// Returns:
  ///   A Map of status codes to APIResponse objects describing the possible
  ///   responses for the operation.
  @override
  Map<String, APIResponse> documentOperationResponses(
    APIDocumentContext context,
    Operation? operation,
  ) {
    if (operation!.method == "GET") {
      return {
        "200": APIResponse.schema(
          "Serves a login form.",
          APISchemaObject.string(),
          contentTypes: ["text/html"],
        )
      };
    } else if (operation.method == "POST") {
      return {
        "${HttpStatus.movedTemporarily}": APIResponse(
          "If successful, the query parameter of the redirect URI named 'code' contains authorization code. "
          "Otherwise, the query parameter 'error' is present and contains a error string.",
          headers: {
            "Location": APIHeader()
              ..schema = APISchemaObject.string(format: "uri")
          },
        ),
        "${HttpStatus.badRequest}": APIResponse.schema(
          "If 'client_id' is invalid, the redirect URI cannot be verified and this response is sent.",
          APISchemaObject.object({"error": APISchemaObject.string()}),
          contentTypes: ["application/json"],
        )
      };
    }

    throw StateError("AuthCodeController documentation failed.");
  }

  /// Customizes the documentation for the operations of this controller.
  ///
  /// This method overrides the default implementation to add additional
  /// information specific to the OAuth 2.0 authorization code flow.
  ///
  /// It performs the following tasks:
  /// 1. Calls the superclass method to get the default operation documentation.
  /// 2. Updates the authorization URL in the documented authorization code flow
  ///    of the auth server to match the current route.
  ///
  /// Parameters:
  ///   context: The [APIDocumentContext] for the current documentation generation.
  ///   route: The route string for this controller.
  ///   path: The [APIPath] object representing the path in the API documentation.
  ///
  /// Returns:
  ///   A Map of operation names to [APIOperation] objects representing the
  ///   documented operations for this controller.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    final ops = super.documentOperations(context, route, path);
    authServer.documentedAuthorizationCodeFlow.authorizationURL =
        Uri(path: route.substring(1));
    return ops;
  }

  /// Generates a redirect response for the OAuth 2.0 authorization code flow.
  ///
  /// This method constructs a redirect URI based on the provided parameters and
  /// returns a Response object with appropriate headers for redirection.
  ///
  /// Parameters:
  /// - [inputUri]: The base URI to redirect to. If null, falls back to the client's redirectURI.
  /// - [clientStateOrNull]: The state parameter provided by the client. If not null, it's included in the redirect URI.
  /// - [code]: The authorization code to be included in the redirect URI. Optional.
  /// - [error]: An AuthServerException containing error details. Optional.
  ///
  /// Returns:
  /// - A Response object with status 302 (Found) and appropriate headers for redirection.
  /// - If no valid redirect URI can be constructed, returns a 400 (Bad Request) response.
  ///
  /// The method constructs the redirect URI by:
  /// 1. Determining the base URI (from input or client's redirect URI)
  /// 2. Adding query parameters for code, state, and error as applicable
  /// 3. Constructing a new URI with these parameters
  ///
  /// The response includes headers for location, cache control, and pragma.
  static Response _redirectResponse(
    String? inputUri,
    String? clientStateOrNull, {
    String? code,
    AuthServerException? error,
  }) {
    final uriString = inputUri ?? error!.client?.redirectURI;
    if (uriString == null) {
      return Response.badRequest(body: {"error": error!.reasonString});
    }

    final redirectURI = Uri.parse(uriString);
    final queryParameters =
        Map<String, String?>.from(redirectURI.queryParameters);

    if (code != null) {
      queryParameters["code"] = code;
    }
    if (clientStateOrNull != null) {
      queryParameters["state"] = clientStateOrNull;
    }
    if (error != null) {
      queryParameters["error"] = error.reasonString;
    }

    final responseURI = Uri(
      scheme: redirectURI.scheme,
      userInfo: redirectURI.userInfo,
      host: redirectURI.host,
      port: redirectURI.port,
      path: redirectURI.path,
      queryParameters: queryParameters,
    );
    return Response(
      HttpStatus.movedTemporarily,
      {
        HttpHeaders.locationHeader: responseURI.toString(),
        HttpHeaders.cacheControlHeader: "no-store",
        HttpHeaders.pragmaHeader: "no-cache"
      },
      null,
    );
  }
}
