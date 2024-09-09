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
import 'package:protevus_runtime/runtime.dart';
import 'package:logging/logging.dart';

/// The unifying protocol for [Request] and [Response] classes.
///
/// A [Controller] must return an instance of this type from its [Controller.handle] method.
abstract class RequestOrResponse {}

/// An interface that [Controller] subclasses implement to generate a controller for each request.
///
/// If a [Controller] implements this interface, a [Controller] is created for each request. Controllers
/// must implement this interface if they declare setters or non-final properties, as those properties could
/// change during request handling.
///
/// A controller that implements this interface can store information that is not tied to the request
/// to be reused across each instance of the controller type by implementing [recycledState] and [restore].
/// Use these methods when a controller needs to construct runtime information that only needs to occur once
/// per controller type.
abstract class Recyclable<T> implements Controller {
  /// Returns state information that is reused across instances of this type.
  ///
  /// This method is called once when this instance is first created. It is passed
  /// to each instance of this type via [restore].
  T? get recycledState;

  /// Provides a instance of this type with the [recycledState] of this type.
  ///
  /// Use this method it provide compiled runtime information to a instance.
  void restore(T? state);
}

/// An interface for linking controllers.
///
/// All [Controller]s implement this interface.
abstract class Linkable {
  /// See [Controller.link].
  Linkable? link(Controller Function() instantiator);

  /// See [Controller.linkFunction].
  Linkable? linkFunction(
    FutureOr<RequestOrResponse?> Function(Request request) handle,
  );
}

