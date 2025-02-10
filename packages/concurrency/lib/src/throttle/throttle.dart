import 'dart:async';
import 'dart:collection';

/// Controls the execution rate of tasks by limiting how frequently they can run.
///
/// Unlike RateLimiter which uses tokens, Throttle ensures a minimum time gap
/// between task executions and optionally combines multiple requests into
/// a single execution.
class Throttle {
  final Duration _minInterval;
  final bool _combineRequests;
  DateTime? _lastRun;
  Timer? _timer;
  final Queue<_ThrottleRequest> _queue = Queue();
  bool _processing = false;

  /// Creates a new throttle.
  ///
  /// [minInterval] specifies the minimum time that must pass between executions.
  /// [combineRequests] determines if multiple pending requests should be combined
  /// into a single execution. When true, only the most recent request is executed.
  Throttle({
    required Duration minInterval,
    bool combineRequests = false,
  })  : _minInterval = minInterval,
        _combineRequests = combineRequests;

  /// Executes a task with throttling.
  ///
  /// If another task was recently executed (within minInterval), this task
  /// will be queued. If combineRequests is true, queued tasks may be combined.
  ///
  /// If [timeout] is specified and the task cannot be executed within that
  /// duration, throws a [ThrottleException].
  Future<T> execute<T>(
    FutureOr<T> Function() task, {
    Duration? timeout,
  }) {
    final completer = Completer<T>();
    final request = _ThrottleRequest<T>(task, completer);

    if (_combineRequests) {
      // Remove any pending requests since we'll only execute the most recent
      while (_queue.isNotEmpty) {
        final pending = _queue.removeLast();
        pending.completer.completeError(
          ThrottleException('Request superseded by newer request'),
        );
      }
    }

    _queue.add(request);

    // Set timeout if specified
    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted && _queue.contains(request)) {
          _queue.remove(request);
          completer.completeError(
            ThrottleException(
              'Request timed out after ${timeout.inSeconds} seconds',
            ),
          );
        }
      });
    }

    // Start processing if not already running
    if (!_processing) {
      _processQueue();
    }

    return completer.future;
  }

  /// Executes a task that doesn't return a value with throttling.
  Future<void> run(FutureOr<void> Function() task, {Duration? timeout}) {
    return execute<void>(task, timeout: timeout);
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty || _processing) return;

    _processing = true;
    try {
      while (_queue.isNotEmpty) {
        final now = DateTime.now();
        final timeSinceLastRun =
            _lastRun != null ? now.difference(_lastRun!) : _minInterval;

        if (timeSinceLastRun < _minInterval) {
          // Wait for remaining time before processing next request
          final delay = _minInterval - timeSinceLastRun;
          _timer?.cancel();
          _timer = Timer(delay, () => _processQueue());
          return;
        }

        final request = _queue.removeFirst();
        try {
          final result = await request.task();
          if (!request.completer.isCompleted) {
            request.completer.complete(result);
          }
        } catch (e, st) {
          if (!request.completer.isCompleted) {
            request.completer.completeError(e, st);
          }
        }

        _lastRun = DateTime.now();
      }
    } finally {
      _processing = false;
    }
  }

  /// Cancels all pending requests.
  void cancel() {
    _timer?.cancel();
    _timer = null;

    final error = ThrottleException('Throttle was cancelled');
    while (_queue.isNotEmpty) {
      final request = _queue.removeFirst();
      if (!request.completer.isCompleted) {
        request.completer.completeError(error);
      }
    }
  }
}

/// A request in the throttle queue.
class _ThrottleRequest<T> {
  final FutureOr<T> Function() task;
  final Completer<T> completer;

  _ThrottleRequest(this.task, this.completer);
}

/// Exception thrown when throttle operations fail.
class ThrottleException implements Exception {
  final String message;

  ThrottleException(this.message);

  @override
  String toString() => 'ThrottleException: $message';
}
