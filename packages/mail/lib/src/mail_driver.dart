import 'dart:async';

import 'package:meta/meta.dart';

import 'address.dart';
import 'attachment.dart';
import 'exceptions.dart';

/// Base interface for all mail drivers.
abstract class MailDriver {
  /// Sends an email message.
  ///
  /// Returns a [Future] that completes when the message is sent.
  /// Throws [MailException] if sending fails.
  Future<void> send({
    required List<Address> to,
    required List<Address> from,
    List<Address>? cc,
    List<Address>? bcc,
    List<Address>? replyTo,
    required String subject,
    String? html,
    String? text,
    List<Attachment>? attachments,
    Map<String, String>? headers,
    Map<String, String>? metadata,
    List<String>? tags,
  });

  /// Validates the driver configuration.
  ///
  /// Returns true if the configuration is valid, false otherwise.
  @protected
  bool validateConfig();

  /// Closes any resources used by the driver.
  Future<void> close();
}

/// Configuration for mail drivers.
abstract class MailConfig {
  /// Creates a new mail configuration.
  const MailConfig();

  /// Validates the configuration.
  ///
  /// Returns true if the configuration is valid, false otherwise.
  bool validate();

  /// Converts the configuration to a map.
  Map<String, dynamic> toMap();
}
