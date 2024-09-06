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

/// A [Controller] that validates the Authorization header of a request.
///
/// This class, Authorizer, is responsible for authenticating and authorizing incoming HTTP requests.
/// It validates the Authorization header, processes it according to the specified parser (e.g., Bearer or Basic),
/// and then uses the provided validator to check the credentials.
///
/// For each request, this controller parses the authorization header, validates it with an [AuthValidator] and then create an [Authorization] object
/// if successful. The [Request] keeps a reference to this [Authorization] and is then sent to the next controller in the channel.
///
/// If either parsing or validation fails, a 401 Unauthorized response is sent and the [Request] is removed from the channel.
///
/// Parsing occurs according to [parser]. The resulting value (e.g., username and password) is sent to [validator].
/// [validator] verifies this value (e.g., lookup a user in the database and verify their password matches).
///
/// Usage:
///
///         router
///           .route("/protected-route")
///           .link(() =>new Authorizer.bearer(authServer))
///           .link(() => new ProtectedResourceController());
class Authorizer extends Controller {
  /// Creates an instance of [Authorizer].
  ///
  /// This constructor allows for creating an [Authorizer] with custom configurations.
  ///
  /// By default, this instance will parse bearer tokens from the authorization header, e.g.:
  ///
  ///         Authorization: Bearer ap9ijlarlkz8jIOa9laweo
  ///
  /// If [scopes] is provided, the authorization granted must have access to *all* scopes according to [validator].
  Authorizer(
    this.validator, {
    this.parser = const AuthorizationBearerParser(),
    List<String>? scopes,
  }) : scopes = scopes?.map((s) => AuthScope(s)).toList();

  /// Creates an instance of [Authorizer] with Basic Authentication parsing.
  ///
  /// This constructor initializes an [Authorizer] that uses Basic Authentication.
  /// It sets up the [Authorizer] to parse the Authorization header of incoming requests
  /// using the [AuthorizationBasicParser].
  ///
  /// The Authorization header for Basic Authentication should be in the format:
  ///
  ///         Authorization: Basic base64(username:password)
  Authorizer.basic(AuthValidator? validator)
      : this(validator, parser: const AuthorizationBasicParser());

  /// Creates an instance of [Authorizer] with Bearer token parsing.
  ///
  /// This constructor initializes an [Authorizer] that uses Bearer token authentication.
  /// It sets up the [Authorizer] to parse the Authorization header of incoming requests
  /// using the [AuthorizationBearerParser].
  ///
  ///         Authorization: Bearer ap9ijlarlkz8jIOa9laweo
  ///
  /// If [scopes] is provided, the bearer token must have access to *all* scopes according to [validator].
  Authorizer.bearer(AuthValidator? validator, {List<String>? scopes})
      : this(
          validator,
          parser: const AuthorizationBearerParser(),
          scopes: scopes,
        );

  /// The validating authorization object.
  ///
  /// This property holds an instance of [AuthValidator] responsible for validating
  /// the credentials parsed from the Authorization header. It processes these
  /// credentials and produces an [Authorization] object that represents the
  /// authorization level of the provided credentials.
  ///
  /// The validator can also reject a request if the credentials are invalid or
  /// insufficient. This property is typically set to an instance of [AuthServer].
  ///
  /// The validator is crucial for determining whether a request should be allowed
  /// to proceed based on the provided authorization information.
  final AuthValidator? validator;

  /// The list of required scopes for authorization.
  ///
  /// If [validator] grants scope-limited authorizations (e.g., OAuth2 bearer tokens), the authorization
  /// provided by the request's header must have access to all [scopes] in order to move on to the next controller.
  ///
  /// This property is set with a list of scope strings in a constructor. Each scope string is parsed into
  /// an [AuthScope] and added to this list.
  final List<AuthScope>? scopes;

  /// Parses the Authorization header of incoming requests.
  ///
  /// The parser determines how to interpret the data in the Authorization header. Concrete subclasses
  /// are [AuthorizationBasicParser] and [AuthorizationBearerParser].
  ///
  /// Once parsed, the parsed value is validated by [validator].
  final AuthorizationParser parser;

