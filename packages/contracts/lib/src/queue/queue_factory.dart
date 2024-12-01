import 'queue.dart';

/// Interface for queue factory.
abstract class QueueFactory {
  /// Resolve a queue connection instance.
  Queue connection([String? name]);
}
