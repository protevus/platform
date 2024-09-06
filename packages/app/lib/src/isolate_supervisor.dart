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

import 'package:protevus_application/application.dart';
import 'package:logging/logging.dart';

/// Represents the supervision of a [ApplicationIsolateServer].
///
/// This class, ApplicationIsolateSupervisor, is responsible for supervising and managing
/// an [ApplicationIsolateServer]. It handles the lifecycle of the isolate, including
/// starting, stopping, and communicating with it. The supervisor also manages error
/// handling, message passing between isolates, and ensures proper startup and shutdown
/// of the supervised isolate.
///
/// You should not use this class directly.
class ApplicationIsolateSupervisor {
  /// Creates an instance of [ApplicationIsolateSupervisor].
  ///
  /// This constructor initializes a new [ApplicationIsolateSupervisor] with the provided parameters.
  ///
  /// Parameters:
  /// - [supervisingApplication]: The [Application] instance that owns this supervisor.
  /// - [isolate]: The [Isolate] being supervised.
  /// - [receivePort]: The [ReceivePort] for receiving messages from the supervised isolate.
  /// - [identifier]: A numeric identifier for the isolate relative to the [Application].
  /// - [logger]: The [Logger] instance used for logging.
  /// - [startupTimeout]: Optional. The maximum duration to wait for the isolate to start up.
  ///   Defaults to 30 seconds.
  ApplicationIsolateSupervisor(
    this.supervisingApplication,
    this.isolate,
    this.receivePort,
    this.identifier,
    this.logger, {
    this.startupTimeout = const Duration(seconds: 30),
  });

  /// The [Isolate] being supervised by this [ApplicationIsolateSupervisor].
  ///
  /// This isolate represents a separate thread of execution where the
  /// [ApplicationIsolateServer] runs. The supervisor manages the lifecycle
  /// and communication with this isolate.
  final Isolate isolate;

  /// The [ReceivePort] for receiving messages from the supervised isolate.
  ///
  /// This [ReceivePort] is used to establish a communication channel between
  /// the supervisor and the supervised isolate. It allows the supervisor to
  /// receive various types of messages, including startup notifications,
  /// error reports, and custom messages from the isolate.
  ///
  /// The [receivePort] is crucial for managing the lifecycle of the isolate
  /// and handling inter-isolate communication. It is used in conjunction with
  /// the [listener] method to process incoming messages from the isolate.
  final ReceivePort receivePort;

  /// A numeric identifier for the isolate relative to the [Application].
  ///
  /// This identifier is unique within the context of the parent [Application].
  /// It is used to distinguish between different isolates managed by the same
  /// application, facilitating logging, debugging, and isolate management.
  /// The identifier is typically assigned sequentially when creating new isolates.
  final int identifier;

  /// The maximum duration to wait for the isolate to start up.
  ///
  /// This duration specifies the time limit for the supervised isolate to complete its
  /// startup process. If the isolate fails to start within this timeout period, an
  /// exception will be thrown. This helps prevent indefinite waiting in case of startup
  /// issues.
  ///
  /// The default value is typically set in the constructor, often to 30 seconds.
  final Duration startupTimeout;

  /// A reference to the owning [Application].
  ///
  /// This property holds a reference to the [Application] instance that owns and manages
  /// this [ApplicationIsolateSupervisor]. It allows the supervisor to interact with
  /// the main application, access shared resources, and coordinate activities across
  /// multiple isolates.
  ///
  /// The supervising application is responsible for creating and managing the lifecycle
  /// of this supervisor and its associated isolate. It also provides context for
  /// operations such as logging, configuration, and inter-isolate communication.
  Application supervisingApplication;

  /// The logger instance used for recording events and errors.
  ///
  /// This [Logger] is typically shared with the [supervisingApplication] and is used
  /// to log various events, warnings, and errors related to the isolate supervision
  /// process. It helps in debugging and monitoring the behavior of the supervised
  /// isolate and the supervisor itself.
  ///
  /// The logger can be used to record information at different severity levels,
  /// such as fine, info, warning, and severe, depending on the nature of the event
  /// being logged.
  Logger logger;

  /// A list to store pending [MessageHubMessage] objects.
  ///
  /// This queue is used to temporarily hold messages that are received when the
  /// supervising application is not running. Once the application starts running,
  /// these messages are processed and sent to other supervisors.
  ///
  /// The queue helps ensure that no messages are lost during the startup phase
  /// of the application, maintaining message integrity across isolates.
  final List<MessageHubMessage> _pendingMessageQueue = [];

  /// Indicates whether the isolate is currently in the process of launching.
  ///
  /// This getter returns `true` if the isolate is still in the startup phase,
  /// and `false` if the launch process has completed.
  ///
  /// It checks the state of the [_launchCompleter] to determine if the
  /// launch process is still ongoing. If the completer is not yet completed,
  /// it means the isolate is still launching.
  ///
  /// This property is useful for handling different behaviors or error states
  /// depending on whether the isolate is in its launch phase or has already
  /// started running normally.
  bool get _isLaunching => !_launchCompleter.isCompleted;

