/// A class that represents a queued event listener.
class CallQueuedListener {
  /// The class name of the listener.
  final String className;

  /// The method name to call.
  final String method;

  /// The arguments to pass to the method.
  final List<dynamic> data;

  /// Whether to dispatch after commit.
  bool afterCommit = false;

  /// The backoff strategy.
  dynamic backoff;

  /// The maximum number of exceptions allowed.
  int? maxExceptions;

  /// The retry until timestamp.
  DateTime? retryUntil;

  /// Whether the job should be encrypted.
  bool shouldBeEncrypted = false;

  /// The timeout in seconds.
  int? timeout;

  /// Whether to fail on timeout.
  bool failOnTimeout = false;

  /// The number of times to try the job.
  int? tries;

  /// The middleware to apply.
  List<dynamic> middleware = [];

  /// The connection to use for the queue.
  String? connection;

  /// The queue to use.
  String? queue;

  /// The delay before processing.
  Duration? delay;

  /// Create a new queued listener instance.
  CallQueuedListener(this.className, this.method, this.data);

  /// Add middleware to the listener.
  void through(List<dynamic> middleware) {
    this.middleware = middleware;
  }

  /// Set the desired connection for the job.
  CallQueuedListener onConnection(String connection) {
    this.connection = connection;
    return this;
  }

  /// Set the desired queue for the job.
  CallQueuedListener onQueue(String queue) {
    this.queue = queue;
    return this;
  }

  /// Set the desired delay for the job.
  CallQueuedListener withDelay(Duration delay) {
    this.delay = delay;
    return this;
  }
}
