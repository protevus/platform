# Platform Events Package

A Laravel-compatible event dispatcher implementation for Dart.

## Overview

This package provides a complete implementation of Laravel's Events system in Dart, including support for:

- Event registration and dispatching
- Wildcard event listeners
- Event subscribers
- Queued listeners and closures
- Broadcasting support
- Database transaction awareness

## Usage Examples

### Basic Event Handling

```dart
final dispatcher = EventDispatcher();

// Register a simple event listener
dispatcher.listen('UserRegistered', (event, data) {
  final email = data[0] as String;
  print('New user registered: $email');
});

// Register a wildcard listener
dispatcher.listen('user.*', (event, data) {
  print('User event occurred: $event');
  print('Data: $data');
});

// Dispatch an event
dispatcher.dispatch('UserRegistered', ['john@example.com']);
```

### Event Subscribers

```dart
class UserEventSubscriber {
  Map<String, dynamic> subscribe(EventDispatcher events) {
    return {
      'UserRegistered': 'handleUserRegistration',
      'UserDeleted': 'handleUserDeletion',
    };
  }

  void handleUserRegistration(List<dynamic> data) {
    final email = data[0] as String;
    print('Handling registration for: $email');
  }

  void handleUserDeletion(List<dynamic> data) {
    final email = data[0] as String;
    print('Handling deletion for: $email');
  }
}

dispatcher.subscribe(UserEventSubscriber());
```

### Queued Events

```dart
final welcomeEmail = QueuedClosure((String email) {
  print('Sending welcome email to $email');
})
.onQueue('emails')
.withDelay(Duration(minutes: 5))
.catchError((error) {
  print('Failed to send welcome email: $error');
});

dispatcher.listen('UserRegistered', welcomeEmail.resolve());
```

### Broadcasting Events

```dart
class UserLoggedIn implements ShouldBroadcast {
  final String email;
  final DateTime timestamp;

  UserLoggedIn(this.email) : timestamp = DateTime.now();

  @override
  List<String> broadcastOn() => ['user-events'];

  @override
  String broadcastAs() => 'user.logged_in';

  @override
  Map<String, dynamic> broadcastWith() => {
    'email': email,
    'timestamp': timestamp.toIso8601String(),
  };
}

// Event will be automatically broadcasted when dispatched
dispatcher.dispatch(UserLoggedIn('john@example.com'));
```

### Dependency Injection

```dart
final container = Container(MirrorsReflector());

// Register event dispatcher
container.registerSingleton<EventDispatcherContract>(
  EventDispatcher(container),
);

// Register services that use events
container.registerFactory<AuthenticationService>((container) {
  return AuthenticationService(
    container.make<EventDispatcherContract>()!,
  );
});
```

## More Examples

Check out the `example` directory for complete examples:

- `basic_events.dart` - Basic event handling and wildcard listeners
- `subscribers_and_queues.dart` - Event subscribers and queued events
- `di_and_broadcasting.dart` - Broadcasting events with dependency injection
- `subscriber_with_di.dart` - Event subscribers with dependency injection and testing

## API Differences from Laravel

The main difference from Laravel's implementation is in how closures are serialized. Due to Dart's reflection limitations:

- Laravel can serialize any closure by extracting its source code and scope
- Our implementation requires closures to be registered with a unique identifier and factory function

Example of serializable closure:

```dart
final greetUser = SerializableClosure.create(
  (String name) => 'Hello $name',
  'greet-user',
  () => (String name) => 'Hello $name',
);

// Later, reconstruct and use the closure
final reconstructed = SerializableClosure.fromJson({
  'identifier': 'greet-user',
});
```

## Dependencies

- platform_container: IoC container support
- platform_contracts: Core interfaces
- platform_macroable: Macro support
- platform_support: Utility functions
- platform_queue: *Coming soon* - Queue system integration
