import 'dart:async';

import 'package:angel3_mq/mq.dart';
import 'package:angel3_mq/src/queue/data_stream.base.dart';
import 'package:equatable/equatable.dart';

/// A class representing a queue for message streaming.
///
/// The `Queue` class extends the [BaseDataStream] class and adds an
/// identifier, making it suitable for managing and streaming messages in a
/// queue-like fashion.
///
/// Example:
/// ```dart
/// final myQueue = Queue('my_queue_id');
///
/// // Enqueue a message to the queue.
/// final message = Message(
///   headers: {'contentType': 'json', 'sender': 'Alice'},
///   payload: {'text': 'Hello, World!'},
///   timestamp: '2023-09-07T12:00:002',
/// );
/// myQueue.enqueue(message);
///
/// // Check if the queue has active listeners.
/// final hasListeners = myQueue.hasListeners();
/// ```
class Queue extends BaseDataStream with EquatableMixin {
  Queue(this.id);
  final String id;
  final StreamController<Message> _controller =
      StreamController<Message>.broadcast();
  Message? _latestMessage;

  void addMessage(Message message) {
    _latestMessage = message;
    _controller.add(message);
  }

  Stream<Message> get dataStream => _controller.stream;

  Message? get latestMessage => _latestMessage;

  bool hasListeners() => _controller.hasListener;

  void dispose() {
    _controller.close();
  }

  // New method to remove a message
  void removeMessage(Message message) {
    if (_latestMessage == message) {
      _latestMessage = null;
    }
    // Note: We can't remove past messages from the stream,
    // but we can prevent this message from being processed again in the future.
  }

  List<Object?> get props => [id];
}
