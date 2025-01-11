import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:platform_queue/queue.dart';
import 'package:mustache_template/mustache_template.dart';

/// Base class for all notifications.
abstract class Notification {
  /// Unique identifier for the notification.
  String? id;

  /// The locale to be used when sending the notification.
  String? locale;

  /// Creates a new notification instance.
  Notification();

  /// The channels the notification should be delivered on.
  ///
  /// Override this method to specify which channels to use.
  /// Example: ['mail', 'database', 'sms']
  @protected
  List<String> via(dynamic notifiable) => const ['mail'];

  /// Convert the notification to something JSON serializable.
  ///
  /// This is used when storing the notification in a database or queue.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': runtimeType.toString(),
      'locale': locale,
      'data': {},
    };
  }

  /// Create a notification instance from JSON data.
  ///
  /// This is used when retrieving notifications from a database or queue.
  static Notification fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'Notifications must implement their own fromJson factory',
    );
  }

  /// Set the locale for this notification.
  ///
  /// Returns this instance for method chaining.
  Notification withLocale(String locale) {
    this.locale = locale;
    return this;
  }

  /// Helper method to render templates using Mustache.
  @protected
  String render(String template, [Map<String, dynamic> data = const {}]) {
    final parsed = Template(template, htmlEscapeValues: false);
    return parsed.renderString(data);
  }

  /// Queue configuration for this notification.
  ///
  /// Override these getters to customize queuing behavior.
  @protected
  bool get shouldQueue => false;

  @protected
  String? get queueConnection => null;

  @protected
  String? get queueName => null;

  @protected
  int get maxAttempts => 3;

  @protected
  Duration get retryAfter => const Duration(seconds: 60);

  /// Channel-specific conversion methods.
  /// Implement these in your notification classes as needed.

  /// Convert the notification to an array format.
  ///
  /// This is used as a fallback for channels when specific conversion
  /// methods are not implemented.
  @protected
  Map<String, dynamic> toArray(dynamic notifiable) {
    return toJson();
  }

  /// Get the channels to broadcast this notification on.
  ///
  /// Override this method to specify broadcast channels.
  @protected
  List<String> broadcastOn(dynamic notifiable) => [];

  /// Get the type of the notification for database storage.
  ///
  /// Override this method to customize how the notification is stored.
  @protected
  String? databaseType(dynamic notifiable) => null;

  @protected
  FutureOr<Map<String, dynamic>> toMail(dynamic notifiable) {
    throw UnimplementedError('Notification does not support mail channel');
  }

  @protected
  FutureOr<Map<String, dynamic>> toDatabase(dynamic notifiable) {
    throw UnimplementedError('Notification does not support database channel');
  }

  @protected
  FutureOr<Map<String, dynamic>> toBroadcast(dynamic notifiable) {
    throw UnimplementedError('Notification does not support broadcast channel');
  }

  @protected
  FutureOr<Map<String, dynamic>> toSms(dynamic notifiable) {
    throw UnimplementedError('Notification does not support SMS channel');
  }
}