/// Base class for request handling objects.
///
/// A controller is a discrete processing unit for requests. These units are linked
/// together to form a series of steps that fully handle a request.
///
/// Subclasses must implement [handle] to respond to, modify or forward requests.
/// This class must be subclassed. [Router] and [ResourceController] are common subclasses.
abstract class Controller
    implements APIComponentDocumenter, APIOperationDocumenter, Linkable {
  /// Returns a stacktrace and additional details about how the request's processing in the HTTP response.
  ///
  /// By default, this is false. During debugging, setting this to true can help debug Conduit applications
  /// from the HTTP client.
  static bool includeErrorDetailsInServerErrorResponses = false;

  /// Whether or not to allow uncaught exceptions escape request controllers.
  ///
  /// When this value is false - the default - all [Controller] instances handle
  /// unexpected exceptions by catching and logging them, and then returning a 500 error.
  ///
  /// While running tests, it is useful to know where unexpected exceptions come from because
  /// they are an error in your code. By setting this value to true, all [Controller]s
  /// will rethrow unexpected exceptions in addition to the base behavior. This allows the stack
  /// trace of the unexpected exception to appear in test results and halt the tests with failure.
  ///
  /// By default, this value is false. Do not set this value to true outside of tests.
  static bool letUncaughtExceptionsEscape = false;

  /// Receives requests that this controller does not respond to.
  ///
  /// This value is set by [link] or [linkFunction].
  Controller? get nextController => _nextController;

  /// An instance of the 'conduit' logger.
  Logger get logger => Logger("conduit");

  /// The CORS policy of this controller.
  CORSPolicy? policy = CORSPolicy();

  Controller? _nextController;

  /// Links a controller to the receiver to form a request channel.
  ///
  /// Establishes a channel containing the receiver and the controller returned by [instantiator]. If
  /// the receiver does not handle a request, the controller created by [instantiator] will get an opportunity to do so.
  ///
  /// [instantiator] is called immediately when invoking this function. If the returned [Controller] does not implement
  /// [Recyclable], this is the only time [instantiator] is called. The returned controller must only have properties that
  /// are marked as final.
  ///
  /// If the returned controller has properties that are not marked as final, it must implement [Recyclable].
  /// When a controller implements [Recyclable], [instantiator] is called for each request that
  /// reaches this point of the channel. See [Recyclable] for more details.
  ///
  /// See [linkFunction] for a variant of this method that takes a closure instead of an object.
  @override
  Linkable link(Controller Function() instantiator) {
    final instance = instantiator();
    if (instance is Recyclable) {
      _nextController = _ControllerRecycler(instantiator, instance);
    } else {
      _nextController = instantiator();
    }

    return _nextController!;
  }

  /// Links a function controller to the receiver to form a request channel.
  ///
  /// If the receiver does not respond to a request, [handle] receives the request next.
  ///
  /// See [link] for a variant of this method that takes an object instead of a closure.
  @override
  Linkable? linkFunction(
    FutureOr<RequestOrResponse?> Function(Request request) handle,
  ) {
    return _nextController = _FunctionController(handle);
  }

  /// Lifecycle callback, invoked after added to channel, but before any requests are served.
  ///
  /// Subclasses override this method to provide final, one-time initialization after it has been added to a channel,
  /// but before any requests are served. This is useful for performing any caching or optimizations for this instance.
  /// For example, [Router] overrides this method to optimize its list of routes into a more efficient data structure.
  ///
  /// This method is invoked immediately after [ApplicationChannel.entryPoint] completes, for each
  /// instance in the channel created by [ApplicationChannel.entryPoint]. This method will only be called once per instance.
  ///
  /// Controllers added to the channel via [link] may use this method, but any values this method stores
  /// must be stored in a static structure, not the instance itself, since that instance will only be used to handle one request
  /// before it is garbage collected.
  ///
  /// If you override this method you should call the superclass' implementation so that linked controllers invoke this same method.
  /// If you do not invoke the superclass' implementation, you must ensure that any linked controllers invoked this method through other means.
  void didAddToChannel() {
    _nextController?.didAddToChannel();
  }

  /// Delivers [req] to this instance to be processed.
  ///
  /// This method is the entry point of a [Request] into this [Controller].
  /// By default, it invokes this controller's [handle] method within a try-catch block
  /// that guarantees an HTTP response will be sent for [Request].
  Future? receive(Request req) async {
    if (req.isPreflightRequest) {
      return _handlePreflightRequest(req);
    }

    Request? next;
    try {
      try {
        final result = await handle(req);
        if (result is Response) {
          await _sendResponse(req, result, includeCORSHeaders: true);
          logger.info(req.toDebugString());
          return null;
        } else if (result is Request) {
          next = result;
        }
      } on Response catch (response) {
        await _sendResponse(req, response, includeCORSHeaders: true);
        logger.info(req.toDebugString());
        return null;
      } on HandlerException catch (e) {
        await _sendResponse(req, e.response, includeCORSHeaders: true);
        logger.info(req.toDebugString());
        return null;
      }
    } catch (any, stacktrace) {
      handleError(req, any, stacktrace);

      if (letUncaughtExceptionsEscape) {
        rethrow;
      }

      return null;
    }

    if (next == null) {
      return null;
    }

    return nextController?.receive(next);
  }

  /// The primary request handling method of this object.
  ///
  /// Subclasses implement this method to provide their request handling logic.
  ///
  /// If this method returns a [Response], it will be sent as the response for [request] linked controllers will not handle it.
  ///
  /// If this method returns [request], the linked controller handles the request.
  ///
  /// If this method returns null, [request] is not passed to any other controller and is not responded to. You must respond to [request]
  /// through [Request.raw].
  FutureOr<RequestOrResponse?> handle(Request request);

  /// Executed prior to [Response] being sent.
  ///
  /// This method is used to post-process [response] just before it is sent. By default, does nothing.
  /// The [response] may be altered prior to being sent. This method will be executed for all requests,
  /// including server errors.
  void willSendResponse(Response response) {}

  /// Sends an HTTP response for a request that yields an exception or error.
  ///
  /// When this controller encounters an exception or error while handling [request], this method is called to send the response.
  /// By default, it attempts to send a 500 Server Error response and logs the error and stack trace to [logger].
  ///
  /// Note: If [caughtValue]'s implements [HandlerException], this method is not called.
  ///
  /// If you override this method, it must not throw.
  Future handleError(
    Request request,
    dynamic caughtValue,
    StackTrace trace,
  ) async {
    if (caughtValue is HTTPStreamingException) {
      logger.severe(
        request.toDebugString(includeHeaders: true),
        caughtValue.underlyingException,
        caughtValue.trace,
      );

      request.response.close().catchError((_) => null);

      return;
    }

    try {
      final body = includeErrorDetailsInServerErrorResponses
          ? {
              "controller": "$runtimeType",
              "error": "$caughtValue.",
              "stacktrace": trace.toString()
            }
          : null;

      final response = Response.serverError(body: body)
        ..contentType = ContentType.json;

      await _sendResponse(request, response, includeCORSHeaders: true);

      logger.severe(
        request.toDebugString(includeHeaders: true),
        caughtValue,
        trace,
      );
    } catch (e) {
      logger.severe("Failed to send response, draining request. Reason: $e");

      request.raw.drain().catchError((_) => null);
    }
  }

  /// Applies CORS headers to the response if necessary.
  ///
  /// This method checks if the request is a CORS request and not a preflight request.
  /// If so, it applies the appropriate CORS headers to the response based on the policy
  /// of the last controller in the chain.
  void applyCORSHeadersIfNecessary(Request req, Response resp) {
    if (req.isCORSRequest && !req.isPreflightRequest) {
      final lastPolicyController = _lastController;
      final p = lastPolicyController.policy;
      if (p != null) {
        if (p.isRequestOriginAllowed(req.raw)) {
          resp.headers.addAll(p.headersForRequest(req));
        }
      }
    }
  }

  /// Documents the API paths for this controller.
  ///
  /// This method delegates the documentation of API paths to the next controller
  /// in the chain, if one exists. If there is no next controller, it returns an
  /// empty map.
  ///
  /// [context] is the API documentation context.
  ///
  /// Returns a map where the keys are path strings and the values are [APIPath]
  /// objects describing the paths.
  @override
  Map<String, APIPath> documentPaths(APIDocumentContext context) =>
      nextController?.documentPaths(context) ?? {};

  /// Documents the API operations for this controller.
  ///
  /// This method is responsible for generating documentation for the API operations
  /// associated with this controller. It delegates the documentation process to
  /// the next controller in the chain, if one exists.
  ///
  /// Parameters:
  /// - [context]: The API documentation context.
  /// - [route]: The route string for the current path.
  /// - [path]: The APIPath object representing the current path.
  ///
  /// Returns:
  /// A map where the keys are operation identifiers (typically HTTP methods)
  /// and the values are [APIOperation] objects describing the operations.
  /// If there is no next controller, it returns an empty map.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    if (nextController == null) {
      return {};
    }

    return nextController!.documentOperations(context, route, path);
  }

  /// Documents the API components for this controller.
  ///
  /// This method delegates the documentation of API components to the next controller
  /// in the chain, if one exists. If there is no next controller, this method does nothing.
  ///
  /// [context] is the API documentation context.
  @override
  void documentComponents(APIDocumentContext context) =>
      nextController?.documentComponents(context);

  /// Handles preflight requests for CORS.
  ///
  /// This method is called when a preflight request is received. It determines
  /// which controller should handle the preflight request and delegates the
  /// handling to that controller.
  Future? _handlePreflightRequest(Request req) async {
    Controller controllerToDictatePolicy;
    try {
      final lastControllerInChain = _lastController;
      if (lastControllerInChain != this) {
        controllerToDictatePolicy = lastControllerInChain;
      } else {
        if (policy != null) {
          if (!policy!.validatePreflightRequest(req.raw)) {
            await _sendResponse(req, Response.forbidden());
            logger.info(req.toDebugString(includeHeaders: true));
          } else {
            await _sendResponse(req, policy!.preflightResponse(req));
            logger.info(req.toDebugString());
          }

          return null;
        } else {
          // If we don't have a policy, then a preflight request makes no sense.
          await _sendResponse(req, Response.forbidden());
          logger.info(req.toDebugString(includeHeaders: true));
          return null;
        }
      }
    } catch (any, stacktrace) {
      return handleError(req, any, stacktrace);
    }

    return controllerToDictatePolicy.receive(req);
  }

  /// Sends the response for a request.
  ///
  /// This method applies CORS headers if necessary, calls [willSendResponse],
  /// and then sends the response.
  Future _sendResponse(
    Request request,
    Response response, {
    bool includeCORSHeaders = false,
  }) {
    if (includeCORSHeaders) {
      applyCORSHeadersIfNecessary(request, response);
    }
    willSendResponse(response);

    return request.respond(response);
  }

  /// Returns the last controller in the chain.
  ///
  /// This method traverses the linked controllers to find the last one in the chain.
  Controller get _lastController {
    Controller controller = this;
    while (controller.nextController != null) {
      controller = controller.nextController!;
    }
    return controller;
  }
}

