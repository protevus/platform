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

/// Abstract class defining the interface for providing application-specific behavior to [AuthRedirectController].
///
/// This delegate is responsible for rendering the HTML login form when [AuthRedirectController.getAuthorizationPage]
/// is called in response to a GET request. Implementations of this class should customize the login form
/// according to the application's needs while ensuring that the form submission adheres to the required format.
///
/// The rendered form should:
/// - Be submitted as a POST request to the [requestUri].
/// - Include all provided parameters (responseType, clientID, state, scope) in the form submission.
/// - Collect and include user-entered username and password.
/// - Use 'application/x-www-form-urlencoded' as the Content-Type for form submission.
///
/// Example of expected form submission:
///
///         POST https://example.com/auth/code
///         Content-Type: application/x-www-form-urlencoded
///
///         response_type=code&client_id=com.conduit.app&state=o9u3jla&username=bob&password=password
///
/// Implementations should take care to handle all provided parameters and ensure secure transmission of credentials.
abstract class AuthRedirectControllerDelegate {
  /// Returns an HTML representation of a login form.
  ///
  /// This method is responsible for generating and returning the HTML content for a login form
  /// when [AuthRedirectController.getAuthorizationPage] is called in response to a GET request.
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
    AuthRedirectController forController,
    Uri requestUri,
    String? responseType,
    String clientID,
    String? state,
    String? scope,
  );
}

/// Controller for issuing OAuth 2.0 authorization codes and tokens.
///
/// This controller provides an endpoint for creating an OAuth 2.0 authorization code or access token. An authorization code
/// can be exchanged for an access token with an [AuthController]. This is known as the OAuth 2.0 'Authorization Code Grant' flow.
/// Returning an access token is known as the OAuth 2.0 'Implicit Grant' flow.
///
/// See operation methods [getAuthorizationPage] and [authorize] for more details.
///
/// Usage:
///
///       router
///         .route("/auth/code")
///         .link(() => new AuthRedirectController(authServer));
///
class AuthRedirectController extends ResourceController {
  /// Creates a new instance of an [AuthRedirectController].
  ///
  /// This constructor initializes an [AuthRedirectController] with the provided [authServer].
  ///
  /// Parameters:
  /// - [authServer]: The required authorization server.
  /// - [delegate]: Optional. If provided, this controller will return a login page for all GET requests.
  /// - [allowsImplicit]: Optional. Defaults to true. Determines if the controller allows the Implicit Grant Flow.
  ///
  /// The constructor also sets the [acceptedContentTypes] to ["application/x-www-form-urlencoded"].
  ///
  /// Usage:
  /// ```dart
  /// final authRedirectController = AuthRedirectController(
  ///   myAuthServer,
  ///   delegate: myDelegate,
  ///   allowsImplicit: false,
  /// );
  /// ```
  AuthRedirectController(
    this.authServer, {
    this.delegate,
    this.allowsImplicit = true,
  }) {
    acceptedContentTypes = [
      ContentType("application", "x-www-form-urlencoded")
    ];
  }

  /// A pre-defined Response object for unsupported response types.
  ///
  /// This static final variable creates a Response object with:
  /// - HTTP status code 400 (Bad Request)
  /// - HTML content indicating an "unsupported_response_type" error
  /// - Content-Type set to text/html
  ///
  /// This response is used when the 'response_type' parameter in the request
  /// is neither 'code' nor 'token', or when 'token' is requested but implicit
  /// grant flow is not allowed.
  static final Response _unsupportedResponseTypeResponse = Response.badRequest(
    body: "<h1>Error</h1><p>unsupported_response_type</p>",
  )..contentType = ContentType.html;

  /// A reference to the [AuthServer] used to grant authorization codes and access tokens.
  ///
  /// This property holds an instance of [AuthServer] which is responsible for
  /// handling the authentication and authorization processes. It is used by
  /// this controller to issue authorization codes and access tokens as part of
  /// the OAuth 2.0 flow.
  ///
  /// The [AuthServer] instance should be properly configured and initialized
  /// before being assigned to this property.
  late final AuthServer authServer;

