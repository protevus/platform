import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../driver.dart';

/// A concurrency driver that uses Dart isolates for parallel execution.
///
/// This driver spawns new isolates for task execution, providing true
/// parallel processing capabilities. Each isolate runs in its own
/// thread with isolated memory.
class IsolateDriver implements Driver {
  /// Maximum number of isolates to run concurrently
  final int maxConcurrent;

  /// Creates a new isolate driver.
  ///
  /// [maxConcurrent] controls how many isolates can run at once.
  /// Defaults to the number of processor cores.
  IsolateDriver({this.maxConcurrent = 0});

  @override
  Future<List<T>> run<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    final tasks = List.generate(times, (_) => task);
    return runAll(tasks);
  }

  @override
  Future<List<T>> runAll<T>(List<FutureOr<T> Function()> tasks) async {
    if (tasks.isEmpty) return [];

    final results = List<T?>.filled(tasks.length, null);
    final completer = Completer<List<T>>();
    var completed = 0;

    // Function to run in isolate
    Future<T> isolateFunction(int index) async {
      try {
        return await tasks[index]();
      } catch (e, st) {
        throw ConcurrencyException(
          'Task failed in isolate',
          e,
          st,
        );
      }
    }

    // Handle isolate completion
    void handleResult(int index, T result) {
      results[index] = result;
      completed++;
      if (completed == tasks.length) {
        completer.complete(results.cast<T>());
      }
    }

    // Handle isolate errors
    void handleError(int index, Object error, StackTrace stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(
          ConcurrencyException(
            'Task $index failed in isolate',
            error,
            stackTrace,
          ),
        );
      }
    }

    // Determine max concurrent isolates
    final concurrent = maxConcurrent > 0
        ? maxConcurrent
        : (Platform.numberOfProcessors).toInt();

    // Process tasks in batches
    for (var i = 0; i < tasks.length; i += concurrent) {
      final batch = <Future<void>>[];
      final end =
          (i + concurrent < tasks.length) ? i + concurrent : tasks.length;

      for (var j = i; j < end; j++) {
        batch.add(
          Isolate.run(() => isolateFunction(j))
              .then((result) => handleResult(j, result))
              .catchError(
                  (error, stackTrace) => handleError(j, error, stackTrace)),
        );
      }

      // Wait for batch to complete before starting next batch
      await Future.wait(batch);
    }

    return completer.future;
  }

  @override
  Future<void> defer<T>(
    FutureOr<T> Function() task, {
    int times = 1,
  }) async {
    final tasks = List.generate(times, (_) => task);
    return deferAll(tasks);
  }

  @override
  Future<void> deferAll<T>(List<FutureOr<T> Function()> tasks) async {
    // Schedule isolate creation for next event loop iteration
    scheduleMicrotask(() async {
      try {
        await runAll(tasks);
      } catch (e, st) {
        // Log error since this is a background task
        Zone.current.handleUncaughtError(e, st);
      }
    });
  }
}
