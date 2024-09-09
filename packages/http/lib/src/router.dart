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
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';

/// Determines which [Controller] should receive a [Request] based on its path.
///
/// A router is a [Controller] that evaluates the path of a [Request] and determines which controller should be the next to receive it.
/// Valid paths for a [Router] are called *routes* and are added to a [Router] via [route].
///
/// Each [route] creates a new [Controller] that will receive all requests whose path match the route pattern.
/// If a request path does not match one of the registered routes, [Router] responds with 404 Not Found and does not pass
/// the request to another controller.
///
/// Unlike most [Controller]s, a [Router] may have multiple controllers it sends requests to. In most applications,
/// a [Router] is the [ApplicationChannel.entryPoint].
class Router extends Controller {
  /// Creates a new [Router].
  ///
  /// [basePath] is an optional prefix for all routes on this instance.
  /// [notFoundHandler] is an optional function to handle requests that don't match any routes.
  Router({String? basePath, Future Function(Request)? notFoundHandler})
      : _unmatchedController = notFoundHandler,
        _basePathSegments =
            basePath?.split("/").where((str) => str.isNotEmpty).toList() ?? [] {
    policy?.allowCredentials = false;
  }

  /// The root node of the routing tree.
  final _RootNode _root = _RootNode();

  /// List of route controllers.
  final List<_RouteController> _routeControllers = [];

  /// Segments of the base path.
  final List<String> _basePathSegments;

  /// Function to handle unmatched requests.
  final Function(Request)? _unmatchedController;

  /// A prefix for all routes on this instance.
  ///
  /// If this value is non-null, each [route] is prefixed by this value.
  ///
  /// For example, if a route is "/users" and the value of this property is "/api",
  /// a request's path must be "/api/users" to match the route.
  ///
  /// Trailing and leading slashes have no impact on this value.
  String get basePath => "/${_basePathSegments.join("/")}";

  /// Adds a route that [Controller]s can be linked to.
  ///
  /// Routers allow for multiple linked controllers. A request that matches [pattern]
  /// will be sent to the controller linked to this method's return value.
  ///
  /// The [pattern] must follow the rules of route patterns (see also http://conduit.io/docs/http/routing/).
  ///
  /// A pattern consists of one or more path segments, e.g. "/path" or "/path/to".
  ///
  /// A path segment can be:
  ///
  /// - A literal string (e.g. `users`)
  /// - A path variable: a literal string prefixed with `:` (e.g. `:id`)
  /// - A wildcard: the character `*`
  ///
  /// A path variable may contain a regular expression by placing the expression in parentheses immediately after the variable name. (e.g. `:id(/d+)`).
  ///
  /// A path segment is required by default. Path segments may be marked as optional
  /// by wrapping them in square brackets `[]`.
  ///
  /// Here are some example routes:
  ///
  ///         /users
  ///         /users/:id
  ///         /users/[:id]
  ///         /users/:id/friends/[:friendID]
  ///         /locations/:name([^0-9])
  ///         /files/*
  ///
  Linkable route(String pattern) {
    final routeController = _RouteController(
      RouteSpecification.specificationsForRoutePattern(pattern),
    );
    _routeControllers.add(routeController);
    return routeController;
  }

  /// Called when this controller is added to a channel.
  @override
  void didAddToChannel() {
    _root.node =
        RouteNode(_routeControllers.expand((rh) => rh.specifications).toList());

    for (final c in _routeControllers) {
      c.didAddToChannel();
    }
  }

  /// Routers override this method to throw an exception. Use [route] instead.
  @override
  Linkable link(Controller Function() generatorFunction) {
    throw ArgumentError(
      "Invalid link. 'Router' cannot directly link to controllers. Use 'route'.",
    );
  }

  /// Routers override this method to throw an exception. Use [route] instead.
  @override
  Linkable? linkFunction(
    FutureOr<RequestOrResponse?> Function(Request request) handle,
  ) {
    throw ArgumentError(
      "Invalid link. 'Router' cannot directly link to functions. Use 'route'.",
    );
  }

