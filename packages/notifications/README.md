# Notifications Package

A Laravel-style notification system for Dart, providing a clean and flexible way to send notifications across various channels like email, SMS, database, and more.

## Features

- Channel-based notifications (mail, database, broadcast, etc.)
- Queued notifications
- Template engine for dynamic content
- Localization support
- Event-driven architecture
- Extensible design

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  notifications: ^0.0.1
```

## Usage

### Creating a Notification

```dart
class WelcomeNotification extends Notification {
  final String name;

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
}
```

### Setting Up the Notification System

```dart
final provider = NotificationServiceProvider(
  factory: factory,
  mailManager: mailManager,
  database: database,
  events: events,
);

final notifications = provider.register();
provider.boot(notifications);
```

### Sending Notifications

```dart
// Send to a single user
await notifications.send(WelcomeNotification('John'), user);

// Send to multiple users
await notifications.send(WelcomeNotification('Admin'), [user1, user2]);
```

### Using Templates

```dart
final template = 'Hello {{name}}, welcome to {{platform}}!';
final result = TemplateEngine.render(template, {
  'name': 'John',
  'platform': 'Our Platform',
});
```

### Localization

```dart
final translations = TranslationManager(fallbackLocale: 'en');
translations.loadFromJson('''
{
  "en": {
    "welcome": "Welcome, {{name}}!",
    "goodbye": "Goodbye!"
  },
  "es": {
    "welcome": "¡Bienvenido, {{name}}!",
    "goodbye": "¡Adiós!"
  }
}
''');

// Get translations
final message = translations.get('welcome', 'es'); // "¡Bienvenido, {{name}}!"
```

### Queued Notifications

```dart
class WelcomeNotification extends Notification {
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
```

## Channels

### Mail Channel

Sends notifications via email using your configured mail provider.

```dart
@override
Future<Map<String, dynamic>> toMail(dynamic notifiable) async {
  return MailMessage()
    ..setSubject('Welcome!')
    ..setView('emails.welcome')
    ..withData({'name': 'John'})
    ..data();
}
```

### Database Channel

Stores notifications in your database for displaying in your UI.

```dart
@override
Future<Map<String, dynamic>> toDatabase(dynamic notifiable) async {
  return {
    'message': 'Welcome to the platform!',
    'type': 'welcome',
  };
}
```

### Custom Channels

You can create custom channels by implementing the `NotificationChannel` interface:

```dart
class SmsChannel implements NotificationChannel {
  @override
  String get id => 'sms';

  @override
  Future<void> send(dynamic notification, dynamic notifiable) async {
    // Implement SMS sending logic
  }
}
```

## Events

The notification system fires events during the notification lifecycle:

- `NotificationSending`: Before a notification is sent
- `NotificationSent`: After a notification is sent successfully
- `NotificationFailed`: When a notification fails to send

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