  /// Handles the incoming request by validating its authorization.
  ///
  /// This method performs the following steps:
  /// 1. Extracts the Authorization header from the request.
  /// 2. If the header is missing, returns an unauthorized response.
  /// 3. Attempts to parse the authorization data using the configured parser.
  /// 4. Validates the parsed data using the configured validator.
  /// 5. If validation succeeds, adds the authorization to the request and proceeds.
  /// 6. If validation fails due to insufficient scope, returns a forbidden response.
  /// 7. For other validation failures, returns an unauthorized response.
  /// 8. Handles parsing exceptions by returning appropriate error responses.
  ///
  /// @param request The incoming HTTP request to be authorized.
  /// @return A [Future] that resolves to either the authorized [Request] or an error [Response].
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    final authData = request.raw.headers.value(HttpHeaders.authorizationHeader);
    if (authData == null) {
      return Response.unauthorized();
    }

    try {
      final value = parser.parse(authData);
      request.authorization =
          await validator!.validate(parser, value, requiredScope: scopes);
      if (request.authorization == null) {
        return Response.unauthorized();
      }

      _addScopeRequirementModifier(request);
    } on AuthorizationParserException catch (e) {
      return _responseFromParseException(e);
    } on AuthServerException catch (e) {
      if (e.reason == AuthRequestError.invalidScope) {
        return Response.forbidden(
          body: {
            "error": "insufficient_scope",
            "scope": scopes!.map((s) => s.toString()).join(" ")
          },
        );
      }

      return Response.unauthorized();
    }

