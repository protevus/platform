import 'dart:async';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart' show SmtpServer;

import '../address.dart' as mail;
import '../attachment.dart' as mail;
import '../exceptions.dart';
import '../mail_driver.dart';

/// Configuration for SMTP mail driver.
class SmtpConfig extends MailConfig {
  /// The SMTP server host.
  final String host;

  /// The SMTP server port.
  final int port;

  /// The username for authentication.
  final String username;

  /// The password for authentication.
  final String password;

  /// Whether to use SSL/TLS.
  final bool secure;

  /// Whether to allow invalid certificates.
  final bool allowInsecure;

  /// Creates a new SMTP configuration.
  const SmtpConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.secure = true,
    this.allowInsecure = false,
  });

  @override
  bool validate() {
    return host.isNotEmpty &&
        port > 0 &&
        port < 65536 &&
        username.isNotEmpty &&
        password.isNotEmpty;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'secure': secure,
      'allowInsecure': allowInsecure,
    };
  }
}

/// Mail driver implementation for SMTP servers.
class SmtpDriver implements MailDriver {
  /// The SMTP configuration.
  final SmtpConfig config;

  /// The SMTP server instance.
  late final SmtpServer _server;

  /// Creates a new SMTP driver.
  SmtpDriver(this.config) {
    if (!config.validate()) {
      throw MailConfigException('Invalid SMTP configuration');
    }

    _server = SmtpServer(
      config.host,
      port: config.port,
      username: config.username,
      password: config.password,
      ssl: config.secure,
      allowInsecure: config.allowInsecure,
    );
  }

  @override
  bool validateConfig() => config.validate();

  @override
  Future<void> send({
    required List<mail.Address> to,
    required List<mail.Address> from,
    List<mail.Address>? cc,
    List<mail.Address>? bcc,
    List<mail.Address>? replyTo,
    required String subject,
    String? html,
    String? text,
    List<mail.Attachment>? attachments,
    Map<String, String>? headers,
    Map<String, String>? metadata,
    List<String>? tags,
  }) async {
    try {
      final message = Message()
        ..from = _convertAddress(from.first)
        ..recipients.addAll(to.map(_convertAddress))
        ..ccRecipients.addAll(cc?.map(_convertAddress) ?? [])
        ..bccRecipients.addAll(bcc?.map(_convertAddress) ?? [])
        ..subject = subject;

      if (html != null) {
        message.html = html;
      }

      if (text != null) {
        message.text = text;
      }

      if (attachments != null) {
        for (final attachment in attachments) {
          message.attachments.add(
            StreamAttachment(
              Stream.value(attachment.content),
              attachment.mimeType,
              fileName: attachment.filename,
            ),
          );
        }
      }

      if (headers != null) {
        message.headers.addAll(headers);
      }

      final connection = PersistentConnection(_server);
      try {
        await connection.send(message);
      } finally {
        await connection.close();
      }
    } on MailerException catch (e) {
      throw MailSendException(
        'Failed to send email via SMTP',
        cause: e,
      );
    } catch (e) {
      throw MailDriverException(
        'SMTP driver error',
        e,
      );
    }
  }

  /// Converts a [mail.Address] to a mailer [Address].
  Address _convertAddress(mail.Address address) {
    return Address(address.email, address.name ?? '');
  }

  @override
  Future<void> close() async {
    // No cleanup needed for SMTP
  }
}
