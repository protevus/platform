import 'dart:async';

import 'address.dart';
import 'attachment.dart';
import 'exceptions.dart';
import 'mail_driver.dart';
import 'mailable.dart';

/// Manager class for handling mail operations.
///
/// This class manages mail drivers and provides a high-level interface
/// for sending emails. It supports multiple mail drivers and handles
/// driver configuration and lifecycle.
class MailManager {
  /// The registered mail drivers.
  final Map<String, MailDriver> _drivers = {};

  /// The default driver name.
  final String _defaultDriver;

  /// Creates a new mail manager.
  ///
  /// The [defaultDriver] parameter specifies which driver to use by default.
  MailManager({
    required String defaultDriver,
  }) : _defaultDriver = defaultDriver;

  /// Registers a mail driver.
  ///
  /// The [name] parameter is a unique identifier for the driver.
  /// The [driver] parameter is the driver instance to register.
  void registerDriver(String name, MailDriver driver) {
    _drivers[name] = driver;
  }

  /// Gets a mail driver by name.
  ///
  /// If no name is provided, returns the default driver.
  /// Throws [MailConfigException] if the driver is not found.
  MailDriver driver([String? name]) {
    final driverName = name ?? _defaultDriver;
    final driver = _drivers[driverName];

    if (driver == null) {
      throw MailConfigException('Mail driver "$driverName" not found');
    }

    return driver;
  }

  /// Sends an email using the specified driver.
  ///
  /// If no driver is specified, uses the default driver.
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
    int? priority,
    String? locale,
    String? driverName,
  }) {
    return driver(driverName).send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
    );
  }

  /// Sends a mailable using the specified driver.
  ///
  /// If no driver is specified, uses the default driver.
  Future<void> sendMailable(Mailable mailable, [String? driverName]) {
    return mailable.send(this);
  }

  /// Closes all registered drivers and releases resources.
  Future<void> close() async {
    await Future.wait(
      _drivers.values.map((driver) => driver.close()),
    );
    _drivers.clear();
  }
}

/// Extension methods for sending mail using a specific driver.
extension MailManagerDriverExtension on MailManager {
  /// Sends an email using the SMTP driver.
  Future<void> smtp({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'smtp',
    );
  }

  /// Sends an email using the Mailgun driver.
  Future<void> mailgun({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'mailgun',
    );
  }

  /// Logs an email message instead of sending it.
  ///
  /// This is useful for development and testing.
  Future<void> log({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'log',
    );
  }
}