  /// The [SendPort] used to send messages to the supervised isolate.
  ///
  /// This [SendPort] is initialized when the supervisor receives the corresponding
  /// [SendPort] from the supervised isolate during the startup process. It enables
  /// bi-directional communication between the supervisor and the supervised isolate.
  ///
  /// The [_serverSendPort] is used to send various messages to the isolate, including
  /// stop signals, custom application messages, and other control commands. It plays
  /// a crucial role in managing the lifecycle and behavior of the supervised isolate.
  late SendPort _serverSendPort;

  /// A [Completer] used to manage the launch process of the supervised isolate.
  ///
  /// This completer is initialized when the isolate is being launched and is completed
  /// when the isolate has successfully started up. It's used in conjunction with
  /// [resume] method to handle the asynchronous nature of isolate startup.
  ///
  /// The completer allows other parts of the supervisor to wait for the isolate
  /// to finish launching before proceeding with further operations. It's also used
  /// to implement timeout functionality in case the isolate fails to start within
  /// the specified [startupTimeout].
  late Completer _launchCompleter;

  /// A [Completer] used to manage the stop process of the supervised isolate.
  ///
  /// This nullable [Completer] is initialized when the [stop] method is called
  /// and is used to handle the asynchronous nature of stopping the isolate.
  /// It allows the supervisor to wait for the isolate to acknowledge the stop
  /// message before proceeding with the termination process.
  ///
  /// The completer is set to null after the stop process is complete, indicating
  /// that the isolate has been successfully stopped. This helps manage the state
  /// of the stop operation and prevents multiple stop attempts from interfering
  /// with each other.
  Completer? _stopCompleter;

  /// A constant string used as a message key to signal the supervised isolate to stop.
  ///
  /// This constant is used in the communication protocol between the supervisor
  /// and the supervised isolate. When sent to the isolate, it indicates that
  /// the isolate should begin its shutdown process.
  ///
  /// The underscore prefix in the value suggests that this is intended for
  /// internal use within the isolate communication system.
  static const String messageKeyStop = "_MessageStop";

  /// A constant string used as a message key to indicate that the supervised isolate is listening.
  ///
  /// This constant is part of the communication protocol between the supervisor
  /// and the supervised isolate. When the isolate sends this message to the
  /// supervisor, it signals that the isolate has completed its startup process
  /// and is ready to receive and process messages.
  ///
  /// The underscore prefix in the value suggests that this is intended for
  /// internal use within the isolate communication system.
  static const String messageKeyListening = "_MessageListening";

  /// Resumes the [Isolate] being supervised.
  ///
  /// This method initiates the process of resuming the supervised isolate and
  /// sets up the necessary listeners and error handlers. It performs the following steps:
  ///
  /// 1. Initializes a new [Completer] for managing the launch process.
  /// 2. Sets up a listener for the [receivePort] to handle incoming messages.
  /// 3. Configures the isolate to handle errors non-fatally.
  /// 4. Adds an error listener to the isolate.
  /// 5. Resumes the isolate from its paused state.
  /// 6. Waits for the isolate to complete its startup process.
  ///
  /// If the isolate fails to start within the specified [startupTimeout], a
  /// [TimeoutException] is thrown with a detailed error message.
  ///
  /// Returns a [Future] that completes when the isolate has successfully started,
  /// or throws an exception if the startup process fails or times out.
  ///
  /// Throws:
  /// - [TimeoutException] if the isolate doesn't start within the [startupTimeout].
  Future resume() {
    _launchCompleter = Completer();
    receivePort.listen(listener);

    isolate.setErrorsFatal(false);
    isolate.addErrorListener(receivePort.sendPort);
    logger.fine(
      "ApplicationIsolateSupervisor($identifier).resume will resume isolate",
    );
    isolate.resume(isolate.pauseCapability!);

    return _launchCompleter.future.timeout(
      startupTimeout,
      onTimeout: () {
        logger.fine(
          "ApplicationIsolateSupervisor($identifier).resume timed out waiting for isolate start",
        );
        throw TimeoutException(
            "Isolate ($identifier) failed to launch in $startupTimeout seconds. "
            "There may be an error with your application or Application.isolateStartupTimeout needs to be increased.");
      },
    );
  }

  /// Stops the [Isolate] being supervised.
  ///
  /// This method initiates the process of stopping the supervised isolate. It performs the following steps:
  ///
  /// 1. Creates a new [Completer] to manage the stop process.
  /// 2. Sends a stop message to the supervised isolate using [_serverSendPort].
  /// 3. Waits for the isolate to acknowledge the stop message.
  /// 4. If the isolate doesn't respond within 5 seconds, logs a severe message.
  /// 5. Forcefully kills the isolate using [isolate.kill()].
  /// 6. Closes the [receivePort] to clean up resources.
  ///
  /// The method uses a timeout of 5 seconds to wait for the isolate's acknowledgment.
  /// If the timeout occurs, it assumes the isolate is not responding and proceeds to terminate it.
  ///
  /// This method ensures that the isolate is stopped one way or another, either gracefully
  /// or by force, and properly cleans up associated resources.
  ///
  /// Returns a [Future] that completes when the stop process is finished, regardless of
  /// whether the isolate responded to the stop message or was forcefully terminated.
  Future stop() async {
    _stopCompleter = Completer();
    logger.fine(
      "ApplicationIsolateSupervisor($identifier).stop sending stop to supervised isolate",
    );
    _serverSendPort.send(messageKeyStop);

    try {
      await _stopCompleter!.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      logger.severe(
        "Isolate ($identifier) not responding to stop message, terminating.",
      );
    } finally {
      isolate.kill();
    }

    receivePort.close();
  }