  /// Determines whether the controller allows the OAuth 2.0 Implicit Grant Flow.
  ///
  /// When set to true, the controller will process requests for access tokens
  /// directly (response_type=token). When false, such requests will be rejected.
  ///
  /// This property is typically set in the constructor and should not be
  /// modified after initialization.
  final bool allowsImplicit;

  /// A randomly generated value the client can use to verify the origin of the redirect.
  ///
  /// This property is bound to the 'state' query parameter of the incoming request.
  /// It serves as a security measure to prevent cross-site request forgery (CSRF) attacks.
  ///
  /// Clients must include this query parameter when initiating an authorization request.
  /// Upon receiving a redirect from this server, clients should verify that the 'state'
  /// value in the redirect matches the one they initially sent. This ensures that the
  /// response is for the request they initiated and not for a malicious request.
  ///
  /// The value of 'state' is typically a randomly generated string or session identifier.
  /// It should be unique for each authorization request to maintain security.
  ///
  /// Example usage:
  /// ```
  /// GET /authorize?response_type=code&client_id=CLIENT_ID&state=RANDOM_STATE
  /// ```
  @Bind.query("state")
  String? state;

  /// The type of response requested from the authorization endpoint.
  ///
  /// This property is bound to the 'response_type' query parameter of the incoming request.
  /// It must be either 'code' or 'token':
  /// - 'code': Indicates that the client is initiating the authorization code flow.
  /// - 'token': Indicates that the client is initiating the implicit flow.
  ///
  /// The value of this property determines the type of credential (authorization code or access token)
  /// that will be issued upon successful authentication.
  ///
  /// Note: The availability of the 'token' response type depends on the [allowsImplicit] setting
  /// of the controller.
  @Bind.query("response_type")
  String? responseType;

  /// The client ID of the authenticating client.
  ///
  /// This property is bound to the 'client_id' query parameter of the incoming request.
  /// It represents the unique identifier of the client application requesting authorization.
  ///
  /// The client ID must be registered and valid according to the [authServer].
  /// It is used to identify the client during the authorization process and to ensure
  /// that only authorized clients can request access tokens or authorization codes.
  ///
  /// This field is nullable, but typically required for most OAuth 2.0 flows.
  /// If not provided in the request, it may lead to authorization failures.
  ///
  /// Example usage in a request URL:
  /// ```
  /// GET /authorize?client_id=my_client_id&...
  /// ```
  @Bind.query("client_id")
  String? clientID;

  /// Delegate responsible for rendering the HTML login form.
  ///
  /// If provided, this delegate will be used to generate a custom login page
  /// when [getAuthorizationPage] is called. The delegate's [render] method
  /// is responsible for creating the HTML content of the login form.
  ///
  /// When this property is null, the controller will not serve a login page
  /// and will respond with a 405 Method Not Allowed status for GET requests.
  ///
  /// This delegate allows for customization of the login experience while
  /// maintaining the required OAuth 2.0 authorization flow.
  final AuthRedirectControllerDelegate? delegate;

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
    if (delegate == null) {
      return Response(405, {}, null);
    }

    if (responseType != "code" && responseType != "token") {
      return _unsupportedResponseTypeResponse;
    }

    if (responseType == "token" && !allowsImplicit) {
      return _unsupportedResponseTypeResponse;
    }

    final renderedPage = await delegate!
        .render(this, request!.raw.uri, responseType, clientID!, state, scope);
    if (renderedPage == null) {
      return Response.notFound();
    }