/// A controller that recycles instances of another controller.
///
/// This controller is used internally to handle controllers that implement [Recyclable].
@PreventCompilation()
class _ControllerRecycler<T> extends Controller {
  _ControllerRecycler(this.generator, Recyclable<T> instance) {
    recycleState = instance.recycledState;
    nextInstanceToReceive = instance;
  }

  /// Function to generate new instances of the recyclable controller.
  Controller Function() generator;

  /// Override for the CORS policy.
  CORSPolicy? policyOverride;

  /// State to be recycled between instances.
  T? recycleState;

  Recyclable<T>? _nextInstanceToReceive;

  /// The next instance to receive requests.
  Recyclable<T>? get nextInstanceToReceive => _nextInstanceToReceive;

  /// Sets the next instance to receive requests and initializes it.
  set nextInstanceToReceive(Recyclable<T>? instance) {
    _nextInstanceToReceive = instance;
    instance?.restore(recycleState);
    instance?._nextController = nextController;
    if (policyOverride != null) {
      instance?.policy = policyOverride;
    }
  }

  /// Returns the CORS policy of the next instance to receive requests.
  ///
  /// This getter delegates to the [policy] of the [nextInstanceToReceive].
  /// If [nextInstanceToReceive] is null, this will return null.
  ///
  /// Returns:
  ///   The [CORSPolicy] of the next instance, or null if there is no next instance.
  @override
  CORSPolicy? get policy {
    return nextInstanceToReceive?.policy;
  }

