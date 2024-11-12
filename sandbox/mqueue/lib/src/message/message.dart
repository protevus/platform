import 'package:angel3_mq/src/message/message.base.dart';
import 'package:uuid/uuid.dart';

/// Represents a message with headers, payload, and an optional timestamp.
///
/// A [Message] is a specific type of message that extends the [BaseMessage]
/// class.
///
/// Example:
/// ```dart
/// final message = Message(
///   headers: {'contentType': 'json', 'sender': 'Alice'},
///   payload: {'text': 'Hello, World!'},
///   timestamp: '2023-09-07T12:00:002',
/// );
/// ```
class Message extends BaseMessage {
  /// Creates a new [Message] with the specified headers, payload, timestamp, and id.
  ///
  /// The [headers] parameter is a map that can contain additional information
  /// about the message. It is optional and defaults to an empty map if not
  /// provided.
  ///
  /// The [payload] parameter represents the main content of the message and is
  /// required.
  ///
  /// The [timestamp] parameter is an optional ISO 8601 formatted timestamp
  /// indicating when the message was created. If not provided, the current
  /// timestamp will be used.
  ///
  /// The [id] parameter is an optional unique identifier for the message.
  /// If not provided, a new UUID will be generated.
  ///
  /// Example:
  /// ```dart
  /// final message = Message(
  ///   headers: {'contentType': 'json', 'sender': 'Alice'},
  ///   payload: {'text': 'Hello, World!'},
  ///   timestamp: '2023-09-07T12:00:002',
  ///   id: '123e4567-e89b-12d3-a456-426614174000',
  /// );
  /// ```
  Message({
    required Object payload,
    Map<String, dynamic>? headers,
    String? timestamp,
    String? id,
  })  : id = id ?? Uuid().v4(),
        super(
          headers,
          payload,
          timestamp ?? DateTime.now().toUtc().toIso8601String(),
        );

  /// A unique identifier for the message.
  final String id;

  /// Returns a human-readable string representation of the message.
  ///
  /// Example:
  /// ```dart
  /// final message = Message(
  ///   headers: {'contentType': 'json', 'sender': 'Alice'},
  ///   payload: {'text': 'Hello, World!'},
  ///   timestamp: '2023-09-07T12:00:002',
  /// );
  ///
  /// print(message.toString());
  /// // Output:
  /// // Message{
  /// //   headers: {contentType: json, sender: Alice},
  /// //   payload: {text: Hello, World!},
  /// //   timestamp: 2023-09-07T12:00:002,
  /// // }
  /// ```
  @override
  String toString() {
    return '''
Message{
  id: $id,
  headers: $headers,
  payload: $payload,
  timestamp: $timestamp,
}''';
  }
}
