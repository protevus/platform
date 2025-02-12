import 'dart:async';

/// Interface for notification channels.
///
/// All notification channels (email, SMS, database, etc.) must implement this interface.
abstract class NotificationChannel {
  /// Sends the notification to the specified notifiable entity.
  ///
  /// [notification] The notification instance to be sent
  /// [notifiable] The entity receiving the notification
  Future<void> send(dynamic notification, dynamic notifiable);

  /// The unique identifier for this channel.
  ///
  /// This should match the channel name used in [Notification.via].
  /// For example: 'mail', 'sms', 'database', etc.
  String get id;

  /// Validates that the notification contains all required data for this channel.
  ///
  /// Throws [FormatException] if the notification data is invalid.
  void validateNotification(dynamic notification, dynamic notifiable) {
    // Default implementation does no validation
  }

  /// Determines if this channel should handle the given notification.
  ///
  /// By default, checks if the notification's [via] list contains this channel's [id].
  bool shouldSend(dynamic notification, dynamic notifiable) {
    if (notification == null) return false;

    try {
      final channels = notification.via as List<String>;
      return channels.contains(id);
    } catch (e) {
      return false;
    }
  }
}

/// Exception thrown when a notification channel encounters an error.
class NotificationChannelException implements Exception {
  final String message;
  final dynamic originalError;

  NotificationChannelException(this.message, [this.originalError]);

  @override
  String toString() =>
      'NotificationChannelException: $message${originalError != null ? ' ($originalError)' : ''}';
}
