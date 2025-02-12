import 'dart:async';

import 'package:illuminate_events/events.dart';
import 'package:illuminate_queue/queue.dart';

import 'events/notification_events.dart';
import 'notification.dart';
import 'notification_manager.dart';

/// Handles the sending of notifications through various channels.
class NotificationSender {
  /// The notification manager instance.
  final NotificationManager _manager;

  /// The queue manager for handling queued notifications.
  final QueueManager? _queueManager;

  /// The locale to use when sending notifications.
  final String? locale;

  /// The event dispatcher for notification events.
  final EventDispatcher _events;

  /// Creates a new notification sender instance.
  NotificationSender(
    this._manager,
    this._queueManager,
    this._events, {
    this.locale,
  });

  /// Send a notification immediately.
  ///
  /// [notifiables] The entities to receive the notification
  /// [notification] The notification to send
  /// [channels] Optional list of specific channels to use
  Future<void> send(
    dynamic notifiables,
    Notification notification, [
    List<String>? channels,
  ]) async {
    final targets = _formatNotifiables(notifiables);
    final originalNotification = notification;

    for (final notifiable in targets) {
      // Clone notification for each notifiable to prevent state sharing
      final notification = _cloneNotification(originalNotification);

      // Get channels to use for this notification
      final viaChannels = channels ?? notification.via(notifiable);
      if (viaChannels.isEmpty) continue;

      // Set notification locale
      if (locale != null) {
        notification.locale = locale;
      }

      // Send through each channel
      for (final channelId in viaChannels) {
        final channel = _manager.channel(channelId);
        if (channel == null) {
          print('Warning: Channel $channelId not found');
          continue;
        }

        if (!channel.shouldSend(notification, notifiable)) {
          continue;
        }

        try {
          channel.validateNotification(notification, notifiable);

          // Fire sending event
          final sendingEvent = NotificationSending(
            notifiable,
            notification,
            channelId,
          );
          _events.dispatch(sendingEvent, [sendingEvent]);

          // Send notification
          await channel.send(notification, notifiable);

          // Fire sent event
          final sentEvent = NotificationSent(
            notifiable,
            notification,
            channelId,
            null, // No response since send() returns void
          );
          _events.dispatch(sentEvent, [sentEvent]);
        } catch (e, stackTrace) {
          // Fire failed event
          final failedEvent = NotificationFailed(
            notifiable,
            notification,
            channelId,
            e,
            stackTrace,
          );
          _events.dispatch(failedEvent, [failedEvent]);
          rethrow;
        }
      }
    }
  }

  /// Queue a notification for sending.
  ///
  /// [notifiables] The entities to receive the notification
  /// [notification] The notification to send
  /// [channels] Optional list of specific channels to use
  Future<void> queue(
    dynamic notifiables,
    Notification notification, [
    List<String>? channels,
  ]) async {
    if (_queueManager == null) {
      throw StateError('Queue manager not configured');
    }

    final targets = _formatNotifiables(notifiables);
    final originalNotification = notification;

    for (final notifiable in targets) {
      final notification = _cloneNotification(originalNotification);
      final viaChannels = channels ?? notification.via(notifiable);

      if (viaChannels.isEmpty) continue;

      if (locale != null) {
        notification.locale = locale;
      }

      // Create queue job for each channel
      for (final channelId in viaChannels) {
        final channel = _manager.channel(channelId);
        if (channel == null) continue;

        if (!channel.shouldSend(notification, notifiable)) {
          continue;
        }

        // Push notification job to queue
        await _queueManager.connection(notification.queueConnection).push(
              'send_notification',
              data: {
                'notification': notification.toJson(),
                'notifiable': notifiable,
                'channel': channelId,
                'max_attempts': notification.maxAttempts,
                'retry_after': notification.retryAfter.inSeconds,
              },
              queue: notification.queueName,
            );
      }
    }
  }

  /// Format notifiables into a list.
  List<dynamic> _formatNotifiables(dynamic notifiables) {
    if (notifiables is List) return notifiables;
    if (notifiables is Set) return notifiables.toList();
    return [notifiables];
  }

  /// Create a clone of a notification using the factory.
  ///
  /// This ensures each notifiable gets its own notification instance.
  Notification _cloneNotification(Notification original) {
    return _manager.factory.clone(original);
  }
}
