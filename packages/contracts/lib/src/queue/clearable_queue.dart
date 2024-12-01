/// Interface for queues that can be cleared.
abstract class ClearableQueue {
  /// Delete all of the jobs from the queue.
  int clear(String queue);
}
