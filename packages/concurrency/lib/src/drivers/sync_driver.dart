import 'dart:async';

import '../driver.dart';

/// A synchronous implementation of the concurrency driver.
///
/// This driver executes tasks sequentially in the current isolate.
/// Useful for testing and debugging purposes.
class SyncDriver implements Driver {
  @override
  Future<List<T>> run<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    final results = <T>[];
    for (var i = 0; i < times; i++) {
      try {
        results.add(await task());
      } catch (e, st) {
        throw ConcurrencyException(
          'Task failed during synchronous execution',
          e,
          st,
        );
      }
    }
    return results;
  }

  @override
  Future<List<T>> runAll<T>(List<FutureOr<T> Function()> tasks) async {
    final results = <T>[];
    for (final task in tasks) {
      try {
        results.add(await task());
      } catch (e, st) {
        throw ConcurrencyException(
          'Task failed during synchronous execution',
          e,
          st,
        );
      }
    }
    return results;
  }

  @override
  Future<void> defer<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    // Schedule task execution for the next event loop iteration
    for (var i = 0; i < times; i++) {
      scheduleMicrotask(() async {
        try {
          await task();
        } catch (e, st) {
          // Log error since this is a background task
          Zone.current.handleUncaughtError(e, st);
        }
      });
    }
  }

  @override
  Future<void> deferAll<T>(List<FutureOr<T> Function()> tasks) async {
    for (final task in tasks) {
      scheduleMicrotask(() async {
        try {
          await task();
        } catch (e, st) {
          // Log error since this is a background task
          Zone.current.handleUncaughtError(e, st);
        }
      });
    }
  }
}