  /// Sets the CORS policy for this controller recycler.
  ///
  /// This setter overrides the CORS policy for the recycled controllers.
  /// When set, it updates the [policyOverride] property, which is used
  /// to apply the policy to newly generated controller instances.
  ///
  /// Parameters:
  ///   p: The [CORSPolicy] to be set. Can be null to remove the override.
  @override
  set policy(CORSPolicy? p) {
    policyOverride = p;
  }

  /// Links a controller to this recycler and updates the next instance's next controller.
  ///
  /// This method extends the base [link] functionality by also setting the
  /// [_nextController] of the [nextInstanceToReceive] to the newly linked controller.
  ///
  /// Parameters:
  ///   instantiator: A function that returns a new [Controller] instance.
  ///
  /// Returns:
  ///   The newly linked [Linkable] controller.
  @override
  Linkable link(Controller Function() instantiator) {
    final c = super.link(instantiator);
    nextInstanceToReceive?._nextController = c as Controller;
    return c;
  }

  /// Links a function controller to this recycler and updates the next instance's next controller.
  ///
  /// This method extends the base [linkFunction] functionality by also setting the
  /// [_nextController] of the [nextInstanceToReceive] to the newly linked function controller.
  ///
  /// Parameters:
  ///   handle: A function that takes a [Request] and returns a [FutureOr<RequestOrResponse?>].
  ///
  /// Returns:
  ///   The newly linked [Linkable] controller, or null if the linking failed.
  @override
  Linkable? linkFunction(
    FutureOr<RequestOrResponse?> Function(Request request) handle,
  ) {
    final c = super.linkFunction(handle);
    nextInstanceToReceive?._nextController = c as Controller?;
    return c;
  }

  /// Receives and processes an incoming request.
  ///
  /// This method is responsible for handling the request by delegating it to the next
  /// instance in the recycling chain. It performs the following steps:
  /// 1. Retrieves the current next instance to receive the request.
  /// 2. Generates a new instance to be the next receiver.
  /// 3. Delegates the request handling to the current next instance.
  ///
  /// This approach ensures that each request is handled by a fresh instance,
  /// while maintaining the recycling pattern for efficient resource usage.
  ///
  /// Parameters:
  ///   req: The incoming [Request] to be processed.
  ///
  /// Returns:
  ///   A [Future] that completes when the request has been handled.
  @override
  Future? receive(Request req) {
    final next = nextInstanceToReceive;
    nextInstanceToReceive = generator() as Recyclable<T>;
    return next!.receive(req);
  }

  /// This method should never be called directly on a _ControllerRecycler.
  ///
  /// The _ControllerRecycler is designed to delegate request handling to its
  /// recycled instances. If this method is invoked, it indicates a bug in the
  /// controller recycling mechanism.
  ///
  /// @param request The incoming request (unused in this implementation).
  /// @throws StateError Always throws an error to indicate improper usage.
  @override
  FutureOr<RequestOrResponse> handle(Request request) {
    throw StateError("_ControllerRecycler invoked handle. This is a bug.");
  }

  /// Prepares the controller for handling requests after being added to the channel.
  ///
  /// This method is called after the controller is added to the request handling channel,
  /// but before any requests are processed. It initializes the next instance to receive
  /// requests by calling its [didAddToChannel] method.
  ///
  /// Note: This implementation does not call the superclass method because the
  /// [nextInstanceToReceive]'s [nextController] is set to the same instance, and it must
  /// call [nextController.didAddToChannel] itself to avoid duplicate preparation.
  @override
  void didAddToChannel() {
    // don't call super, since nextInstanceToReceive's nextController is set to the same instance,
    // and it must call nextController.prepare
    nextInstanceToReceive?.didAddToChannel();
  }

