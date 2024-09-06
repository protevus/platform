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
import 'package:logging/logging.dart';
import 'package:protevus_application/application.dart';
import 'package:protevus_http/http.dart';
import 'package:protevus_runtime/runtime.dart';

/// A class representing an application server in the Conduit framework.
///
/// The ApplicationServer class is responsible for managing the lifecycle of an HTTP server
/// and its associated [ApplicationChannel]. It handles server creation, starting, and stopping,
/// as well as routing incoming requests to the appropriate handlers.
///
/// Key features:
/// - Creates and manages an instance of [ApplicationChannel]
/// - Configures and starts an HTTP or HTTPS server
/// - Handles incoming requests and routes them to the appropriate controller
/// - Manages server lifecycle (start, stop, close)
/// - Provides logging capabilities
/// - Supports both IPv4 and IPv6
/// - Handles secure connections with SSL/TLS
///
/// This class is typically instantiated and managed by the Application class and should not
/// be created directly in most cases
class ApplicationServer {
  /// Creates a new server instance.
  ///
  /// You should not need to invoke this method directly.
  ApplicationServer(this.channelType, this.options, this.identifier) {
    channel = (RuntimeContext.current[channelType] as ChannelRuntime)
        .instantiateChannel()
      ..server = this
      ..options = options;
  }

  /// The configuration options used to start this server's [channel].
  ///
  /// This property holds an instance of [ApplicationOptions] which contains
  /// various settings used to configure the server, such as the address to bind to,
  /// the port number, SSL/TLS settings, and other application-specific options.
  /// These options are passed to the [ApplicationChannel] when it is initialized.
  ApplicationOptions options;

  /// The underlying [HttpServer] instance used by this [ApplicationServer].
  ///
  /// This property represents the core HTTP server that handles incoming requests.
  /// It is initialized when the server starts and is used throughout the lifecycle
  /// of the [ApplicationServer] to manage incoming connections and route requests
  /// to the appropriate handlers.
  ///
  /// The server can be either a standard HTTP server or an HTTPS server, depending
  /// on the configuration and security context provided during initialization.
  late final HttpServer server;

  /// The instance of [ApplicationChannel] serving requests.
  ///
  /// This property represents the primary request handling pipeline for the application.
  /// It is instantiated when the ApplicationServer is created and is responsible for
  /// processing incoming HTTP requests, routing them to appropriate controllers,
  /// and generating responses.
  ///
  /// The [ApplicationChannel] is a custom class defined by the application developer
  /// that sets up the request handling logic, including middleware, controllers,
  /// and other application-specific components.
  late ApplicationChannel channel;

  /// The cached entrypoint of [channel].
  ///
  /// This property stores the main [Controller] that serves as the entry point for request handling.
  /// It is initialized when the server starts and is used to process incoming HTTP requests.
  /// The entrypoint controller typically represents the root of the request handling pipeline
  /// and may delegate to other controllers or middleware as needed.
  late Controller entryPoint;

  /// The type of [ApplicationChannel] this server will use.
  ///
  /// This property stores the Type of the ApplicationChannel subclass that will be
  /// instantiated and used by this ApplicationServer. The ApplicationChannel
  /// defines the request handling logic and routing for the application.
  final Type channelType;

  /// Target for sending messages to other [ApplicationChannel.messageHub]s.
  ///
  /// This property represents an [EventSink] that can be used to send messages
  /// to other [ApplicationChannel.messageHub]s across different instances of
  /// the application. It is primarily used for inter-server communication in
  /// distributed setups.
  ///
  /// The [hubSink] is typically set and managed by instances of [ApplicationMessageHub].
  /// Application developers should not directly modify or use this property, as it is
  /// intended for internal framework use.
  ///
  /// The sink can be null if no message hub has been configured for this server.
  EventSink<dynamic>? hubSink;

  /// Indicates whether this server requires an HTTPS listener.
  ///
  /// This getter returns a boolean value that determines if the server
  /// should use HTTPS instead of HTTP. It is typically set to true when
  /// a security context is provided during server initialization.
  ///
  /// Returns:
  ///   [bool]: true if the server requires HTTPS, false otherwise.
  bool get requiresHTTPS => _requiresHTTPS;

  /// Indicates whether this server instance is configured to use HTTPS.
  ///
  /// This private variable is set to true when a security context is provided
  /// during server initialization, indicating that the server should use HTTPS.
  /// It is used internally to determine the server's connection type and is
  /// accessed through the public getter [requiresHTTPS].
  ///
  /// The value is false by default, assuming HTTP connection, and is only set to
  /// true when HTTPS is explicitly configured.
  bool _requiresHTTPS = false;

