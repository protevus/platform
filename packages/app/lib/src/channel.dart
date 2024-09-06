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
import 'package:protevus_application/application.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_openapi/v3.dart';
import 'package:protevus_runtime/runtime.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// An abstract class that defines the behavior specific to your application.
///
/// You create a subclass of [ApplicationChannel] to initialize your application's services and define how HTTP requests are handled by your application.
/// There *must* only be one subclass in an application and it must be visible to your application library file, e.g., 'package:my_app/my_app.dart'.
///
/// You must implement [entryPoint] to define the controllers that comprise your application channel. Most applications will
/// also override [prepare] to read configuration values and initialize services. Some applications will provide an [initializeApplication]
/// method to do global startup tasks.
///
/// When your application is started, an instance of your application channel is created for each isolate (see [Application.start]). Each instance
/// is a replica of your application that runs in its own memory isolated thread.
abstract class ApplicationChannel implements APIComponentDocumenter {
  /// Provides global initialization for the application.
  ///
  /// Most of your application initialization code is written in [prepare], which is invoked for each isolate. For initialization that
  /// needs to occur once per application start, you must provide an implementation for this method. This method is invoked prior
  /// to any isolates being spawned.
  ///
  /// You may alter [options] in this method and those changes will be available in each instance's [options]. To pass arbitrary data
  /// to each of your isolates at startup, add that data to [ApplicationOptions.context].
  ///
  /// Example:
  ///
  ///         class MyChannel extends ApplicationChannel {
  ///           static Future initializeApplication(ApplicationOptions options) async {
  ///             options.context["runtimeOption"] = "foo";
  ///           }
  ///
  ///           Future prepare() async {
  ///             if (options.context["runtimeOption"] == "foo") {
  ///               // do something
  ///             }
  ///           }
  ///         }
  ///
  ///
  /// Do not configure objects like [CodecRegistry], [CORSPolicy.defaultPolicy] or any other value that isn't explicitly passed through [options].
  ///
  /// * Note that static methods are not inherited in Dart and therefore you are not overriding this method. The declaration of this method in the base [ApplicationChannel] class
  /// is for documentation purposes.
  static Future initializeApplication(ApplicationOptions options) async {}

  /// Returns a Logger instance for this object.
  ///
  /// This logger's name appears as 'conduit'.
  Logger get logger => Logger("protevus");

  /// Returns the [ApplicationServer] instance that sends HTTP requests to this object.
  ///
  /// This getter provides access to the server associated with this ApplicationChannel.
  /// The server is responsible for handling incoming HTTP requests and routing them
  /// to the appropriate controllers within the channel.
  ApplicationServer get server => _server;

  /// Sets the ApplicationServer for this channel and establishes message hub connections.
  ///
  /// This setter method performs two main tasks:
  /// 1. It assigns the provided [server] to the private [_server] variable.
  /// 2. It sets up the message hub connections:
  ///    - It adds a listener to the outbound stream of the messageHub, which sends
  ///      application events through the server.
  ///    - It sets the inbound sink of the messageHub as the hubSink of the server.
  ///
  /// This setup allows for inter-isolate communication through the ApplicationMessageHub.
  ///
  /// [server] The ApplicationServer instance to be set for this channel.
  set server(ApplicationServer server) {
    _server = server;
    messageHub._outboundController.stream.listen(server.sendApplicationEvent);
    server.hubSink = messageHub._inboundController.sink;
  }

  /// A messaging hub for inter-isolate communication within the application.
  ///
  /// You use this object to synchronize state across the isolates of an application. Any data sent
  /// through this object will be received by every other channel in your application (except the one that sent it).
  final ApplicationMessageHub messageHub = ApplicationMessageHub();

  /// Returns a SecurityContext for HTTPS configuration if certificate and private key files are provided.
  ///
  /// If this value is non-null, the [server] receiving HTTP requests will only accept requests over HTTPS.
  ///
  /// By default, this value is null. If the [ApplicationOptions] provided to the application are configured to
  /// reference a private key and certificate file, this value is derived from that information. You may override
  /// this method to provide an alternative means to creating a [SecurityContext].
  SecurityContext? get securityContext {
    if (options?.certificateFilePath == null ||
        options?.privateKeyFilePath == null) {
      return null;
    }

    return SecurityContext()
      ..useCertificateChain(options!.certificateFilePath!)
      ..usePrivateKey(options!.privateKeyFilePath!);
  }

  /// The configuration options used to start the application this channel belongs to.
  ///
  /// These options are set when starting the application. Changes to this object have no effect
  /// on other isolates.
  ///
  /// This property holds an instance of [ApplicationOptions] which contains various
  /// configuration settings for the application. These options are typically set
  /// during the application's startup process.
  ///
  /// The options stored here are specific to this channel instance and do not
  /// affect other isolates running in the application. This means that modifying
  /// these options at runtime will only impact the current isolate.
  ///
  /// The property is nullable, allowing for cases where options might not be set
  /// or where default configurations are used in the absence of specific options.
  ApplicationOptions? options;

