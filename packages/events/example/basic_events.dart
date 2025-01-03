import 'package:platform_events/events.dart';

void main() {
  // Create an event dispatcher
  final dispatcher = EventDispatcher();

  // Register a simple event listener
  dispatcher.listen('UserRegistered', (event, data) {
    final email = data[0] as String;
    print('New user registered: $email');
  });

  // Register a wildcard listener for all user events
  dispatcher.listen('user.*', (event, data) {
    print('User event occurred: $event');
    print('Data: $data');
  });

  // Register multiple events for the same listener
  dispatcher.listen(['user.login', 'user.logout'], (event, data) {
    final email = data[0] as String;
    print('User ${event.split('.')[1]}: $email');
  });

  // Dispatch some events
  dispatcher.dispatch('UserRegistered', ['john@example.com']);
  dispatcher.dispatch('user.login', ['john@example.com']);
  dispatcher.dispatch('user.logout', ['john@example.com']);

  // Using until() to get first response
  final response = dispatcher.until('GetUserRole', ['john@example.com']);
  print('User role: $response');

  // Push an event to be fired later
  dispatcher.push('WelcomeEmail', ['john@example.com']);

  // Later, flush the pushed event
  dispatcher.flush('WelcomeEmail');
}
