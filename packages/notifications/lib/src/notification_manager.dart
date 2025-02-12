import 'dart:async';

import 'package:meta/meta.dart';
import 'package:illuminate_events/events.dart';
import 'package:illuminate_queue/queue.dart';

import 'channels/notification_channel.dart';
import 'notification.dart';
import 'notification_factory.dart';
import 'notification_sender.dart';

/// Manages notification channels and handles sending notifications.
class NotificationManager {
  /// The registered notification channels.
  final Map<String, NotificationChannel> _channels = {};

  /// The default channel to use when none is specified.
  String _defaultChannel = 'mail';

  /// The locale to use when sending notifications.
  String? _locale;

  /// The queue manager for handling queued notifications.
  final QueueManager? _queueManager;

  /// The notification factory for creating notification instances.
  final NotificationFactory _factory;

  /// The event dispatcher for notification events.
  final EventDispatcher _events;

  /// Creates a new notification manager instance.
  ///
  /// [factory] The notification factory for creating notification instances
  /// [events] The event dispatcher for notification events
  /// [queueManager] Optional queue manager to enable queued notifications
  NotificationManager(
    this._factory,
    this._events, [
    this._queueManager,
  ]);

  /// Get the notification factory.
  NotificationFactory get factory => _factory;

  /// Register a notification channel.
  ///
  /// [channel] The channel implementation to register
  void registerChannel(NotificationChannel channel) {
    _channels[channel.id] = channel;
  }

  /// Get a channel by its identifier.
  ///
  /// [id] The channel identifier
  /// Returns the channel instance or null if not found
  NotificationChannel? channel(String id) => _channels[id];

  /// Set the default channel.
  ///
  /// [channelId] The identifier of the channel to use as default
  void setDefaultChannel(String channelId) {
    if (!_channels.containsKey(channelId)) {
      throw ArgumentError('Channel $channelId is not registered');
    }
    _defaultChannel = channelId;
  }

  /// Get the default channel identifier.
  String get defaultChannel => _defaultChannel;

  /// Set the locale for notifications.
  ///
  /// [locale] The locale identifier (e.g., 'en-US')
  /// Returns this instance for method chaining
  NotificationManager withLocale(String locale) {
    _locale = locale;
    return this;
  }

  /// Send a notification to the given notifiable entities.
  ///
  /// [notification] The notification to send
  /// [notifiables] The entities to receive the notification
  /// [channels] Optional list of specific channels to use
  Future<void> send(
    Notification notification,
    dynamic notifiables, [
    List<String>? channels,
  ]) async {
    final sender = NotificationSender(
      this,
      _queueManager,
      _events,
      locale: _locale,
    );

    if (notification.shouldQueue && _queueManager != null) {
      await sender.queue(notifiables, notification, channels);
    } else {
      await sender.send(notifiables, notification, channels);
    }
  }

  /// Send a notification immediately, bypassing the queue.
  ///
  /// [notification] The notification to send
  /// [notifiables] The entities to receive the notification
  /// [channels] Optional list of specific channels to use
  Future<void> sendNow(
    Notification notification,
    dynamic notifiables, [
    List<String>? channels,
  ]) async {
    final sender = NotificationSender(
      this,
      _queueManager,
      _events,
      locale: _locale,
    );

    await sender.send(notifiables, notification, channels);
  }

  /// Get all registered channels.
  @visibleForTesting
  Map<String, NotificationChannel> get channels => Map.unmodifiable(_channels);
}