    return Response.ok(renderedPage)..contentType = ContentType.html;
  }

  /// Creates a one-time use authorization code or an access token.
  ///
  /// This method handles the OAuth 2.0 authorization process, responding with a redirect
  /// that contains either an authorization code ('code') or an access token ('token')
  /// along with the passed in 'state'. If the request fails, the redirect URL will
  /// contain an 'error' instead of the authorization code or access token.
  ///
  /// This method is typically invoked by the login form returned from the GET to this controller.
  @Operation.post()
  Future<Response> authorize({
    /// The username of the authenticating user.
    @Bind.query("username") String? username,

    /// The password of the authenticating user.
    @Bind.query("password") String? password,

    /// A space-delimited list of access scopes being requested.
    @Bind.query("scope") String? scope,
  }) async {
    if (clientID == null) {
      return Response.badRequest();
    }

    final client = await authServer.getClient(clientID!);

    if (client?.redirectURI == null) {
      return Response.badRequest();
    }

    if (responseType == "token" && !allowsImplicit) {
      return _unsupportedResponseTypeResponse;
    }

    if (state == null) {
      return _redirectResponse(
        null,
        null,
        error: AuthServerException(AuthRequestError.invalidRequest, client),
      );
    }

    try {
      final scopes = scope?.split(" ").map((s) => AuthScope(s)).toList();

      if (responseType == "code") {
        if (client!.hashedSecret == null) {
          return _redirectResponse(
            null,
            state,
            error: AuthServerException(
              AuthRequestError.unauthorizedClient,
              client,
            ),
          );
        }

        final authCode = await authServer.authenticateForCode(
          username,
          password,
          clientID!,
          requestedScopes: scopes,
        );
        return _redirectResponse(
          client.redirectURI,
          state,
          code: authCode.code,
        );
      } else if (responseType == "token") {
        final token = await authServer.authenticate(
          username,
          password,
          clientID!,
          null,
          requestedScopes: scopes,
        );
        return _redirectResponse(client!.redirectURI, state, token: token);
      } else {
        return _redirectResponse(
          null,
          state,
          error: AuthServerException(AuthRequestError.invalidRequest, client),
        );
      }
    } on FormatException {
      return _redirectResponse(
        null,
        state,
        error: AuthServerException(AuthRequestError.invalidScope, client),
      );
    } on AuthServerException catch (e) {
      if (responseType == "token" &&
          e.reason == AuthRequestError.invalidGrant) {
        return _redirectResponse(
          null,
          state,
          error: AuthServerException(AuthRequestError.accessDenied, client),
        );
      }

      return _redirectResponse(null, state, error: e);
    }
  }

  /// Customizes the API documentation for the request body of this controller's operations.
  ///
  /// This method overrides the default implementation to add specific details to the
  /// POST operation's request body schema:
  /// - Sets the format of the 'password' field to "password".
  /// - Marks 'client_id', 'state', 'response_type', 'username', and 'password' as required fields.
  ///
  /// Parameters:
  ///   - context: The API documentation context.
  ///   - operation: The operation being documented.
  ///
  /// Returns:
  ///   The modified [APIRequestBody] object, or null if no modifications were made.
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

  /// Customizes the API documentation for the operation parameters of this controller.
  ///
  /// This method overrides the default implementation to mark all parameters
  /// as required, except for the 'scope' parameter. It does this by:
  /// 1. Calling the superclass method to get the initial list of parameters.
  /// 2. Iterating through all parameters except 'scope'.
  /// 3. Setting the 'isRequired' property of each parameter to true.
  ///
  /// Parameters:
  ///   - context: The API documentation context.
  ///   - operation: The operation being documented.
  ///
  /// Returns:
  ///   A list of [APIParameter] objects with updated 'isRequired' properties.
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

  /// Generates API documentation for the responses of this controller's operations.
  ///
  /// This method overrides the default implementation to provide custom documentation
  /// for the GET and POST operations of the AuthRedirectController.
  ///
  /// For GET requests:
  /// - Documents a 200 response that serves a login form in HTML format.
  ///
  /// For POST requests:
  /// - Documents a 302 (Moved Temporarily) response for successful authorizations,
  ///   explaining the structure of the redirect URI for both 'code' and 'token' response types.
  /// - Documents a 400 (Bad Request) response for cases where the client ID is invalid
  ///   and the redirect URI cannot be verified.
  ///
  /// Parameters:
  ///   - context: The API documentation context.
  ///   - operation: The operation being documented.
  ///
  /// Returns:
  ///   A Map of status codes to APIResponse objects describing the possible responses.
  ///
  /// Throws:
  ///   StateError if documentation fails (i.e., for unexpected HTTP methods).
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
          "If successful, in the case of a 'response type' of 'code', the query "
          "parameter of the redirect URI named 'code' contains authorization code. "
          "Otherwise, the query parameter 'error' is present and contains a error string. "
          "In the case of a 'response type' of 'token', the redirect URI's fragment "
          "contains an access token. Otherwise, the fragment contains an error code.",
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

    throw StateError("AuthRedirectController documentation failed.");
  }

  /// Customizes the API documentation for the operations of this controller.
  ///
  /// This method overrides the default implementation to update the authorization URLs
  /// for both the Authorization Code Flow and Implicit Flow in the API documentation.
  ///
  /// It performs the following steps:
  /// 1. Calls the superclass method to get the initial operations documentation.
  /// 2. Constructs a URI from the given route.
  /// 3. Sets this URI as the authorization URL for both the Authorization Code Flow
  ///    and the Implicit Flow in the auth server's documentation.
  ///
  /// Parameters:
  ///   - context: The API documentation context.
  ///   - route: The route string for this controller.
  ///   - path: The APIPath object representing this controller's path.
  ///
  /// Returns:
  ///   A Map of operation IDs to APIOperation objects describing the operations of this controller.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    final ops = super.documentOperations(context, route, path);
    final uri = Uri(path: route.substring(1));
    authServer.documentedAuthorizationCodeFlow.authorizationURL = uri;
    authServer.documentedImplicitFlow.authorizationURL = uri;
    return ops;
  }

  /// Generates a redirect response for OAuth 2.0 authorization flow.
  ///
  /// This method constructs a redirect URI based on the given parameters and the type of response
  /// (code or token) requested. It handles both successful authorizations and error cases.
  ///
  /// Parameters:
  /// - [inputUri]: The base URI to redirect to. If null, falls back to the client's registered redirect URI.
  /// - [clientStateOrNull]: The state parameter provided by the client for CSRF protection.
  /// - [code]: The authorization code (for code flow).
  /// - [token]: The access token (for token/implicit flow).
  /// - [error]: Any error that occurred during the authorization process.
  ///
  /// Returns:
  /// - A [Response] object with a 302 status code and appropriate headers for redirection.
  /// - If the redirect URI is invalid or cannot be constructed, returns a 400 Bad Request response.
  ///
  /// The method constructs the redirect URI as follows:
  /// - For 'code' response type: Adds code, state, and error (if any) as query parameters.
  /// - For 'token' response type: Adds token details, state, and error (if any) as URI fragment.
  ///
  /// The response includes headers to prevent caching of the redirect.
  Response _redirectResponse(
    String? inputUri,
    String? clientStateOrNull, {
    String? code,
    AuthToken? token,
    AuthServerException? error,
  }) {
    final uriString = inputUri ?? error!.client?.redirectURI;
    if (uriString == null) {
      return Response.badRequest(body: {"error": error!.reasonString});
    }

    Uri redirectURI;

    try {
      redirectURI = Uri.parse(uriString);
    } catch (error) {
      return Response.badRequest();
    }

    final queryParameters =
        Map<String, String>.from(redirectURI.queryParameters);
    String? fragment;

    if (responseType == "code") {
      if (code != null) {
        queryParameters["code"] = code;
      }
      if (clientStateOrNull != null) {
        queryParameters["state"] = clientStateOrNull;
      }
      if (error != null) {
        queryParameters["error"] = error.reasonString;
      }
    } else if (responseType == "token") {
      final params = token?.asMap() ?? {};

      if (clientStateOrNull != null) {
        params["state"] = clientStateOrNull;
      }
      if (error != null) {
        params["error"] = error.reasonString;
      }

      fragment = params.keys
          .map((key) => "$key=${Uri.encodeComponent(params[key].toString())}")
          .join("&");
    } else {
      return _unsupportedResponseTypeResponse;
    }

    final responseURI = Uri(
      scheme: redirectURI.scheme,
      userInfo: redirectURI.userInfo,
      host: redirectURI.host,
      port: redirectURI.port,
      path: redirectURI.path,
      queryParameters: queryParameters,
      fragment: fragment,
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
