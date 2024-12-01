import 'message_bag.dart';

/// Interface for objects that provide messages.
///
/// This contract defines a standard way for objects to provide
/// access to their messages through a MessageBag instance.
/// This is particularly useful for validation results, form processing,
/// and other scenarios where multiple messages need to be managed.
///
/// Example:
/// ```dart
/// class ValidationResult implements MessageProvider {
///   final MessageBag _messages;
///
///   ValidationResult(this._messages);
///
///   @override
///   MessageBag getMessageBag() => _messages;
/// }
/// ```
abstract class MessageProvider {
  /// Get the messages for the instance.
  ///
  /// Returns a MessageBag instance containing all messages
  /// associated with this provider.
  MessageBag getMessageBag();
}
