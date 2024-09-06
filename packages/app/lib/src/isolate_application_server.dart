/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:protevus_application/application.dart';

/// An isolated server implementation of the ApplicationServer class.
///
/// This class extends ApplicationServer to run in a separate isolate, allowing
/// for concurrent execution of multiple server instances. It manages communication
/// with a supervising application through message passing.
///
/// The server can be started, stopped, and can send and receive application events.
/// It also supports optional console logging for debugging purposes.
///
/// Constructor parameters:
/// - channelType: The type of channel to be used.
/// - configuration: ApplicationOptions for server configuration.
/// - identifier: A unique identifier for this server instance.
/// - supervisingApplicationPort: SendPort for communicating with the supervising application.
/// - logToConsole: Optional flag to enable console logging (default is false).
class ApplicationIsolateServer extends ApplicationServer {
  /// Constructor for ApplicationIsolateServer.
  ///
  /// Creates a new instance of ApplicationIsolateServer with the specified parameters.
  ///
  /// Parameters:
  /// - channelType: The type of channel to be used for communication.
  /// - configuration: ApplicationOptions for configuring the server.
  /// - identifier: A unique identifier for this server instance.
  /// - supervisingApplicationPort: SendPort for communicating with the supervising application.
  /// - logToConsole: Optional flag to enable console logging (default is false).
  ///
  /// This constructor initializes the server, sets up logging if enabled, and establishes
  /// communication with the supervising application. It also sets up a listener for
  /// incoming messages from the supervisor.
  ApplicationIsolateServer(
    Type channelType,
    ApplicationOptions configuration,
    int identifier,
    this.supervisingApplicationPort, {
    bool logToConsole = false,
  }) : super(channelType, configuration, identifier) {
    if (logToConsole) {
      hierarchicalLoggingEnabled = true;
      logger.level = Level.ALL;
      // ignore: avoid_print
      logger.onRecord.listen(print);
    }
    supervisingReceivePort = ReceivePort();
    supervisingReceivePort.listen(listener);

    logger
        .fine("ApplicationIsolateServer($identifier) listening, sending port");
    supervisingApplicationPort.send(supervisingReceivePort.sendPort);
  }

  /// A SendPort used for communication with the supervising application.
  ///
  /// This SendPort allows the ApplicationIsolateServer to send messages and events
  /// back to the supervising application, enabling bidirectional communication
  /// between the isolated server and its parent process.
  SendPort supervisingApplicationPort;

  /// A ReceivePort for receiving messages from the supervising application.
  ///
  /// This ReceivePort is used to listen for incoming messages from the supervising
  /// application. It's initialized in the constructor and is used to set up a
  /// listener for handling various commands and messages, such as stop requests
  /// or application events.
  ///
  /// The 'late' keyword indicates that this variable will be initialized after
  /// the constructor body, but before it's used.
  late ReceivePort supervisingReceivePort;

  /// Starts the ApplicationIsolateServer.
  ///
  /// This method overrides the base class's start method to add functionality
  /// specific to the isolated server. It performs the following steps:
  /// 1. Calls the superclass's start method with the provided shareHttpServer parameter.
  /// 2. Logs a fine-level message indicating that the server has started.
  /// 3. Sends a 'listening' message to the supervising application.
  ///
  /// Parameters:
  /// - shareHttpServer: A boolean indicating whether to share the HTTP server (default is false).
  ///
  /// Returns:
  /// A Future that completes with the result of the superclass's start method.
  ///
  /// Throws:
  /// Any exceptions that may be thrown by the superclass's start method.
  @override
  Future start({bool shareHttpServer = false}) async {
    final result = await super.start(shareHttpServer: shareHttpServer);
    logger.fine(
      "ApplicationIsolateServer($identifier) started, sending listen message",
    );
    supervisingApplicationPort
        .send(ApplicationIsolateSupervisor.messageKeyListening);

    return result;
  }

  /// Sends an application event to the supervising application.
  ///
  /// This method overrides the base class's sendApplicationEvent method to
  /// implement event sending in the context of an isolated server. It wraps
  /// the event in a MessageHubMessage and sends it through the
  /// supervisingApplicationPort.
  ///
  /// Parameters:
  /// - event: The application event to be sent. Can be of any type.
  ///
  /// If an error occurs during the sending process, it is caught and added
  /// to the hubSink as an error, along with the stack trace.
  ///
  /// Note: This method does not throw exceptions directly; instead, it
  /// reports errors through the hubSink.
  @override
  void sendApplicationEvent(dynamic event) {
    try {
      supervisingApplicationPort.send(MessageHubMessage(event));
    } catch (e, st) {
      hubSink?.addError(e, st);
    }
  }