  /// Delegates the documentation of API components to the next instance to receive requests.
  ///
  /// This method is part of the API documentation process. It calls the [documentComponents]
  /// method on the [nextInstanceToReceive] if it exists, passing along the [components]
  /// context. This allows the documentation to be generated for the next controller in the
  /// recycling chain.
  ///
  /// If [nextInstanceToReceive] is null, this method does nothing.
  ///
  /// Parameters:
  ///   components: The [APIDocumentContext] used for generating API documentation.
  @override
  void documentComponents(APIDocumentContext components) =>
      nextInstanceToReceive?.documentComponents(components);

  /// Delegates the documentation of API paths to the next instance to receive requests.
  ///
  /// This method is part of the API documentation process. It calls the [documentPaths]
  /// method on the [nextInstanceToReceive] if it exists, passing along the [components]
  /// context. This allows the documentation to be generated for the next controller in the
  /// recycling chain.
  ///
  /// If [nextInstanceToReceive] is null or its [documentPaths] returns null, an empty map is returned.
  ///
  /// Parameters:
  ///   components: The [APIDocumentContext] used for generating API documentation.
  ///
  /// Returns:
  ///   A [Map] where keys are path strings and values are [APIPath] objects,
  ///   or an empty map if no paths are documented.
  @override
  Map<String, APIPath> documentPaths(APIDocumentContext components) =>
      nextInstanceToReceive?.documentPaths(components) ?? {};

  /// Delegates the documentation of API operations to the next instance to receive requests.
  ///
  /// This method is part of the API documentation process. It calls the [documentOperations]
  /// method on the [nextInstanceToReceive] if it exists, passing along the [components],
  /// [route], and [path] parameters. This allows the documentation to be generated for
  /// the next controller in the recycling chain.
  ///
  /// If [nextInstanceToReceive] is null or its [documentOperations] returns null, an empty map is returned.
  ///
  /// Parameters:
  ///   components: The [APIDocumentContext] used for generating API documentation.
  ///   route: A string representing the route for which operations are being documented.
  ///   path: An [APIPath] object representing the path for which operations are being documented.
  ///
  /// Returns:
  ///   A [Map] where keys are operation identifiers (typically HTTP methods) and values are
  ///   [APIOperation] objects, or an empty map if no operations are documented.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext components,
    String route,
    APIPath path,
  ) =>
      nextInstanceToReceive?.documentOperations(components, route, path) ?? {};
}

/// A controller that wraps a function to handle requests.
@PreventCompilation()
class _FunctionController extends Controller {
  _FunctionController(this._handler);

  /// The function that handles requests.
  final FutureOr<RequestOrResponse?> Function(Request) _handler;

  /// Handles the incoming request by invoking the function controller.
  ///
  /// This method is the core of the _FunctionController, responsible for
  /// processing incoming requests. It delegates the request handling to
  /// the function (_handler) that was provided when this controller was created.
  ///
  /// Parameters:
  ///   request: The incoming [Request] object to be handled.
  ///
  /// Returns:
  ///   A [FutureOr] that resolves to a [RequestOrResponse] object or null.
  ///   The return value depends on the implementation of the _handler function:
  ///   - If it returns a [Response], that will be the result.
  ///   - If it returns a [Request], that request will be forwarded to the next controller.
  ///   - If it returns null, the request is considered handled, and no further processing occurs.
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    return _handler(request);
  }

  /// Documents the API operations for this controller.
  ///
  /// This method is responsible for generating documentation for the API operations
  /// associated with this controller. It delegates the documentation process to
  /// the next controller in the chain, if one exists.
  ///
  /// Parameters:
  /// - [context]: The API documentation context.
  /// - [route]: The route string for the current path.
  /// - [path]: The APIPath object representing the current path.
  ///
  /// Returns:
  /// A map where the keys are operation identifiers (typically HTTP methods)
  /// and the values are [APIOperation] objects describing the operations.
  /// If there is no next controller, it returns an empty map.
  @override
  Map<String, APIOperation> documentOperations(
    APIDocumentContext context,
    String route,
    APIPath path,
  ) {
    if (nextController == null) {
      return {};
    }

    return nextController!.documentOperations(context, route, path);
  }
}

/// Abstract class representing the runtime of a controller.
abstract class ControllerRuntime {
  /// Whether the controller is mutable.
  bool get isMutable;

  /// The resource controller runtime, if applicable.
  ResourceControllerRuntime? get resourceController;
}
