import 'dart:async';

/// Base interface for all concurrency drivers.
abstract class Driver {
  /// Runs the given tasks concurrently and returns their results.
  ///
  /// Tasks can be provided as a single function or list of functions.
  /// Returns a Future that completes with a list of results in the same order
  /// as the input tasks.
  Future<List<T>> run<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  });

  /// Runs multiple tasks concurrently and returns their results.
  ///
  /// Takes a list of tasks and executes them concurrently.
  /// Returns a Future that completes with a list of results in the same order
  /// as the input tasks.
  Future<List<T>> runAll<T>(
    List<FutureOr<T> Function()> tasks,
  );

  /// Defers execution of tasks until after the current task completes.
  ///
  /// Tasks will be executed in the background after the current execution
  /// context completes. Returns a Future that completes when the tasks
  /// have been scheduled (not when they complete).
  Future<void> defer<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  });

  /// Defers execution of multiple tasks until after the current task completes.
  ///
  /// Tasks will be executed in the background after the current execution
  /// context completes. Returns a Future that completes when the tasks
  /// have been scheduled (not when they complete).
  Future<void> deferAll<T>(
    List<FutureOr<T> Function()> tasks,
  );
}

/// Exception thrown when a concurrent task fails.
class ConcurrencyException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  ConcurrencyException(this.message, [this.error, this.stackTrace]);

  @override
  String toString() =>
      'ConcurrencyException: $message${error != null ? '\nCaused by: $error' : ''}';
}
