import 'package:meta/meta.dart';

/// Contract for event dispatching functionality.
///
/// This contract defines the interface for dispatching events,
/// managing listeners, and handling event broadcasting.
///
/// The contract includes both Laravel-compatible methods and platform-specific
/// extensions for enhanced functionality.
@sealed
abstract class EventDispatcherContract {
  /// Registers an event listener.
  ///
  /// Laravel-compatible: Registers event listeners, but with platform-specific
  /// dynamic typing for more flexible event handling.
  ///
  /// Parameters:
  ///   - [events]: Event type or list of event types to listen for.
  ///   - [listener]: Function to handle the event.
  void listen(dynamic events, dynamic listener);

  /// Checks if event has listeners.
  ///
  /// Platform-specific: Provides listener existence checking.
  ///
  /// Parameters:
  ///   - [eventName]: Name of the event to check.
  bool hasListeners(String eventName);

  /// Pushes an event for delayed processing.
  ///
  /// Platform-specific: Supports delayed event processing.
  ///
  /// Parameters:
  ///   - [event]: Name of the event.
  ///   - [payload]: Optional event payload.
  void push(String event, [dynamic payload]);

  /// Flushes delayed events.
  ///
  /// Platform-specific: Processes delayed events immediately.
  ///
  /// Parameters:
  ///   - [event]: Name of the event to flush.
  Future<void> flush(String event);

  /// Subscribes an event subscriber.
  ///
  /// Laravel-compatible: Registers event subscribers, but with platform-specific
  /// dynamic typing for more flexible subscription handling.
  ///
  /// Parameters:
  ///   - [subscriber]: The subscriber to register.
  void subscribe(dynamic subscriber);

  /// Waits for an event to occur.
  ///
  /// Platform-specific: Provides event waiting functionality.
  ///
  /// Parameters:
  ///   - [event]: Event to wait for.
  ///   - [payload]: Optional payload to dispatch.
  Future<dynamic> until(dynamic event, [dynamic payload]);

  /// Dispatches an event.
  ///
  /// Laravel-compatible: Dispatches events, with platform-specific
  /// extensions for halting and payload handling.
  ///
  /// Parameters:
  ///   - [event]: Event to dispatch.
  ///   - [payload]: Optional event payload.
  ///   - [halt]: Whether to halt after first handler.
  Future<dynamic> dispatch(dynamic event, [dynamic payload, bool? halt]);

  /// Gets registered listeners.
  ///
  /// Laravel-compatible: Retrieves event listeners.
  ///
  /// Parameters:
  ///   - [eventName]: Name of the event.
  List<Function> getListeners(String eventName);

  /// Removes an event listener.
  ///
  /// Laravel-compatible: Removes event listeners.
  ///
  /// Parameters:
  ///   - [event]: Event to remove listener for.
  void forget(String event);

  /// Removes pushed event listeners.
  ///
  /// Platform-specific: Cleans up delayed event listeners.
  void forgetPushed();

  /// Sets queue resolver.
  ///
  /// Laravel-compatible: Configures queue integration.
  ///
  /// Parameters:
  ///   - [resolver]: Queue resolver function.
  void setQueueResolver(Function resolver);

  /// Sets transaction manager resolver.
  ///
  /// Laravel-compatible: Configures transaction integration.
  ///
  /// Parameters:
  ///   - [resolver]: Transaction manager resolver function.
  void setTransactionManagerResolver(Function resolver);

  /// Gets raw event listeners.
  ///
  /// Platform-specific: Provides access to raw listener data.
  Map<String, List<Function>> getRawListeners();
}

/// Contract for event subscribers.
///
/// Laravel-compatible: Defines how event subscribers register
/// their event handling methods.
@sealed
abstract class EventSubscriberContract {
  /// Subscribes to events.
  ///
  /// Laravel-compatible: Returns event handler mappings.
  ///
  /// Returns a map of event types to handler functions.
  Map<Type, Function> subscribe();
}

/// Marker interface for broadcastable events.
///
/// Laravel-compatible: Events implementing this interface will be broadcast
/// across the application.
@sealed
abstract class ShouldBroadcast {
  /// Gets channels to broadcast on.
  ///
  /// Laravel-compatible: Defines broadcast channels.
  List<String> broadcastOn();

  /// Gets event name for broadcasting.
  ///
  /// Laravel-compatible: Defines broadcast event name.
  String broadcastAs() => runtimeType.toString();

  /// Gets broadcast data.
  ///
  /// Laravel-compatible: Defines broadcast payload.
  Map<String, dynamic> get broadcastWith => {};
}

/// Marker interface for queueable events.
///
/// Laravel-compatible: Events implementing this interface will be processed
/// through the queue system.
@sealed
abstract class ShouldQueue {
  /// Gets the queue name.
  ///
  /// Laravel-compatible: Defines target queue.
  String get queue => 'default';

  /// Gets the processing delay.
  ///
  /// Laravel-compatible: Defines queue delay.
  Duration? get delay => null;

  /// Gets maximum retry attempts.
  ///
  /// Laravel-compatible: Defines retry limit.
  int get tries => 1;
}

/// Marker interface for encrypted events.
///
/// Laravel-compatible: Events implementing this interface will be encrypted
/// before being stored or transmitted.
@sealed
abstract class ShouldBeEncrypted {
  /// Whether the event should be encrypted.
  ///
  /// Laravel-compatible: Controls event encryption.
  bool get shouldBeEncrypted => true;
}

/// Marker interface for events that should dispatch after commit.
///
/// Laravel-compatible: Events implementing this interface will only be dispatched
/// after the current database transaction commits.
@sealed
abstract class ShouldDispatchAfterCommit {
  /// Whether to dispatch after commit.
  ///
  /// Laravel-compatible: Controls transaction-based dispatch.
  bool get afterCommit => true;
}
