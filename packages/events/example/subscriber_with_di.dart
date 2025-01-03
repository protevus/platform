import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_events/events.dart';
import 'package:platform_contracts/contracts.dart';

/// Example notification service
class NotificationService {
  void sendEmail(String email, String message) {
    print('Sending email to $email: $message');
  }

  void sendPushNotification(String userId, String message) {
    print('Sending push notification to $userId: $message');
  }
}

/// Example activity logger
class ActivityLogger {
  void log(String activity) {
    print('Activity: $activity [${DateTime.now()}]');
  }
}

/// Example user event subscriber that depends on other services
class UserEventSubscriber {
  final NotificationService _notifications;
  final ActivityLogger _logger;

  UserEventSubscriber(this._notifications, this._logger);

  Map<String, dynamic> subscribe(EventDispatcher events) {
    return {
      'UserRegistered': 'handleUserRegistration',
      'UserLoggedIn': 'handleUserLogin',
      'UserLoggedOut': 'handleUserLogout',
    };
  }

  void handleUserRegistration(List<dynamic> data) {
    final email = data[0] as String;
    _notifications.sendEmail(
      email,
      'Welcome! Your account has been created successfully.',
    );
    _logger.log('New user registered: $email');
  }

  void handleUserLogin(List<dynamic> data) {
    final email = data[0] as String;
    _notifications.sendPushNotification(
      email,
      'New login detected on your account.',
    );
    _logger.log('User logged in: $email');
  }

  void handleUserLogout(List<dynamic> data) {
    final email = data[0] as String;
    _logger.log('User logged out: $email');
  }
}

void main() async {
  // Set up container
  final container = Container(MirrorsReflector());

  // Register services
  container.registerSingleton<NotificationService>(NotificationService());
  container.registerSingleton<ActivityLogger>(ActivityLogger());

  // Register event dispatcher
  final dispatcher = EventDispatcher(container);
  container.registerSingleton<EventDispatcherContract>(dispatcher);

  // Register subscriber with dependencies injected from container
  container.registerFactory<UserEventSubscriber>((container) {
    return UserEventSubscriber(
      container.make<NotificationService>()!,
      container.make<ActivityLogger>()!,
    );
  });

  // Subscribe using container-resolved subscriber
  final subscriber = container.make<UserEventSubscriber>()!;
  dispatcher.subscribe(subscriber);

  // Dispatch some events
  print('\nRegistering user:');
  dispatcher.dispatch('UserRegistered', ['jane@example.com']);

  print('\nUser logging in:');
  dispatcher.dispatch('UserLoggedIn', ['jane@example.com']);

  print('\nUser logging out:');
  dispatcher.dispatch('UserLoggedOut', ['jane@example.com']);

  // Example of using child container for testing
  final testContainer = container.createChild();

  // Override services in child container with test doubles
  testContainer.registerSingleton<NotificationService>(
    NotificationService(), // In real tests, this would be a mock
  );
  testContainer.registerSingleton<ActivityLogger>(
    ActivityLogger(), // In real tests, this would be a mock
  );

  // Create test subscriber with overridden dependencies
  final testSubscriber = testContainer.make<UserEventSubscriber>()!;

  // Create test dispatcher
  final testDispatcher = EventDispatcher(testContainer);
  testDispatcher.subscribe(testSubscriber);

  // Test events will use the overridden services
  print('\nTesting with overridden services:');
  testDispatcher.dispatch('UserRegistered', ['test@example.com']);
}
