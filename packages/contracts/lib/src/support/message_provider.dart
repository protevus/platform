import 'message_bag.dart';

abstract class MessageProvider {
  /// Get the messages for the instance.
  ///
  /// @return MessageBag
  MessageBag getMessageBag();
}
