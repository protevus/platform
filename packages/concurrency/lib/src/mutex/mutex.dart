import 'dart:async';

/// A mutual exclusion lock for coordinating access to shared resources.
///
/// The mutex ensures that only one task can access a protected resource at a time.
/// It supports timeouts and automatic lock release through zones.
class Mutex {
  final _lock = Completer<void>();
  var _locked = false;
  final _queue = <Completer<void>>[];

  /// Whether the mutex is currently locked.
  bool get isLocked => _locked;

  /// Acquires the mutex lock.
  ///
  /// If the mutex is already locked, waits until it becomes available.
  /// Returns a future that completes when the lock is acquired.
  ///
  /// If [timeout] is specified, throws a [MutexException] if the lock
  /// cannot be acquired within that duration.
  Future<void> acquire({Duration? timeout}) {
    if (!_locked) {
      _locked = true;
      _lock.complete();
      return Future.value();
    }

    final completer = Completer<void>();
    _queue.add(completer);

    if (timeout != null) {
      return Future.any([
        completer.future,
        Future.delayed(timeout).then((_) {
          _queue.remove(completer);
          throw MutexException(
              'Failed to acquire lock: timeout after ${timeout.inSeconds} seconds');
        }),
      ]);
    }

    return completer.future;
  }

  /// Releases the mutex lock.
  ///
  /// If there are waiting tasks in the queue, the next task will acquire the lock.
  /// Throws [MutexException] if the mutex is not currently locked.
  void release() {
    if (!_locked) {
      throw MutexException('Cannot release an unlocked mutex');
    }

    if (_queue.isEmpty) {
      _locked = false;
    } else {
      final next = _queue.removeAt(0);
      next.complete();
    }
  }

  /// Executes a task with the mutex lock.
  ///
  /// Automatically acquires the lock before executing the task and releases it
  /// after the task completes (or throws an error).
  ///
  /// If [timeout] is specified, throws a [MutexException] if the lock
  /// cannot be acquired within that duration.
  Future<T> synchronized<T>(
    FutureOr<T> Function() task, {
    Duration? timeout,
  }) async {
    await acquire(timeout: timeout);
    try {
      return await task();
    } finally {
      release();
    }
  }

  /// Creates a new mutex guard for protecting a specific resource.
  ///
  /// The guard ensures proper lock acquisition and release around resource access.
  /// Example:
  /// ```dart
  /// final guard = mutex.guard(() => sharedResource.doSomething());
  /// await guard.protect();
  /// ```
  MutexGuard<T> guard<T>(FutureOr<T> Function() task) {
    return MutexGuard<T>(this, task);
  }
}

/// A guard that manages mutex lock acquisition and release for a specific task.
class MutexGuard<T> {
  final Mutex _mutex;
  final FutureOr<T> Function() _task;
  Duration? _timeout;

  MutexGuard(this._mutex, this._task);

  /// Sets a timeout for acquiring the mutex lock.
  MutexGuard<T> withTimeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  /// Executes the protected task with proper mutex lock handling.
  Future<T> protect() => _mutex.synchronized(_task, timeout: _timeout);
}

/// Exception thrown when mutex operations fail.
class MutexException implements Exception {
  final String message;

  MutexException(this.message);

  @override
  String toString() => 'MutexException: $message';
}