  /// You implement this accessor to define how HTTP requests are handled by your application.
  ///
  /// You must implement this method to return the first controller that will handle an HTTP request. Additional controllers
  /// are linked to the first controller to create the entire flow of your application's request handling logic. This method
  /// is invoked during startup and controllers cannot be changed after it is invoked. This method is always invoked after
  /// [prepare].
  ///
  /// In most applications, the first controller is a [Router]. Example:
  ///
  ///         @override
  ///         Controller get entryPoint {
  ///           final router = Router();
  ///           router.route("/path").link(() => PathController());
  ///           return router;
  ///         }
  Controller get entryPoint;

  /// The [ApplicationServer] instance associated with this channel.
  ///
  /// This private variable stores the server that handles HTTP requests for this
  /// ApplicationChannel. It is marked as 'late' because it will be initialized
  /// after the channel is created, typically when the 'server' setter is called.
  ///
  /// The server is responsible for managing incoming HTTP connections and
  /// routing requests to the appropriate controllers within the channel.
  late ApplicationServer _server;

  /// Performs initialization tasks for the application channel.
  ///
  /// This method allows this instance to perform any initialization (other than setting up the [entryPoint]). This method
  /// is often used to set up services that [Controller]s use to fulfill their duties. This method is invoked
  /// prior to [entryPoint], so that the services it creates can be injected into [Controller]s.
  ///
  /// By default, this method does nothing.
  Future prepare() async {}

  /// Overridable method called just before the application starts receiving requests.
  ///
  /// Override this method to take action just before [entryPoint] starts receiving requests. By default, does nothing.
  void willStartReceivingRequests() {}

  /// Releases resources and performs cleanup when the application channel is closing.
  ///
  /// This method is invoked when the owning [Application] is stopped. It closes open ports
  /// that this channel was using so that the application can be properly shut down.
  ///
  /// Prefer to use [ServiceRegistry] instead of overriding this method.
  ///
  /// If you do override this method, you must call the super implementation.
  @mustCallSuper
  Future close() async {
    logger.fine(
      "ApplicationChannel(${server.identifier}).close: closing messageHub",
    );
    await messageHub.close();
  }

  /// Creates an OpenAPI document for the components and paths in this channel.
  ///
  /// This method generates a complete OpenAPI specification document for the application,
  /// including all components, paths, and operations defined in the channel.
  ///
  /// The documentation process first invokes [documentComponents] on this channel. Every controller in the channel will have its
  /// [documentComponents] methods invoked. Any declared property
  /// of this channel that implements [APIComponentDocumenter] will have its [documentComponents]
  /// method invoked. If there services that are part of the application, but not stored as properties of this channel, you may override
  /// [documentComponents] in your subclass to add them. You must call the superclass' implementation of [documentComponents].
  ///
  /// After components have been documented, [APIOperationDocumenter.documentPaths] is invoked on [entryPoint]. The controllers
  /// of the channel will add paths and operations to the document during this process.
  ///
  /// This method should not be overridden.
  ///
  /// [projectSpec] should contain the keys `name`, `version` and `description`.
  Future<APIDocument> documentAPI(Map<String, dynamic> projectSpec) async {
    final doc = APIDocument()..components = APIComponents();
    final root = entryPoint;
    root.didAddToChannel();

    final context = APIDocumentContext(doc);
    documentComponents(context);

    doc.paths = root.documentPaths(context);

    doc.info = APIInfo(
      projectSpec["name"] as String?,
      projectSpec["version"] as String?,
      description: projectSpec["description"] as String?,
    );

    await context.finalize();

    return doc;
  }

  /// Documents the components of this ApplicationChannel and its controllers.
  ///
  /// This method is responsible for generating API documentation for the components
  /// of this ApplicationChannel and its associated controllers. It performs the following tasks:
  ///
  /// 1. Calls `documentComponents` on the entry point controller, which typically
  ///    initiates the documentation process for all linked controllers.
  ///
  /// 2. Retrieves all documentable channel components using the ChannelRuntime,
  ///    which are typically services or other objects that implement APIComponentDocumenter.
  ///
  /// 3. Calls `documentComponents` on each of these channel components, allowing
  ///    them to add their own documentation to the API registry.
  ///
  /// This method is marked with @mustCallSuper, indicating that subclasses
  /// overriding this method must call the superclass implementation.
  ///
  /// [registry] The APIDocumentContext used to store and organize the API documentation.
  @mustCallSuper
  @override
  void documentComponents(APIDocumentContext registry) {
    entryPoint.documentComponents(registry);

    (RuntimeContext.current[runtimeType] as ChannelRuntime)
        .getDocumentableChannelComponents(this)
        .forEach((component) {
      component.documentComponents(registry);
    });
  }
}

