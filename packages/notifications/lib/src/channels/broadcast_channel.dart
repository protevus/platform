import 'dart:async';

import 'package:platform_events/events.dart';

import '../events/broadcast_notification_created.dart';
import '../messages/broadcast_message.dart';
import '../notification.dart';
import 'notification_channel.dart';

/// Channel for broadcasting notifications.
class BroadcastChannel implements NotificationChannel {
  /// The event dispatcher instance.
  final EventDispatcher _events;

  /// Creates a new broadcast channel instance.
  ///
  /// [events] The event dispatcher to use for broadcasting
  BroadcastChannel(this._events);

  @override
  String get id => 'broadcast';

  @override
  bool shouldSend(dynamic notification, dynamic notifiable) {
    if (notification == null || notifiable == null) return false;

    try {
      // Check if notification has broadcast data
      final data = notification.toBroadcast(notifiable);
      return data != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> send(dynamic notification, dynamic notifiable) async {
    final message = await _getData(notification, notifiable);
    if (message == null) return;

    final event = BroadcastNotificationCreated(
      notifiable,
      notification,
      message is BroadcastMessage ? message.data : message,
    );

    if (message is BroadcastMessage) {
      event
        ..onConnection(message.connection ?? notification.queueConnection)
        ..onQueue(message.queue ?? notification.queueName);
    }

    await _events.dispatch(event);
  }

  @override
  void validateNotification(dynamic notification, dynamic notifiable) {
    if (notification is! Notification) {
      throw FormatException(
        'Invalid notification type: ${notification.runtimeType}',
      );
    }

    if (!_hasRequiredMethods(notification)) {
      throw FormatException(
        'Notification must implement toBroadcast() or toArray()',
      );
    }
  }

  /// Get the data for the notification.
  Future<dynamic> _getData(dynamic notification, dynamic notifiable) async {
    try {
      return await notification.toBroadcast(notifiable);
    } catch (_) {
      try {
        return notification.toArray(notifiable);
      } catch (_) {
        return null;
      }
    }
  }

  /// Check if the notification has the required methods.
  bool _hasRequiredMethods(dynamic notification) {
    try {
      notification.toBroadcast(null);
      return true;
    } catch (_) {
      try {
        notification.toArray(null);
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
