import '../notification.dart';

/// Event fired before a notification is sent.
class NotificationSending {
  /// The notifiable entity receiving the notification.
  final dynamic notifiable;

  /// The notification instance.
  final Notification notification;

  /// The channel being used.
  final String channel;

  /// Creates a new notification sending event.
  NotificationSending(this.notifiable, this.notification, this.channel);
}

/// Event fired after a notification is sent.
class NotificationSent {
  /// The notifiable entity that received the notification.
  final dynamic notifiable;

  /// The notification instance.
  final Notification notification;

  /// The channel used.
  final String channel;

  /// The response from the channel, if any.
  final dynamic response;

  /// Creates a new notification sent event.
  NotificationSent(
    this.notifiable,
    this.notification,
    this.channel,
    this.response,
  );
}

/// Event fired when a notification fails to send.
class NotificationFailed {
  /// The notifiable entity that should have received the notification.
  final dynamic notifiable;

  /// The notification instance.
  final Notification notification;

  /// The channel that failed.
  final String channel;

  /// The error that occurred.
  final Object error;

  /// The stack trace for the error.
  final StackTrace? stackTrace;

  /// Creates a new notification failed event.
  NotificationFailed(
    this.notifiable,
    this.notification,
    this.channel,
    this.error, [
    this.stackTrace,
  ]);
}
