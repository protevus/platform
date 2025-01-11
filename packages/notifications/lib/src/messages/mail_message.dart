import 'package:meta/meta.dart';

/// Represents an email notification message.
class MailMessage {
  /// The view template to use.
  String? view;

  /// The Markdown template to use.
  String? markdown;

  /// The theme to use when using markdown.
  String? theme;

  /// The "from" information for the message.
  List<String>? from;

  /// The "reply to" information for the message.
  List<List<String>> replyTo = [];

  /// The subject of the message.
  String? subject;

  /// The message priority level.
  int? priority;

  /// The CC recipients of the message.
  List<List<String>> cc = [];

  /// The BCC recipients of the message.
  List<List<String>> bcc = [];

  /// The attachments for the message.
  List<Map<String, dynamic>> attachments = [];

  /// The raw attachments for the message.
  List<Map<String, dynamic>> rawAttachments = [];

  /// The tags for the message.
  List<String> tags = [];

  /// The metadata for the message.
  Map<String, String> metadata = {};

  /// Additional data to be passed to the view.
  Map<String, dynamic> _viewData = {};

  /// Creates a new mail message instance.
  MailMessage();

  /// Set the view template for the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage setView(String template) {
    view = template;
    return this;
  }

  /// Set the Markdown template for the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage withMarkdown(String template, {String? theme}) {
    this.markdown = template;
    if (theme != null) this.theme = theme;
    return this;
  }

  /// Set the from address for the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage setFrom(String address, [String? name]) {
    from = name != null ? [address, name] : [address];
    return this;
  }

  /// Add a reply-to address to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage addReplyTo(String address, [String? name]) {
    replyTo.add(name != null ? [address, name] : [address]);
    return this;
  }

  /// Set the subject of the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage setSubject(String value) {
    subject = value;
    return this;
  }

  /// Set the priority of the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage withPriority(int level) {
    this.priority = level;
    return this;
  }

  /// Add a cc address to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage addCc(String address, [String? name]) {
    cc.add(name != null ? [address, name] : [address]);
    return this;
  }

  /// Add a bcc address to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage addBcc(String address, [String? name]) {
    bcc.add(name != null ? [address, name] : [address]);
    return this;
  }

  /// Attach a file to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage attach(String path, {Map<String, dynamic>? options}) {
    this.attachments.add({
      'file': path,
      'options': options ?? {},
    });
    return this;
  }

  /// Attach in-memory data as a file.
  ///
  /// Returns this instance for method chaining.
  MailMessage attachData(List<int> data, String name,
      {Map<String, dynamic>? options}) {
    this.rawAttachments.add({
      'data': data,
      'name': name,
      'options': options ?? {},
    });
    return this;
  }

  /// Add a tag to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage tag(String tag) {
    this.tags.add(tag);
    return this;
  }

  /// Add metadata to the message.
  ///
  /// Returns this instance for method chaining.
  MailMessage withMetadata(String key, String value) {
    this.metadata[key] = value;
    return this;
  }

  /// Add data to be passed to the view.
  ///
  /// Returns this instance for method chaining.
  MailMessage withData(Map<String, dynamic> data) {
    _viewData.addAll(data);
    return this;
  }

  /// Get the view data for the message.
  @protected
  Map<String, dynamic> data() => _viewData;
}
