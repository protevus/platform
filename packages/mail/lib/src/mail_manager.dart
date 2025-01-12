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
  /// The registered mail driver factories.
  final Map<String, MailDriver Function(MailManager)> _factories = {};

  /// The cached mail driver instances.
  final Map<String, MailDriver> _drivers = {};

  /// The default driver name.
  String? _defaultDriver;

  /// Creates a new mail manager.
  MailManager();

  /// Extends the mail manager with a new driver.
  ///
  /// The [name] parameter is a unique identifier for the driver.
  /// The [factory] parameter is a function that creates the driver instance.
  void extend(String name, MailDriver Function(MailManager) factory) {
    _factories[name] = factory;
  }

  /// Sets the default driver name.
  ///
  /// Throws [MailConfigException] if the driver is not registered.
  void setDefaultDriver(String name) {
    if (!_factories.containsKey(name)) {
      throw MailConfigException('Mail driver "$name" not found');
    }
    _defaultDriver = name;
  }

  /// Gets the default driver name.
  String getDefaultDriver() {
    return _defaultDriver ?? 'smtp';
  }

  /// Gets a mail driver by name or creates it if it doesn't exist.
  ///
  /// If no name is provided, returns the default driver.
  /// Throws [MailConfigException] if the driver is not registered.
  MailDriver driver([String? name]) {
    final driverName = name ?? getDefaultDriver();

    // Return cached driver if it exists
    if (_drivers.containsKey(driverName)) {
      return _drivers[driverName]!;
    }

    // Create new driver instance
    final factory = _factories[driverName];
    if (factory == null) {
      throw MailConfigException('Mail driver "$driverName" not found');
    }

    final driver = factory(this);
    _drivers[driverName] = driver;
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
