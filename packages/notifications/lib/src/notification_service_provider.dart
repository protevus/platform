import 'package:illuminate_events/events.dart';
import 'package:illuminate_mail/mail.dart';
import 'package:illuminate_database/eloquent.dart';

import 'channels/broadcast_channel.dart';
import 'channels/database_channel.dart';
import 'channels/mail_channel.dart';
import 'notification_factory.dart';
import 'notification_manager.dart';

/// Service provider for the notification system.
class NotificationServiceProvider {
  /// The notification factory instance.
  final NotificationFactory _factory;

  /// The mail manager instance.
  final MailManager _mailManager;

  /// The database connection instance.
  final Connection _database;

  /// The event dispatcher instance.
  final EventDispatcher _events;

  /// Creates a new notification service provider.
  ///
  /// [factory] The notification factory for creating notifications
  /// [mailManager] The mail manager for sending emails
  /// [database] The database connection for storing notifications
  /// [events] The event dispatcher for broadcasting notifications
  NotificationServiceProvider({
    required NotificationFactory factory,
    required MailManager mailManager,
    required Connection database,
    required EventDispatcher events,
  })  : _factory = factory,
        _mailManager = mailManager,
        _database = database,
        _events = events;

  /// Register the notification services.
  NotificationManager register() {
    final manager = NotificationManager(_factory, _events);

    // Register the default channels
    manager
      ..registerChannel(MailChannel(_mailManager))
      ..registerChannel(DatabaseChannel(_database))
      ..registerChannel(BroadcastChannel(_events));

    return manager;
  }

  /// Boot the notification services.
  void boot(NotificationManager manager) {
    // Listen for broadcast notifications
    _events.listen(
      'Illuminate\\Notifications\\Events\\BroadcastNotificationCreated',
      (event, payload) {
        // Handle broadcast notifications
        // This would typically integrate with your WebSocket/broadcasting system
      },
    );
  }
}
