import 'dart:async';

import 'package:illuminate_database/query_builder.dart';

import '../notification.dart';
import 'notification_channel.dart';

/// Channel for storing notifications in a database.
class DatabaseChannel implements NotificationChannel {
  /// The table to store notifications in.
  final String table;

  /// Creates a new database channel instance.
  ///
  /// [table] The table to store notifications in (defaults to 'notifications')
  DatabaseChannel({this.table = 'notifications'});

  @override
  String get id => 'database';

  @override
  bool shouldSend(dynamic notification, dynamic notifiable) {
    if (notification == null || notifiable == null) return false;

    try {
      // Check if notifiable has a database route
      final route = notifiable.routeNotificationForDatabase(notification);
      return route != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> send(dynamic notification, dynamic notifiable) async {
    final data = await _getData(notification, notifiable);

    await QueryBuilder.table(table).insert({
      'id': notification.id,
      'type': _getType(notification, notifiable),
      'notifiable_type': notifiable.runtimeType.toString(),
      'notifiable_id': await _getNotifiableId(notifiable),
      'data': data,
      'read_at': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  void validateNotification(dynamic notification, dynamic notifiable) {
    if (notification is! Notification) {
      throw FormatException(
          'Invalid notification type: ${notification.runtimeType}');
    }

    if (!_hasRequiredMethods(notifiable)) {
      throw FormatException(
        'Notifiable must implement routeNotificationForDatabase() and getMorphClass()',
      );
    }
  }

  /// Get the notification type.
  String _getType(dynamic notification, dynamic notifiable) {
    if (notification is Notification) {
      try {
        // Check if notification has custom database type
        final type = notification.databaseType(notifiable);
        if (type != null) return type;
      } catch (_) {
        // Fall back to runtime type if method doesn't exist
      }
    }
    return notification.runtimeType.toString();
  }

  /// Get the notification data.
  Future<Map<String, dynamic>> _getData(
    dynamic notification,
    dynamic notifiable,
  ) async {
    if (notification is Notification) {
      try {
        final data = await notification.toDatabase(notifiable);
        return data is Map<String, dynamic> ? data : {'data': data};
      } catch (_) {
        try {
          return notification.toJson();
        } catch (_) {
          throw FormatException(
            'Notification must implement toDatabase() or toJson()',
          );
        }
      }
    }
    throw FormatException(
        'Invalid notification type: ${notification.runtimeType}');
  }

  /// Get the notifiable entity's primary key.
  Future<dynamic> _getNotifiableId(dynamic notifiable) async {
    try {
      return await notifiable.getKey();
    } catch (_) {
      throw FormatException('Notifiable must implement getKey()');
    }
  }

  /// Check if the notifiable entity has the required methods.
  bool _hasRequiredMethods(dynamic notifiable) {
    return notifiable != null &&
        notifiable.routeNotificationForDatabase != null &&
        notifiable.getMorphClass != null;
  }
}
