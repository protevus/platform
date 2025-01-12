import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../address.dart';
import '../attachment.dart';
import '../exceptions.dart';
import '../mail_driver.dart';

/// Configuration for Mailgun mail driver.
class MailgunConfig extends MailConfig {
  /// The Mailgun API key.
  final String apiKey;

  /// The Mailgun domain.
  final String domain;

  /// The Mailgun API endpoint.
  /// Defaults to 'https://api.mailgun.net/v3'.
  final String endpoint;

  /// Creates a new Mailgun configuration.
  const MailgunConfig({
    required this.apiKey,
    required this.domain,
    this.endpoint = 'https://api.mailgun.net/v3',
  });

  @override
  bool validate() {
    return apiKey.isNotEmpty && domain.isNotEmpty && endpoint.isNotEmpty;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'api_key': apiKey,
      'domain': domain,
      'endpoint': endpoint,
    };
  }
}

/// Mail driver implementation for Mailgun.
class MailgunDriver implements MailDriver {
  /// The Mailgun configuration.
  final MailgunConfig config;

  /// The HTTP client.
  final http.Client _client;

  /// Creates a new Mailgun driver.
  ///
  /// The [client] parameter is optional and primarily used for testing.
  /// If not provided, a new HTTP client will be created.
  MailgunDriver(this.config, {http.Client? client})
      : _client = client ?? http.Client() {
    if (!config.validate()) {
      throw MailConfigException('Invalid Mailgun configuration');
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
    try {
      final uri = Uri.parse('${config.endpoint}/${config.domain}/messages');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('api:${config.apiKey}'))}';

      // Required fields
      request.fields['to'] = to.map((a) => a.toString()).join(',');
      request.fields['from'] = from.first.toString();
      request.fields['subject'] = subject;

      // Optional fields
      if (html != null) {
        request.fields['html'] = html;
      }
      if (text != null) {
        request.fields['text'] = text;
      }
      if (cc != null && cc.isNotEmpty) {
        request.fields['cc'] = cc.map((a) => a.toString()).join(',');
      }
      if (bcc != null && bcc.isNotEmpty) {
        request.fields['bcc'] = bcc.map((a) => a.toString()).join(',');
      }
      if (replyTo != null && replyTo.isNotEmpty) {
        request.fields['h:Reply-To'] =
            replyTo.map((a) => a.toString()).join(',');
      }

      // Headers
      if (headers != null) {
        for (final entry in headers.entries) {
          request.fields['h:${entry.key}'] = entry.value;
        }
      }

      // Metadata (custom variables in Mailgun)
      if (metadata != null) {
        for (final entry in metadata.entries) {
          request.fields['v:${entry.key}'] = entry.value;
        }
      }

      // Tags
      if (tags != null && tags.isNotEmpty) {
        for (final tag in tags) {
          request.fields['o:tag'] = tag;
        }
      }

      // Attachments
      if (attachments != null) {
        for (final attachment in attachments) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'attachment',
              attachment.content,
              filename: attachment.filename,
              contentType: MediaType.parse(attachment.mimeType),
            ),
          );
        }
      }

      final response = await _client.send(request);
      final body = await response.stream.bytesToString();

      if (response.statusCode >= 400) {
        throw MailSendException(
          'Failed to send email via Mailgun: ${response.statusCode}\n$body',
        );
      }
    } catch (e) {
      if (e is MailSendException) {
        rethrow;
      }
      throw MailDriverException(
        'Mailgun driver error',
        e,
      );
    }
  }

  @override
  Future<void> close() async {
    _client.close();
  }
}