/// An object that facilitates message passing between [ApplicationChannel]s in different isolates.
///
/// You use this object to share information between isolates. Each [ApplicationChannel] has a property of this type. A message sent through this object
/// is received by every other channel through its hub.
///
/// To receive messages in a hub, add a listener via [listen]. To send messages, use [add].
///
/// For example, an application may want to send data to every connected websocket. A reference to each websocket
/// is only known to the isolate it established a connection on. This data must be sent to each isolate so that each websocket
/// connected to that isolate can send the data:
///
///         router.route("/broadcast").linkFunction((req) async {
///           var message = await req.body.decodeAsString();
///           websocketsOnThisIsolate.forEach((s) => s.add(message);
///           messageHub.add({"event": "broadcastMessage", "data": message});
///           return Response.accepted();
///         });
///
///         messageHub.listen((event) {
///           if (event is Map && event["event"] == "broadcastMessage") {
///             websocketsOnThisIsolate.forEach((s) => s.add(event["data"]);
///           }
///         });
class ApplicationMessageHub extends Stream<dynamic> implements Sink<dynamic> {
  /// A logger instance for the ApplicationMessageHub.
  ///
  /// This logger is used to log messages and errors related to the ApplicationMessageHub.
  /// It is named "protevus" to identify logs from this specific component.
  final Logger _logger = Logger("protevus");

  /// A StreamController for outbound messages.
  ///
  /// This controller manages the stream of outbound messages sent from this
  /// ApplicationMessageHub to other hubs. It is used internally to handle
  /// the flow of messages being sent out to other isolates.
  ///
  /// The stream is not broadcast, meaning it only allows a single subscriber.
  /// This is typically used by the ApplicationServer to listen for outbound
  /// messages and distribute them to other isolates.
  final StreamController<dynamic> _outboundController =
      StreamController<dynamic>();

  /// A StreamController for inbound messages.
  ///
  /// This controller manages the stream of inbound messages received by this
  /// ApplicationMessageHub from other hubs. It is used internally to handle
  /// the flow of messages coming in from other isolates.
  ///
  /// The stream is broadcast, meaning it allows multiple subscribers. This allows
  /// multiple parts of the application to listen for and react to incoming messages
  /// independently.
  final StreamController<dynamic> _inboundController =
      StreamController<dynamic>.broadcast();

  /// Adds a listener for messages from other hubs.
  ///
  /// A class that facilitates message passing between [ApplicationChannel]s in different isolates.
  ///
  /// This class implements both [Stream] and [Sink] interfaces, allowing it to send and receive messages
  /// across isolates. It uses separate controllers for inbound and outbound messages to manage the flow
  /// of data.
  ///
  /// You use this method to add listeners for messages from other hubs.
  /// When another hub [add]s a message, this hub will receive it on [onData].
  ///
  /// [onError], if provided, will be invoked when this isolate tries to [add] invalid data. Only the isolate
  /// that failed to send the data will receive [onError] events.
  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError = false,
  }) =>
      _inboundController.stream.listen(
        onData,
        onError: onError ??
            ((err, StackTrace st) =>
                _logger.severe("ApplicationMessageHub error", err, st)),
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  /// Sends a message to all other hubs.
  ///
  /// This method allows sending a message [event] to all other isolates in the application.
  /// The message will be delivered to all other isolates that have set up a callback using [listen].
  ///
  /// [event] must be isolate-safe data - in general, this means it may not be or contain a closure. Consult the API reference `dart:isolate` for more details. If [event]
  /// is not isolate-safe data, an error is delivered to [listen] on this isolate.
  @override
  void add(dynamic event) {
    _outboundController.sink.add(event);
  }

  /// Closes the message hub and its associated stream controllers.
  ///
  /// This method performs the following tasks:
  /// 1. If the outbound controller has no listeners, it adds a dummy listener
  ///    to prevent potential issues with unhandled stream events.
  /// 2. If the inbound controller has no listeners, it adds a dummy listener
  ///    for the same reason.
  /// 3. Closes both the outbound and inbound controllers.
  ///
  /// This method should be called when the application is shutting down or
  /// when the message hub is no longer needed to ensure proper cleanup of resources.
  ///
  /// Returns a Future that completes when both controllers have been closed.
  @override
  Future close() async {
    if (!_outboundController.hasListener) {
      _outboundController.stream.listen(null);
    }

    if (!_inboundController.hasListener) {
      _inboundController.stream.listen(null);
    }

    await _outboundController.close();
    await _inboundController.close();
  }
}

/// An abstract class that defines the runtime behavior of an ApplicationChannel.
///
/// This class provides methods and properties for managing the lifecycle,
/// documentation, and instantiation of an ApplicationChannel.
abstract class ChannelRuntime {
  Iterable<APIComponentDocumenter> getDocumentableChannelComponents(
    ApplicationChannel channel,
  );

  Type get channelType;

  String get name;
  Uri get libraryUri;
  IsolateEntryFunction get isolateEntryPoint;

  ApplicationChannel instantiateChannel();

  Future runGlobalInitialization(ApplicationOptions config);
}
