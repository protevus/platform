import 'dart:async';
import 'dart:typed_data';

import 'package:illuminate_mail/mail.dart';

import '../messages/mail_message.dart';
import '../notification.dart';
import 'notification_channel.dart';

/// Channel for sending notifications via email.
class MailChannel implements NotificationChannel {
  /// The mail manager instance.
  final MailManager _manager;

  /// Creates a new mail channel instance.
  ///
  /// [manager] The mail manager to use for sending emails
  MailChannel(this._manager);

  @override
  String get id => 'mail';

  @override
  bool shouldSend(dynamic notification, dynamic notifiable) {
    if (notification == null || notifiable == null) return false;

    try {
      // Check if notifiable has a mail route
      final address = notifiable.routeNotificationForMail(notification);
      return address != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> send(dynamic notification, dynamic notifiable) async {
    final message = await _buildMessage(notification, notifiable);
    if (message == null) return;

    final to = _getRecipients(notifiable, notification);
    if (to.isEmpty) return;

    await _manager.send(
      to: to,
      from: _getFrom(message),
      cc: _getAddresses(message.cc),
      bcc: _getAddresses(message.bcc),
      replyTo: _getAddresses(message.replyTo),
      subject: message.subject ?? _getDefaultSubject(notification),
      html: message.view,
      text: message.markdown,
      attachments: _getAttachments(message),
      headers: null, // TODO: Support custom headers
      metadata: message.metadata,
      tags: message.tags,
      priority: message.priority,
    );
  }

  @override
  void validateNotification(dynamic notification, dynamic notifiable) {
    if (notification is! Notification) {
      throw FormatException(
        'Invalid notification type: ${notification.runtimeType}',
      );
    }

    if (!_hasRequiredMethods(notifiable)) {
      throw FormatException(
        'Notifiable must implement routeNotificationForMail()',
      );
    }
  }

  /// Build the mail message from the notification.
  Future<MailMessage?> _buildMessage(
    dynamic notification,
    dynamic notifiable,
  ) async {
    try {
      final data = await notification.toMail(notifiable);
      if (data is MailMessage) return data;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get the recipients for the notification.
  List<Address> _getRecipients(dynamic notifiable, dynamic notification) {
    try {
      final address = notifiable.routeNotificationForMail(notification);
      if (address == null) return [];

      if (address is String) {
        return [Address(address)];
      }

      if (address is List) {
        return address.map((addr) {
          if (addr is String) return Address(addr);
          if (addr is Map) {
            return Address(
              addr['email'] as String,
              addr['name'] as String?,
            );
          }
          throw FormatException('Invalid address format: $addr');
        }).toList();
      }

      throw FormatException('Invalid address format: $address');
    } catch (_) {
      return [];
    }
  }

  /// Get the from addresses from the message.
  List<Address> _getFrom(MailMessage message) {
    if (message.from == null) return [];
    return [
      Address(
        message.from![0],
        message.from!.length > 1 ? message.from![1] : null,
      ),
    ];
  }

  /// Convert address arrays to Address objects.
  List<Address> _getAddresses(List<List<String>> addresses) {
    return addresses.map((addr) {
      return Address(addr[0], addr.length > 1 ? addr[1] : null);
    }).toList();
  }

  /// Convert message attachments to the mail package format.
  List<Attachment> _getAttachments(MailMessage message) {
    final attachments = <Attachment>[];

    for (final attachment in message.attachments) {
      // TODO: Read file content and determine MIME type
      attachments.add(Attachment(
        filename: attachment['file'] as String,
        content: Uint8List(0), // Placeholder until file reading is implemented
        mimeType: attachment['options']?['mimeType'] as String?,
        isInline: attachment['options']?['isInline'] as bool? ?? false,
        contentId: attachment['options']?['contentId'] as String?,
        headers: attachment['options']?['headers'] as Map<String, String>?,
      ));
    }

    for (final attachment in message.rawAttachments) {
      attachments.add(Attachment(
        filename: attachment['name'] as String,
        content: Uint8List.fromList(attachment['data'] as List<int>),
        mimeType: attachment['options']?['mimeType'] as String?,
        isInline: attachment['options']?['isInline'] as bool? ?? false,
        contentId: attachment['options']?['contentId'] as String?,
        headers: attachment['options']?['headers'] as Map<String, String>?,
      ));
    }

    return attachments;
  }

  /// Get a default subject from the notification class name.
  String _getDefaultSubject(dynamic notification) {
    final name = notification.runtimeType.toString();
    // Convert camel case to words with spaces
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])', caseSensitive: true),
          (match) => ' ${match[1]}',
        )
        .trim();
  }

  /// Check if the notifiable entity has the required methods.
  bool _hasRequiredMethods(dynamic notifiable) {
    return notifiable != null && notifiable.routeNotificationForMail != null;
  }
}
