import 'package:platform_notifications/notifications.dart';
import 'example_dependencies.dart';

/// Example notification sent to welcome new users.
class WelcomeNotification extends Notification {
  /// The user's name.
  final String name;

  /// Creates a new welcome notification.
  WelcomeNotification(this.name);

  @override
  List<String> via(dynamic notifiable) => ['mail', 'database'];

  @override
  Future<Map<String, dynamic>> toMail(dynamic notifiable) async {
    final message = MailMessage()
      ..setSubject('Welcome to the Platform!')
      ..setView('emails.welcome')
      ..withData({
        'name': name,
        'url': 'https://example.com/dashboard',
      });

    return message.data();
  }

  @override
  Future<Map<String, dynamic>> toDatabase(dynamic notifiable) async {
    return {
      'name': name,
      'message': 'Welcome to the platform!',
      'action_url': 'https://example.com/dashboard',
    };
  }

  @override
  String? databaseType(dynamic notifiable) => 'welcome';

  @override
  bool get shouldQueue => true;

  @override
  String? get queueConnection => 'redis';

  @override
  String? get queueName => 'notifications';

  @override
  int get maxAttempts => 3;

  @override
  Duration get retryAfter => const Duration(minutes: 5);
}

/// Example usage:
void main() async {
  // Set up dependencies (normally done by your DI container)
  final factory = YourNotificationFactory();
  final mailManager = YourMailManager();
  final database = YourDatabaseConnection();
  final events = YourEventDispatcher();

  // Create and configure the notification system
  final provider = NotificationServiceProvider(
    factory: factory,
    mailManager: mailManager,
    database: database,
    events: events,
  );

  final notifications = provider.register();
  provider.boot(notifications);

  // Create and send a notification
  final user = YourUserModel(); // The notifiable entity
  final notification = WelcomeNotification('John Doe');

  await notifications.send(notification, user);
}

// Example notifiable entity
class YourUserModel {
  String get email => 'john@example.com';

  String? routeNotificationForMail(Notification notification) => email;

  Future<String> getKey() async => '123';

  String getMorphClass() => 'users';
}

// Example factory implementation
class YourNotificationFactory implements NotificationFactory {
  @override
  Notification createFromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'WelcomeNotification':
        return WelcomeNotification(json['data']['name'] as String);
      default:
        throw UnimplementedError('Unknown notification type: ${json['type']}');
    }
  }

  @override
  Notification clone(Notification notification) {
    if (notification is WelcomeNotification) {
      return WelcomeNotification(notification.name);
    }
    throw UnimplementedError(
        'Unknown notification type: ${notification.runtimeType}');
  }
}
