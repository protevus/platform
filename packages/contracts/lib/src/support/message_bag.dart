import 'arrayable.dart';
import 'countable.dart';

// TODO: Fix Imports.

abstract class MessageBag implements Arrayable, Countable {
  /// Get the keys present in the message bag.
  List<String> keys();

  /// Add a message to the bag.
  /// 
  /// Returns this instance for chaining.
  MessageBag add(String key, String message);

  /// Merge a new array of messages into the bag.
  /// 
  /// Returns this instance for chaining.
  MessageBag merge(dynamic messages);

  /// Determine if messages exist for a given key.
  bool has(dynamic key);

  /// Get the first message from the bag for a given key.
  String first([String? key, String? format]);

  /// Get all of the messages from the bag for a given key.
  List<String> get(String key, [String? format]);

  /// Get all of the messages for every key in the bag.
  List<String> all([String? format]);

  /// Remove a message from the bag.
  /// 
  /// Returns this instance for chaining.
  MessageBag forget(String key);

  /// Get the raw messages in the container.
  List<dynamic> getMessages();

  /// Get the default message format.
  String getFormat();

  /// Set the default message format.
  /// 
  /// Returns this instance for chaining.
  MessageBag setFormat([String format = ':message']);

  /// Determine if the message bag has any messages.
  bool isEmpty();

  /// Determine if the message bag has any messages.
  bool isNotEmpty();
}
