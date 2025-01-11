import 'notification.dart';

/// Factory for creating and cloning notifications.
abstract class NotificationFactory {
  /// Create a new notification instance from JSON data.
  Notification createFromJson(Map<String, dynamic> json);

  /// Create a clone of an existing notification.
  Notification clone(Notification notification);
}

/// Exception thrown when notification creation fails.
class NotificationCreationException implements Exception {
  final String message;
  final dynamic originalError;

  NotificationCreationException(this.message, [this.originalError]);

  @override
  String toString() =>
      'NotificationCreationException: $message${originalError != null ? ' ($originalError)' : ''}';
}
