import 'dart:convert';
import 'package:illuminate_contracts/contracts.dart' as contracts;
// import 'package:illuminate_contracts/contracts.dart'; as contracts
//     show Arrayable, Jsonable, MessageProvider, MessageBag;
import 'stringable.dart';

/// A class for storing and retrieving messages.
///
/// This class provides a way to store, retrieve, and manipulate messages
/// (such as validation errors or notifications) in a structured way.
class MessageBag extends Stringable
    implements
        contracts.MessageBag,
        contracts.MessageProvider,
        contracts.Jsonable {
  /// The messages stored in the bag.
  final Map<String, List<String>> _messages;

  /// The format for the messages.
  String _format = ':message';

  /// Create a new message bag instance.
  MessageBag([Map<String, List<String>>? messages])
      : _messages = messages ?? <String, List<String>>{},
        super('');

  /// Get the first message as a Stringable instance.
  Stringable _asStringable() {
    final message = first() ?? '';
    return Stringable(message);
  }

  @override
  List<String> keys() => _messages.keys.toList();

  @override
  contracts.MessageBag add(String key, String message) {
    _messages.putIfAbsent(key, () => []).add(message);
    return this;
  }

  @override
  contracts.MessageBag merge(dynamic messages) {
    if (messages is contracts.MessageProvider) {
      messages = messages.getMessageBag().getMessages();
    }

    if (messages is Map<String, List<String>>) {
      messages.forEach((key, value) {
        for (var message in value) {
          add(key, message);
        }
      });
    }

    return this;
  }

  @override
  bool has(dynamic key) {
    if (key is List) {
      return key.any((k) => _messages.containsKey(k));
    }
    return _messages.containsKey(key);
  }

  @override
  String? first([String? key, String? format]) {
    if (isEmpty) return null;

    if (key == null) {
      return _transform(_messages.values.first.first, format);
    }

    if (!has(key)) return null;

    return _transform(_messages[key]!.first, format);
  }

  @override
  List<String> get(String key, [String? format]) {
    if (!has(key)) return [];

    return _messages[key]!.map((m) => _transform(m, format)).toList();
  }

  @override
  Map<String, List<String>> all([String? format]) {
    if (isEmpty) return {};

    if (format == null) return Map.from(_messages);

    return _messages.map(
      (key, messages) => MapEntry(
        key,
        messages.map((m) => _transform(m, format)).toList(),
      ),
    );
  }

  @override
  contracts.MessageBag forget(String key) {
    _messages.remove(key);
    return this;
  }

  @override
  Map<String, List<String>> getMessages() => Map.from(_messages);

  @override
  String getFormat() => _format;

  @override
  contracts.MessageBag setFormat([String format = ':message']) {
    _format = format;
    return this;
  }

  @override
  bool get isEmpty => _messages.isEmpty;

  @override
  bool get isNotEmpty => _messages.isNotEmpty;

  /// Get the number of messages in the container.
  @override
  int get length =>
      _messages.values.fold(0, (sum, messages) => sum + messages.length);

  @override
  Map<String, dynamic> toArray() {
    return {
      'messages': _messages,
      'format': _format,
      'isEmpty': isEmpty,
      'isNotEmpty': isNotEmpty,
      'length': length,
    };
  }

  @override
  String toJson([Map<String, dynamic>? options]) {
    return jsonEncode(toArray());
  }

  /// Transform a message using the given format.
  String _transform(String message, String? format) {
    format ??= _format;
    return format.replaceAll(':message', message);
  }

  /// Get the string value.
  ///
  /// When using Stringable methods, returns the first message if available.
  /// Otherwise, returns the messages as a string.
  @override
  String toString() {
    if (isEmpty) return '';
    return first() ?? all().toString();
  }

  @override
  contracts.MessageBag getMessageBag() => this;

  // Override Stringable methods to work with the first message

  @override
  Stringable upper() => Stringable(_asStringable().upper().toString());

  @override
  Stringable lower() => Stringable(_asStringable().lower().toString());

  @override
  Stringable title() => Stringable(_asStringable().title().toString());

  @override
  Stringable camel() => Stringable(_asStringable().camel().toString());

  @override
  Stringable studly() => Stringable(_asStringable().studly().toString());

  @override
  Stringable snake([String separator = '_']) =>
      Stringable(_asStringable().snake(separator).toString());

  @override
  Stringable kebab() => Stringable(_asStringable().kebab().toString());
}