  /// Listener method for handling incoming messages from the supervising application.
  ///
  /// This method processes two types of messages:
  /// 1. A stop message (ApplicationIsolateSupervisor.messageKeyStop):
  ///    When received, it calls the stop() method to shut down the server.
  /// 2. A MessageHubMessage:
  ///    When received, it adds the payload of the message to the hubSink.
  ///
  /// Parameters:
  /// - message: The incoming message. Can be either a stop command or a MessageHubMessage.
  ///
  /// This method doesn't return any value but performs actions based on the message type:
  /// - For a stop message, it initiates the server shutdown process.
  /// - For a MessageHubMessage, it propagates the payload to the hubSink if it exists.
  ///
  /// Note: This method assumes that hubSink is properly initialized elsewhere in the class.
  void listener(dynamic message) {
    if (message == ApplicationIsolateSupervisor.messageKeyStop) {
      stop();
    } else if (message is MessageHubMessage) {
      hubSink?.add(message.payload);
    }
  }

  /// Stops the ApplicationIsolateServer and performs cleanup operations.
  ///
  /// This method performs the following steps:
  /// 1. Closes the supervisingReceivePort to stop receiving messages.
  /// 2. Logs a fine-level message indicating the server is closing.
  /// 3. Calls the close() method to shut down the server.
  /// 4. Logs a fine-level message confirming the server has closed.
  /// 5. Clears all listeners from the logger.
  /// 6. Logs a fine-level message indicating it's sending a stop acknowledgement.
  /// 7. Sends a stop acknowledgement message to the supervising application.
  ///
  /// Returns:
  /// A Future that completes when all stop operations are finished.
  ///
  /// Note: This method is asynchronous and should be awaited when called.
  Future stop() async {
    supervisingReceivePort.close();
    logger.fine("ApplicationIsolateServer($identifier) closing server");
    await close();
    logger.fine("ApplicationIsolateServer($identifier) did close server");
    logger.clearListeners();
    logger.fine(
      "ApplicationIsolateServer($identifier) sending stop acknowledgement",
    );
    supervisingApplicationPort
        .send(ApplicationIsolateSupervisor.messageKeyStop);
  }
}

/// A typedef defining the signature for an isolate entry function.
///
/// This function type is used to define the entry point for an isolate in the context
/// of an ApplicationIsolateServer. It takes a single parameter of type
/// ApplicationInitialServerMessage, which contains all the necessary information
/// to initialize and run the server within the isolate.
///
/// Parameters:
/// - message: An ApplicationInitialServerMessage object containing configuration
///   details, identifiers, and communication ports needed to set up the server
///   in the isolate.
///
/// This typedef is typically used when spawning new isolates for server instances,
/// allowing for a standardized way of passing initial setup information to the isolate.
typedef IsolateEntryFunction = void Function(
  ApplicationInitialServerMessage message,
);

/// Represents the initial message sent to an ApplicationIsolateServer when it's created.
///
/// This class encapsulates all the necessary information needed to initialize and
/// configure an ApplicationIsolateServer within an isolate. It includes details about
/// the stream type, configuration options, communication ports, and logging preferences.
///
/// Properties:
/// - streamTypeName: The name of the stream type to be used by the server.
/// - streamLibraryURI: The URI of the library containing the stream implementation.
/// - configuration: ApplicationOptions object containing server configuration details.
/// - parentMessagePort: SendPort for communicating with the parent (supervising) application.
/// - identifier: A unique identifier for the server instance.
/// - logToConsole: A boolean flag indicating whether to enable console logging (default is false).
///
/// This class is typically used when spawning a new isolate for an ApplicationIsolateServer,
/// providing all the necessary information in a single, structured message.
class ApplicationInitialServerMessage {
  ApplicationInitialServerMessage(
    this.streamTypeName,
    this.streamLibraryURI,
    this.configuration,
    this.identifier,
    this.parentMessagePort, {
    this.logToConsole = false,
  });

  String streamTypeName;
  Uri streamLibraryURI;
  ApplicationOptions configuration;
  SendPort parentMessagePort;
  int identifier;
  bool logToConsole = false;
}

/// Represents a message that can be sent through the message hub.
///
/// This class encapsulates a payload of any type, allowing for flexible
/// communication between different parts of the application.
///
/// The payload can be of any type (dynamic), making this class versatile
/// for various types of messages.
///
/// Parameters:
/// - payload: The content of the message, which can be of any type.
class MessageHubMessage {
  MessageHubMessage(this.payload);

  dynamic payload;
}
