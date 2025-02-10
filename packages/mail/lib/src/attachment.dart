import 'dart:convert';
import 'dart:typed_data';

/// Represents an email attachment.
class Attachment {
  /// The filename of the attachment.
  final String filename;

  /// The MIME type of the attachment.
  final String mimeType;

  /// The content of the attachment as bytes.
  final Uint8List content;

  /// Whether the attachment should be displayed inline.
  final bool isInline;

  /// The Content-ID for inline attachments.
  final String? contentId;

  /// Additional headers for the attachment.
  final Map<String, String>? headers;

  /// Creates a new attachment.
  ///
  /// The [filename] is required and should include the file extension.
  /// The [mimeType] defaults to 'application/octet-stream' if not provided.
  const Attachment({
    required this.filename,
    required this.content,
    String? mimeType,
    this.isInline = false,
    this.contentId,
    this.headers,
  }) : mimeType = mimeType ?? 'application/octet-stream';

  /// Creates an attachment from a string.
  ///
  /// The content is encoded as UTF-8.
  factory Attachment.fromString({
    required String filename,
    required String content,
    String? mimeType,
    bool isInline = false,
    String? contentId,
    Map<String, String>? headers,
  }) {
    return Attachment(
      filename: filename,
      content: Uint8List.fromList(content.codeUnits),
      mimeType: mimeType ?? 'text/plain',
      isInline: isInline,
      contentId: contentId,
      headers: headers,
    );
  }

  /// Creates an attachment from base64 encoded data.
  factory Attachment.fromBase64({
    required String filename,
    required String base64Content,
    String? mimeType,
    bool isInline = false,
    String? contentId,
    Map<String, String>? headers,
  }) {
    return Attachment(
      filename: filename,
      content: base64Decode(base64Content),
      mimeType: mimeType,
      isInline: isInline,
      contentId: contentId,
      headers: headers,
    );
  }

  /// Gets the size of the attachment in bytes.
  int get size => content.length;

  /// Creates a copy of this attachment with the given fields replaced.
  Attachment copyWith({
    String? filename,
    Uint8List? content,
    String? mimeType,
    bool? isInline,
    String? contentId,
    Map<String, String>? headers,
  }) {
    return Attachment(
      filename: filename ?? this.filename,
      content: content ?? this.content,
      mimeType: mimeType ?? this.mimeType,
      isInline: isInline ?? this.isInline,
      contentId: contentId ?? this.contentId,
      headers: headers ?? this.headers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attachment &&
        other.filename == filename &&
        other.mimeType == mimeType &&
        other.isInline == isInline &&
        other.contentId == contentId;
  }

  @override
  int get hashCode => Object.hash(
        filename,
        mimeType,
        isInline,
        contentId,
      );
}
