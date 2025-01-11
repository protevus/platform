import 'dart:async';
import 'dart:convert';

import '../address.dart';
import '../attachment.dart';
import '../exceptions.dart';
import '../mail_driver.dart';

/// Configuration for log mail driver.
class LogConfig extends MailConfig {
  /// Whether to pretty print the JSON output.
  final bool pretty;

  /// Creates a new log configuration.
  const LogConfig({
    this.pretty = true,
  });

  @override
  bool validate() => true;

  @override
  Map<String, dynamic> toMap() {
    return {
      'pretty': pretty,
    };
  }
}

/// Mail driver implementation that logs emails instead of sending them.
/// Useful for development and testing.
class LogDriver implements MailDriver {
  /// The log configuration.
  final LogConfig config;

  /// Creates a new log driver.
  LogDriver(this.config) {
    if (!config.validate()) {
      throw MailConfigException('Invalid log configuration');
    }
  }

  @override
  bool validateConfig() => config.validate();

  @override
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
  }) async {
    final email = {
      'to': to.map((a) => a.toString()).toList(),
      'from': from.map((a) => a.toString()).toList(),
      if (cc != null && cc.isNotEmpty)
        'cc': cc.map((a) => a.toString()).toList(),
      if (bcc != null && bcc.isNotEmpty)
        'bcc': bcc.map((a) => a.toString()).toList(),
      if (replyTo != null && replyTo.isNotEmpty)
        'reply_to': replyTo.map((a) => a.toString()).toList(),
      'subject': subject,
      if (html != null) 'html': html,
      if (text != null) 'text': text,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments
            .map((a) => {
                  'filename': a.filename,
                  'mime_type': a.mimeType,
                  'size': a.content.length,
                })
            .toList(),
      if (headers != null && headers.isNotEmpty) 'headers': headers,
      if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    };

    final encoder = JsonEncoder.withIndent(config.pretty ? '  ' : null);
    print('📧 Email logged:\n${encoder.convert(email)}');
  }

  @override
  Future<void> close() async {
    // No cleanup needed for log driver
  }
}
