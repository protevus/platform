import 'arrayable.dart';

/// Interface for storing and retrieving messages.
///
/// This contract defines a standard way to store, retrieve, and manipulate
/// messages (such as validation errors or notifications) in a structured way.
abstract class MessageBag implements Arrayable<String, dynamic> {
  /// Get the keys present in the message bag.
  List<String> keys();

  /// Add a message to the bag.
  ///
  /// Returns this instance for method chaining.
  MessageBag add(String key, String message);

  /// Merge a new array of messages into the bag.
  ///
  /// The [messages] parameter can be either a MessageProvider or a Map.
  /// Returns this instance for method chaining.
  MessageBag merge(dynamic messages);

  /// Determine if messages exist for a given key.
  ///
  /// The [key] parameter can be either a single key or a list of keys.
  bool has(dynamic key);

  /// Get the first message from the bag for a given key.
  ///
  /// If [key] is null, returns the first message from any key.
  /// The [format] parameter can be used to format the message string.
  String? first([String? key, String? format]);

  /// Get all of the messages from the bag for a given key.
  ///
  /// The [format] parameter can be used to format the message strings.
  List<String> get(String key, [String? format]);

  /// Get all of the messages for every key in the bag.
  ///
  /// The [format] parameter can be used to format the message strings.
  Map<String, List<String>> all([String? format]);

  /// Remove a message from the bag.
  ///
  /// Returns this instance for method chaining.
  MessageBag forget(String key);

  /// Get the raw messages in the container.
  Map<String, List<String>> getMessages();

  /// Get the default message format.
  String getFormat();

  /// Set the default message format.
  ///
  /// Returns this instance for method chaining.
  /// Default format is ':message'.
  MessageBag setFormat([String format = ':message']);

  /// Determine if the message bag has any messages.
  bool get isEmpty;

  /// Determine if the message bag has any messages.
  bool get isNotEmpty;

  /// Get the number of messages in the container.
  int get length;
}
