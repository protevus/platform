import 'package:platform_events/events.dart';

/// Example event subscriber class
class UserEventSubscriber {
  Map<String, dynamic> subscribe(EventDispatcher events) {
    return {
      'UserRegistered': 'handleUserRegistration',
      'UserDeleted': 'handleUserDeletion',
      'user.login': ['handleUserLogin', 'logLoginAttempt'],
    };
  }

  void handleUserRegistration(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling registration for: $email');
    print('Sending welcome email...');
  }

  void handleUserDeletion(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling deletion for: $email');
    print('Cleaning up user data...');
  }

  void handleUserLogin(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling login for: $email');
    print('Updating last login timestamp...');
  }

  void logLoginAttempt(List<dynamic> data) {
    final email = data[0] as String;
    print('Logging login attempt for: $email');
  }
}

/// Example queued event handler
class SendWelcomeEmail {
  void handle(List<dynamic> data) {
    final email = data[0] as String;
    print('Sending welcome email to: $email');
  }

  void failed(List<dynamic> data, Object error) {
    final email = data[0] as String;
    print('Failed to send welcome email to: $email');
    print('Error: $error');
  }
}

void main() {
  final dispatcher = EventDispatcher();

  // Register the subscriber
  dispatcher.subscribe(UserEventSubscriber());

  // Register a queued event listener
  final welcomeEmail = QueuedClosure((String email) {
    print('Queued: Sending welcome email to $email');
  }).onQueue('emails').withDelay(Duration(minutes: 5)).catchError((error) {
    print('Failed to send welcome email: $error');
  });

  dispatcher.listen('UserRegistered', welcomeEmail.resolve());

  // Dispatch some events
  print('\nRegistering user:');
  dispatcher.dispatch('UserRegistered', ['jane@example.com']);

  print('\nUser logging in:');
  dispatcher.dispatch('user.login', ['jane@example.com']);

  print('\nDeleting user:');
  dispatcher.dispatch('UserDeleted', ['jane@example.com']);

  // Example of serializable closure
  final greetUser = SerializableClosure.create(
    (String name) => 'Hello $name',
    'greet-user',
    () => (String name) => 'Hello $name',
  );

  // Later, reconstruct and use the closure
  final reconstructed = SerializableClosure.fromJson({
    'identifier': 'greet-user',
  });

  print('\nGreeting from reconstructed closure:');
  print((reconstructed as Function).call('Jane'));
}
