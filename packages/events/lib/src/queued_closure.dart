import 'package:platform_collections/collections.dart';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_support/platform_support.dart';

import 'queued_listener.dart';
import 'invoke_queued_closure.dart';
import 'serializable_closure.dart';

/// A wrapper for closures that should be queued.
class QueuedClosure implements ShouldQueue {
  /// The underlying closure.
  final Function closure;

  /// The name of the connection the job should be sent to.
  String? connection;

  /// The name of the queue the job should be sent to.
  String? queue;

  /// The number of seconds before the job should be made available.
  Duration? delay;

  /// All of the "catch" callbacks for the queued closure.
  final List<Function> catchCallbacks = [];

  /// Create a new queued closure event listener resolver.
  QueuedClosure(this.closure);

  /// Set the desired connection for the job.
  QueuedClosure onConnection(String? connection) {
    this.connection = connection;
    return this;
  }

  /// Set the desired queue for the job.
  QueuedClosure onQueue(dynamic queue) {
    // TODO: Implement enum value support once platform_support is updated
    this.queue = queue is String ? queue : queue.toString();
    return this;
  }

  /// Set the desired delay for the job.
  QueuedClosure withDelay(Duration? delay) {
    this.delay = delay;
    return this;
  }

  /// Specify a callback that should be invoked if the queued listener job fails.
  QueuedClosure catchError(Function callback) {
    catchCallbacks.add(callback);
    return this;
  }

  /// Resolve the actual event listener callback.
  Function resolve() {
    return (List<dynamic> arguments) {
      final serializedClosure = SerializableClosure(closure);
      final serializedCallbacks = Collection(catchCallbacks)
          .map((callback) => SerializableClosure(callback))
          .toList();

      final job = CallQueuedListener(
        'InvokeQueuedClosure',
        'handle',
        [
          serializedClosure,
          arguments,
          serializedCallbacks,
        ],
      );

      if (connection != null) {
        job.onConnection(connection!);
      }

      if (queue != null) {
        job.onQueue(queue!);
      }

      if (delay != null) {
        job.withDelay(delay!);
      }

      return job;
    };
  }

  /// Create a new queued closure instance.
  static QueuedClosure create(Function closure) => QueuedClosure(closure);
}
