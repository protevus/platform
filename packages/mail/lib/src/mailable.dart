import 'dart:async';

import 'package:mustache_template/mustache_template.dart';

import 'address.dart';
import 'attachment.dart';
import 'exceptions.dart';
import 'mail_manager.dart';

/// Base class for all mailable messages.
///
/// This class provides a fluent interface for building email messages.
/// Extend this class to create custom email types with predefined content
/// and behavior.
abstract class Mailable {
  /// The addresses the message should be sent from.
  final List<Address> _from = [];

  /// The addresses the message should be sent to.
  final List<Address> _to = [];

  /// The addresses that should be CC'd.
  final List<Address> _cc = [];

  /// The addresses that should be BCC'd.
  final List<Address> _bcc = [];

  /// The addresses that should receive replies.
  final List<Address> _replyTo = [];

  /// The subject of the message.
  String? _subject;

  /// The view template for the message.
  String? _template;

  /// The plain text version of the message.
  String? _text;

  /// The HTML version of the message.
  String? _html;

  /// The template data.
  final Map<String, dynamic> _viewData = {};

  /// The attachments for the message.
  final List<Attachment> _attachments = [];

  /// The message headers.
  final Map<String, String> _headers = {};

  /// The message metadata.
  final Map<String, String> _metadata = {};

  /// The message tags.
  final List<String> _tags = [];

  /// The priority of the message (1-5, where 1 is highest).
  int? _priority;

  /// The locale for the message.
  String? _locale;

  /// Creates a new mailable message.
  Mailable();

  /// Builds the mailable content.
  ///
  /// Override this method to define the content and configuration
  /// of your mailable. This is where you set the from address,
  /// subject, template, etc.
  FutureOr<void> build();

  /// Sets the from address.
  Mailable from(String address, [String? name]) {
    _from.add(Address(address, name));
    return this;
  }

  /// Sets the to address(es).
  Mailable to(String address, [String? name]) {
    _to.add(Address(address, name));
    return this;
  }

  /// Sets the CC address(es).
  Mailable cc(String address, [String? name]) {
    _cc.add(Address(address, name));
    return this;
  }

  /// Sets the BCC address(es).
  Mailable bcc(String address, [String? name]) {
    _bcc.add(Address(address, name));
    return this;
  }

  /// Sets the reply-to address(es).
  Mailable replyTo(String address, [String? name]) {
    _replyTo.add(Address(address, name));
    return this;
  }

  /// Sets the subject of the message.
  Mailable subject(String subject) {
    _subject = subject;
    return this;
  }

  /// Sets the template for the message.
  Mailable template(String template) {
    _template = template;
    return this;
  }

  /// Sets the HTML content for the message.
  Mailable html(String html) {
    _html = html;
    return this;
  }

  /// Sets the plain text content for the message.
  Mailable text(String text) {
    _text = text;
    return this;
  }

  /// Adds template data.
  Mailable withData(String key, dynamic value) {
    _viewData[key] = value;
    return this;
  }

  /// Adds multiple template data entries.
  Mailable withAllData(Map<String, dynamic> data) {
    _viewData.addAll(data);
    return this;
  }

  /// Attaches a file to the message.
  Mailable attach(Attachment attachment) {
    _attachments.add(attachment);
    return this;
  }

  /// Adds a header to the message.
  Mailable header(String name, String value) {
    _headers[name] = value;
    return this;
  }

  /// Adds metadata to the message.
  Mailable metadata(String key, String value) {
    _metadata[key] = value;
    return this;
  }

  /// Adds a tag to the message.
  Mailable tag(String tag) {
    _tags.add(tag);
    return this;
  }

  /// Sets the priority of the message.
  Mailable priority(int level) {
    if (level < 1 || level > 5) {
      throw MailFormatException('Priority must be between 1 and 5');
    }
    _priority = level;
    return this;
  }

  /// Sets the locale for the message.
  Mailable locale(String locale) {
    _locale = locale;
    return this;
  }

  /// Renders the message content using the template and view data.
  Future<(String?, String?)> _render() async {
    String? htmlContent = _html;
    String? textContent = _text;

    if (_template != null) {
      try {
        final template = Template(_template!, htmlEscapeValues: false);
        htmlContent = template.renderString(_viewData);
      } on TemplateException catch (e) {
        throw MailTemplateException('Failed to render template', e);
      }
    }

    return (htmlContent, textContent);
  }

  /// Sends the message using the given [MailManager].
  Future<void> send(MailManager manager) async {
    await build();

    if (_from.isEmpty) {
      throw MailFormatException('No sender address specified');
    }

    if (_to.isEmpty) {
      throw MailFormatException('No recipient address specified');
    }

    if (_subject == null || _subject!.isEmpty) {
      throw MailFormatException('No subject specified');
    }

    final (html, text) = await _render();

    if (html == null && text == null) {
      throw MailFormatException('No content specified');
    }

    await manager.send(
      to: _to,
      from: _from,
      cc: _cc,
      bcc: _bcc,
      replyTo: _replyTo,
      subject: _subject!,
      html: html,
      text: text,
      attachments: _attachments,
      headers: _headers,
      metadata: _metadata,
      tags: _tags,
      priority: _priority,
      locale: _locale,
    );
  }
}
