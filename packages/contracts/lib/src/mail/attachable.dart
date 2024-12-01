/// Interface for mail attachments.
abstract class Attachable {
  /// Get an attachment instance for this entity.
  dynamic toMailAttachment();
}
