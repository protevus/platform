import '../notification.dart';

/// Event fired when a notification is ready to be broadcast.
class BroadcastNotificationCreated {
  /// The notifiable entity.
  final dynamic notifiable;

  /// The notification instance.
  final Notification notification;

  /// The notification data.
  final Map<String, dynamic> data;

  /// The queue connection to use.
  String? connection;

  /// The queue to use.
  String? queue;

  /// Creates a new broadcast notification created event.
  ///
  /// [notifiable] The entity receiving the notification
  /// [notification] The notification being broadcast
  /// [data] The notification data to broadcast
  BroadcastNotificationCreated(
    this.notifiable,
    this.notification,
    this.data,
  );

  /// Set the queue connection for the broadcast.
  ///
  /// Returns this instance for method chaining.
  BroadcastNotificationCreated onConnection(String connection) {
    this.connection = connection;
    return this;
  }

  /// Set the queue name for the broadcast.
  ///
  /// Returns this instance for method chaining.
  BroadcastNotificationCreated onQueue(String queue) {
    this.queue = queue;
    return this;
  }

  /// Get the channels the event should broadcast on.
  ///
  /// This matches Laravel's broadcastOn() method but returns a List instead
  /// of a Channel instance since we're using a different broadcasting system.
  List<String> broadcastOn() {
    if (notifiable == null) return [];

    try {
      final channels = notification.broadcastOn(notifiable);
      return channels.map((channel) => channel.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get the broadcast data.
  Map<String, dynamic> broadcastWith() {
    return {
      'id': notification.id,
      'type': notification.runtimeType.toString(),
      'data': data,
      'notifiable_id': _getNotifiableId(),
      'notifiable_type': notifiable.runtimeType.toString(),
    };
  }

  /// Get the notifiable entity ID.
  dynamic _getNotifiableId() {
    try {
      return notifiable.getKey();
    } catch (_) {
      return null;
    }
  }
}