  /// The unique identifier of this instance.
  ///
  /// Each instance has its own identifier, a numeric value starting at 1, to identify it
  /// among other instances.
  ///
  /// This identifier is used to distinguish between different [ApplicationServer] instances
  /// when multiple servers are running concurrently. It's particularly useful for logging
  /// and debugging purposes, allowing developers to trace which server instance is handling
  /// specific requests or operations.
  ///
  /// The identifier is typically assigned automatically by the [Application] class when
  /// creating new server instances, ensuring that each server has a unique number.
  ///
  /// Example:
  ///   If three server instances are created, they might have identifiers 1, 2, and 3 respectively.
  int identifier;

  /// Returns the logger instance for this ApplicationServer.
  ///
  /// This getter provides access to a [Logger] instance specifically configured
  /// for the Conduit framework. The logger is named "conduit" and can be used
  /// throughout the ApplicationServer and its associated classes for consistent
  /// logging purposes.
  ///
  /// The logger can be used to record various levels of information, warnings,
  /// and errors during the server's operation, which is crucial for debugging
  /// and monitoring the application's behavior.
  ///
  /// Returns:
  ///   A [Logger] instance named "conduit".
  Logger get logger => Logger("protevus");

  /// Starts this instance, allowing it to receive HTTP requests.
  ///
  /// This method initializes the server, preparing it to handle incoming HTTP requests.
  /// It performs the following steps:
  /// 1. Prepares the channel by calling [channel.prepare()].
  /// 2. Sets up the entry point for request handling.
  /// 3. Binds the HTTP server to the specified address and port.
  /// 4. Configures HTTPS if a security context is provided.
  ///
  /// The method supports both HTTP and HTTPS connections, determined by the presence
  /// of a security context. It also handles IPv6 configuration and server sharing options.
  ///
  /// Parameters:
  ///   [shareHttpServer] - A boolean indicating whether to share the HTTP server
  ///                       across multiple instances. Defaults to false.
  ///
  /// Returns:
  ///   A [Future] that completes when the server has successfully started and is
  ///   ready to receive requests.
  ///
  /// Throws:
  ///   May throw exceptions related to network binding or security context configuration.
  ///
  /// Note:
  ///   This method should not be invoked directly under normal circumstances.
  ///   It is typically called by the framework during the application startup process.
  Future start({bool shareHttpServer = false}) async {
    logger.fine("ApplicationServer($identifier).start entry");

    await channel.prepare();

    entryPoint = channel.entryPoint;
    entryPoint.didAddToChannel();

    logger.fine("ApplicationServer($identifier).start binding HTTP");
    final securityContext = channel.securityContext;
    if (securityContext != null) {
      _requiresHTTPS = true;

      server = await HttpServer.bindSecure(
        options.address,
        options.port,
        securityContext,
        requestClientCertificate: options.isUsingClientCertificate,
        v6Only: options.isIpv6Only,
        shared: shareHttpServer,
      );
    } else {
      _requiresHTTPS = false;

      server = await HttpServer.bind(
        options.address,
        options.port,
        v6Only: options.isIpv6Only,
        shared: shareHttpServer,
      );
    }

    logger.fine("ApplicationServer($identifier).start bound HTTP");
    return didOpen();
  }

  /// Closes this HTTP server and associated channel.
  ///
  /// This method performs the following steps:
  /// 1. Closes the HTTP server, forcibly terminating any ongoing connections.
  /// 2. Closes the associated [ApplicationChannel].
  /// 3. Closes the [hubSink] if it exists.
  ///
  /// The method logs the progress of each step for debugging purposes.
  ///
  /// Returns:
  ///   A [Future] that completes when all closing operations are finished.
  ///
  /// Note:
  ///   The [hubSink] is actually closed by channel.messageHub.close, but it's
  ///   explicitly closed here to satisfy the Dart analyzer.
  Future close() async {
    logger.fine("ApplicationServer($identifier).close Closing HTTP listener");
    await server.close(force: true);
    logger.fine("ApplicationServer($identifier).close Closing channel");
    await channel.close();

    // This is actually closed by channel.messageHub.close, but this shuts up the analyzer.
    hubSink?.close();
    logger.fine("ApplicationServer($identifier).close Closing complete");
  }

  /// Invoked when this server becomes ready to receive requests.
  ///
  /// [ApplicationChannel.willStartReceivingRequests] is invoked after this opening has completed.
  Future didOpen() async {
    server.serverHeader = "conduit/$identifier";

    logger.fine("ApplicationServer($identifier).didOpen start listening");
    server.map((baseReq) => Request(baseReq)).listen(entryPoint.receive);

    channel.willStartReceivingRequests();
    logger.info("Server conduit/$identifier started.");
  }

  /// Sends an application event.
  ///
  /// This method is designed to handle application-wide events. By default,
  /// it does nothing and serves as a placeholder for potential event handling
  /// implementations in derived classes.
  ///
  /// Parameters:
  ///   [event]: A dynamic object representing the event to be sent.
  ///            It can be of any type, allowing flexibility in event structures.
  ///
  /// Note:
  ///   Override this method in subclasses to implement specific event handling logic.
  void sendApplicationEvent(dynamic event) {
    // By default, do nothing
  }
}