  /// Receives a request and routes it to the appropriate controller.
  @override
  Future receive(Request req) async {
    Controller next;
    try {
      var requestURISegmentIterator = req.raw.uri.pathSegments.iterator;

      if (req.raw.uri.pathSegments.isEmpty) {
        requestURISegmentIterator = [""].iterator;
      }

      for (var i = 0; i < _basePathSegments.length; i++) {
        requestURISegmentIterator.moveNext();
        if (_basePathSegments[i] != requestURISegmentIterator.current) {
          await _handleUnhandledRequest(req);
          return null;
        }
      }

      final node =
          _root.node!.nodeForPathSegments(requestURISegmentIterator, req.path);
      if (node?.specification == null) {
        await _handleUnhandledRequest(req);
        return null;
      }
      req.path.setSpecification(
        node!.specification!,
        segmentOffset: _basePathSegments.length,
      );
      next = node.controller!;
    } catch (any, stack) {
      return handleError(req, any, stack);
    }

    // This line is intentionally outside of the try block
    // so that this object doesn't handle exceptions for 'next'.
    return next.receive(req);
  }

  /// Router should not handle requests directly.
  @override
  FutureOr<RequestOrResponse> handle(Request request) {
    throw StateError("Router invoked handle. This is a bug.");
  }

  /// Documents the paths for this router.
  @override
  Map<String, APIPath> documentPaths(APIDocumentContext context) {
    return _routeControllers.fold(<String, APIPath>{}, (prev, elem) {
      prev.addAll(elem.documentPaths(context));
      return prev;
    });
  }

  /// Documents the components for this router.
  @override
  void documentComponents(APIDocumentContext context) {
    for (final controller in _routeControllers) {
      controller.documentComponents(context);
    }
  }

  /// Returns a string representation of this router.
  @override
  String toString() {
    return _root.node.toString();
  }

  /// Handles unmatched requests.
  Future _handleUnhandledRequest(Request req) async {
    if (_unmatchedController != null) {
      return _unmatchedController(req);
    }
    final response = Response.notFound();
    if (req.acceptsContentType(ContentType.html)) {
      response
        ..body = "<html><h3>404 Not Found</h3></html>"
        ..contentType = ContentType.html;
    }

    applyCORSHeadersIfNecessary(req, response);
    await req.respond(response);
    logger.info(req.toDebugString());
  }
}

/// Represents the root node of the routing tree.
class _RootNode {
  RouteNode? node;
}

/// Represents a route controller.
class _RouteController extends Controller {
  /// Creates a new [_RouteController] with the given specifications.
  _RouteController(this.specifications) {
    for (final p in specifications) {
      p.controller = this;
    }
  }

  /// Route specifications for this controller.
  final List<RouteSpecification> specifications;

  /// Documents the paths for this route controller.
  @override
  Map<String, APIPath> documentPaths(APIDocumentContext components) {
    return specifications.fold(<String, APIPath>{}, (pathMap, spec) {
      final elements = spec.segments.map((rs) {
        if (rs.isLiteralMatcher) {
          return rs.literal;
        } else if (rs.isVariable) {
          return "{${rs.variableName}}";
        } else if (rs.isRemainingMatcher) {
          return "{path}";
        }
        throw StateError("unknown specification");
      }).join("/");
      final pathKey = "/$elements";

      final path = APIPath()
        ..parameters = spec.variableNames
            .map((pathVar) => APIParameter.path(pathVar))
            .toList();

      if (spec.segments.any((seg) => seg.isRemainingMatcher)) {
        path.parameters.add(
          APIParameter.path("path")
            ..description =
                "This path variable may contain slashes '/' and may be empty.",
        );
      }

      path.operations =
          spec.controller!.documentOperations(components, pathKey, path);

      pathMap[pathKey] = path;

      return pathMap;
    });
  }

  /// Handles the request for this route controller.
  @override
  FutureOr<RequestOrResponse> handle(Request request) {
    return request;
  }
}