  /// Handles incoming messages from the supervised isolate.
  ///
  /// This method is the central message processing function for the supervisor.
  /// It handles various types of messages:
  ///
  /// - [SendPort]: Stores the send port for communicating with the isolate.
  /// - [messageKeyListening]: Indicates the isolate has started and is listening.
  /// - [messageKeyStop]: Acknowledges that the isolate has received a stop message.
  /// - [List]: Represents an error from the isolate, which is then handled.
  /// - [MessageHubMessage]: Inter-isolate communication message.
  ///
  /// For [MessageHubMessage], if the supervising application is not running,
  /// the message is queued. Otherwise, it's immediately sent to other supervisors.
  ///
  /// This method is crucial for managing the lifecycle and communication of the
  /// supervised isolate, handling startup, shutdown, errors, and inter-isolate messaging.
  void listener(dynamic message) {
    if (message is SendPort) {
      _serverSendPort = message;
    } else if (message == messageKeyListening) {
      _launchCompleter.complete();
      logger.fine(
        "ApplicationIsolateSupervisor($identifier) isolate listening acknowledged",
      );
    } else if (message == messageKeyStop) {
      logger.fine(
        "ApplicationIsolateSupervisor($identifier) stop message acknowledged",
      );
      receivePort.close();

      _stopCompleter!.complete();
      _stopCompleter = null;
    } else if (message is List) {
      logger.fine(
        "ApplicationIsolateSupervisor($identifier) received isolate error ${message.first}",
      );
      final stacktrace = StackTrace.fromString(message.last as String);
      _handleIsolateException(message.first, stacktrace);
    } else if (message is MessageHubMessage) {
      if (!supervisingApplication.isRunning) {
        _pendingMessageQueue.add(message);
      } else {
        _sendMessageToOtherSupervisors(message);
      }
    }
  }

  /// Sends all pending messages stored in the [_pendingMessageQueue] to other supervisors.
  ///
  /// This method is typically called when the supervising application starts running
  /// to process any messages that were received while the application was not active.
  /// It performs the following steps:
  ///
  /// 1. Creates a copy of the [_pendingMessageQueue] to safely iterate over it.
  /// 2. Clears the original [_pendingMessageQueue].
  /// 3. Sends each message in the copied list to other supervisors using [_sendMessageToOtherSupervisors].
  ///
  /// This ensures that no messages are lost during the startup phase of the application
  /// and maintains message integrity across isolates.
  void sendPendingMessages() {
    final list = List<MessageHubMessage>.from(_pendingMessageQueue);
    _pendingMessageQueue.clear();
    list.forEach(_sendMessageToOtherSupervisors);
  }

  /// Sends a [MessageHubMessage] to all other supervisors managed by the supervising application.
  ///
  /// This method is responsible for propagating messages across different isolates
  /// managed by the same application. It performs the following actions:
  ///
  /// 1. Iterates through all supervisors in the supervising application.
  /// 2. Excludes the current supervisor from the recipients.
  /// 3. Sends the provided [message] to each of the other supervisors' isolates.
  ///
  /// This method is crucial for maintaining communication and synchronization
  /// between different isolates within the application.
  ///
  /// Parameters:
  /// - [message]: The [MessageHubMessage] to be sent to other supervisors.
  void _sendMessageToOtherSupervisors(MessageHubMessage message) {
    supervisingApplication.supervisors
        .where((sup) => sup != this)
        .forEach((supervisor) {
      supervisor._serverSendPort.send(message);
    });
  }

  /// Handles exceptions thrown by the supervised isolate.
  ///
  /// This method is responsible for processing and responding to exceptions
  /// that occur within the supervised isolate. It behaves differently depending
  /// on whether the isolate is still in the process of launching or not:
  ///
  /// - If the isolate is launching ([_isLaunching] is true):
  ///   It wraps the error in an [ApplicationStartupException] and completes
  ///   the [_launchCompleter] with this error, effectively failing the launch process.
  ///
  /// - If the isolate has already launched:
  ///   It logs the error as a severe uncaught exception using the supervisor's logger.
  ///
  /// Parameters:
  /// - [error]: The error or exception object thrown by the isolate.
  /// - [stacktrace]: The [StackTrace] associated with the error.
  ///
  /// This method is crucial for maintaining the stability and error handling
  /// of the isolate, especially during its startup phase.
  void _handleIsolateException(dynamic error, StackTrace stacktrace) {
    if (_isLaunching) {
      final appException = ApplicationStartupException(error);
      _launchCompleter.completeError(appException, stacktrace);
    } else {
      logger.severe("Uncaught exception in isolate.", error, stacktrace);
    }
  }
}