    return request;
  }

  /// Generates an appropriate HTTP response based on the type of AuthorizationParserException.
  ///
  /// This method takes an [AuthorizationParserException] as input and returns
  /// a [Response] object based on the exception's reason:
  ///
  /// - For [AuthorizationParserExceptionReason.malformed], it returns a 400 Bad Request
  ///   response with a body indicating an invalid authorization header.
  /// - For [AuthorizationParserExceptionReason.missing], it returns a 401 Unauthorized
  ///   response.
  /// - For any other reason, it returns a 500 Server Error response.
  ///
  /// @param e The AuthorizationParserException that occurred during parsing.
  /// @return A Response object appropriate to the exception reason.
  Response _responseFromParseException(AuthorizationParserException e) {
    switch (e.reason) {
      case AuthorizationParserExceptionReason.malformed:
        return Response.badRequest(
          body: {"error": "invalid_authorization_header"},
        );
      case AuthorizationParserExceptionReason.missing:
        return Response.unauthorized();
      default:
        return Response.serverError();
    }
  }

  /// Adds a response modifier to the request to handle scope requirements.
  ///
  /// This method is called after successful authorization and adds a response
  /// modifier to the request. The modifier's purpose is to enhance 403 (Forbidden)
  /// responses that are due to insufficient scope.
  ///
  /// If this [Authorizer] has required scopes and the response is a 403 with a body
  /// containing a "scope" key, this modifier will add any of this [Authorizer]'s
  /// required scopes that aren't already present in the response body's scope list.
  ///
  /// This ensures that if a downstream controller returns a 403 due to insufficient
  /// scope, the response includes all the scopes required by both this [Authorizer]
  /// and the downstream controller.
  ///
  /// @param request The [Request] object to which the modifier will be added.
  void _addScopeRequirementModifier(Request request) {
    // If a controller returns a 403 because of invalid scope,
    // this Authorizer adds its required scope as well.
    if (scopes != null) {
      request.addResponseModifier((resp) {
        if (resp.statusCode == 403 && resp.body is Map) {
          final body = resp.body as Map<String, dynamic>;
          if (body.containsKey("scope")) {
            final declaredScopes = (body["scope"] as String).split(" ");
            final scopesToAdd = scopes!
                .map((s) => s.toString())
                .where((s) => !declaredScopes.contains(s));
            body["scope"] =
                [scopesToAdd, declaredScopes].expand((i) => i).join(" ");
          }
        }
      });
    }
  }

  /// Documents the components for the API documentation.
  ///
  /// This method is responsible for registering custom API responses that are specific
  /// to authorization-related errors. It adds three responses to the API documentation:
  ///
  /// 1. "InsufficientScope": Used when the provided credentials or bearer token have
  ///    insufficient permissions to access a route.
  ///
  /// 2. "InsufficientAccess": Used when the provided credentials or bearer token are
  ///    not authorized for a specific request.
  ///
  /// 3. "MalformedAuthorizationHeader": Used when the provided Authorization header
  ///    is malformed.
  ///
  /// Each response is registered with a description and a schema defining the
  /// structure of the JSON response body.
  ///
  /// @param context The APIDocumentContext used to register the responses.
  @override
  void documentComponents(APIDocumentContext context) {
    /// Calls the superclass's documentComponents method.
    ///
    /// This method invokes the documentComponents method of the superclass,
    /// ensuring that any component documentation defined in the parent class
    /// is properly registered in the API documentation context.
    ///
    /// @param context The APIDocumentContext used for registering API components.
    super.documentComponents(context);

    /// Registers an "InsufficientScope" response in the API documentation.
    ///
    /// This response is used when the provided credentials or bearer token
    /// have insufficient permissions to access a specific route. It includes
    /// details about the error and the required scope for the operation.
    ///
    /// The response has the following structure:
    /// - A description explaining the insufficient scope error.
    /// - Content of type "application/json" with a schema containing:
    ///   - An "error" field of type string.
    ///   - A "scope" field of type string, describing the required scope.
    ///
    /// This response can be referenced in API operations to standardize
    /// the documentation of insufficient scope errors.
    context.responses.register(
      "InsufficientScope",
      APIResponse(
        "The provided credentials or bearer token have insufficient permission to access this route.",
        content: {
          "application/json": APIMediaType(
            schema: APISchemaObject.object({
              "error": APISchemaObject.string(),
              "scope": APISchemaObject.string()
                ..description = "The required scope for this operation."
            }),
          )
        },
      ),
    );

    /// Registers an "InsufficientAccess" response in the API documentation.
    ///
    /// This response is used when the provided credentials or bearer token
    /// are not authorized for a specific request. It includes details about
    /// the error in a JSON format.
    ///
    /// The response has the following structure:
    /// - A description explaining the insufficient access error.
    /// - Content of type "application/json" with a schema containing:
    ///   - An "error" field of type string.
    ///
    /// This response can be referenced in API operations to standardize
    /// the documentation of insufficient access errors.
    context.responses.register(
      "InsufficientAccess",
      APIResponse(
        "The provided credentials or bearer token are not authorized for this request.",
        content: {
          "application/json": APIMediaType(
            schema: APISchemaObject.object(
              {"error": APISchemaObject.string()},
            ),
          )
        },
      ),
    );

    /// Registers a "MalformedAuthorizationHeader" response in the API documentation.
    ///
    /// This response is used when the provided Authorization header is malformed.
    /// It includes details about the error in a JSON format.
    ///
    /// The response has the following structure:
    /// - A description explaining the malformed authorization header error.
    /// - Content of type "application/json" with a schema containing:
    ///   - An "error" field of type string.
    ///
    /// This response can be referenced in API operations to standardize
    /// the documentation of malformed authorization header errors.
    context.responses.register(
      "MalformedAuthorizationHeader",
      APIResponse(
        "The provided Authorization header was malformed.",
        content: {
          "application/json": APIMediaType(
            schema: APISchemaObject.object(
              {"error": APISchemaObject.string()},
            ),
          )
        },
      ),
    );
  }

  /// Documents the operations for the API documentation.
  ///
  /// This method is responsible for adding security-related responses and requirements
  /// to each operation in the API documentation. It performs the following tasks:
  ///
  /// 1. Calls the superclass's documentOperations method to get the base operations.
  /// 2. For each operation:
  ///    - Adds a 400 response for malformed authorization headers.
  ///    - Adds a 401 response for insufficient access.
  ///    - Adds a 403 response for insufficient scope.
  ///    - Retrieves security requirements from the validator.
  ///    - Adds these security requirements to the operation.
  ///
  /// @param context The APIDocumentContext used for documenting the API.
  /// @param route The route string for which operations are being documented.
  /// @param path The APIPath object representing the path of the operations.
  /// @return A map of operation names to APIOperation objects with added security documentation.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    final operations = super.documentOperations(context, route, path);

    operations.forEach((_, op) {
      op.addResponse(400, context.responses["MalformedAuthorizationHeader"]);
      op.addResponse(401, context.responses["InsufficientAccess"]);
      op.addResponse(403, context.responses["InsufficientScope"]);

      final requirements = validator!
          .documentRequirementsForAuthorizer(context, this, scopes: scopes);
      for (final req in requirements) {
        op.addSecurityRequirement(req);
      }
    });

    return operations;
  }
}
