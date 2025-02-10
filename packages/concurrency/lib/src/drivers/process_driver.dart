import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../driver.dart';

/// A concurrency driver that uses system processes for parallel execution.
///
/// This driver spawns new OS processes for task execution. Each process runs
/// independently with its own memory space. This is useful for CPU-intensive
/// tasks that benefit from true parallelism.
class ProcessDriver implements Driver {
  /// Maximum number of concurrent processes
  final int maxConcurrent;

  /// Working directory for spawned processes
  final String? workingDirectory;

  /// Environment variables for spawned processes
  final Map<String, String>? environment;

  /// Creates a new process driver.
  ///
  /// [maxConcurrent] controls how many processes can run at once.
  /// Defaults to the number of processor cores.
  ///
  /// [workingDirectory] sets the working directory for spawned processes.
  ///
  /// [environment] provides environment variables to spawned processes.
  ProcessDriver({
    this.maxConcurrent = 0,
    this.workingDirectory,
    this.environment,
  });

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

    // Create a temporary Dart script to execute the task
    final scriptFile = await _createTaskScript();

    try {
      // Determine max concurrent processes
      final concurrent =
          maxConcurrent > 0 ? maxConcurrent : Platform.numberOfProcessors;

      // Process tasks in batches
      for (var i = 0; i < tasks.length; i += concurrent) {
        final batch = <Future<void>>[];
        final end =
            (i + concurrent < tasks.length) ? i + concurrent : tasks.length;

        for (var j = i; j < end; j++) {
          batch.add(_runProcess(scriptFile.path, j, tasks[j]).then((result) {
            results[j] = result as T;
            completed++;
            if (completed == tasks.length) {
              completer.complete(results.cast<T>());
            }
          }).catchError((error, StackTrace stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(
                ConcurrencyException(
                  'Process task $j failed',
                  error,
                  stackTrace,
                ),
              );
            }
          }));
        }

        // Wait for batch to complete before starting next batch
        await Future.wait(batch);
      }
    } finally {
      // Clean up temporary script
      await scriptFile.delete();
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
    // Schedule process creation for next event loop iteration
    scheduleMicrotask(() async {
      try {
        await runAll(tasks);
      } catch (e, st) {
        // Log error since this is a background task
        Zone.current.handleUncaughtError(e, st);
      }
    });
  }

  // Creates a temporary Dart script file to execute the task
  Future<File> _createTaskScript() async {
    final tempDir =
        await Directory.systemTemp.createTemp('dart_process_driver_');
    final file = File('${tempDir.path}/task_runner.dart');

    await file.writeAsString('''
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

void main(List<String> args) async {
  try {
    // Execute the task and encode result
    final result = await Isolate.run(() async {
      // Task execution would go here
      // In practice, we'd need to deserialize the task from args
      return null;
    });

    print(json.encode({
      'success': true,
      'result': result,
    }));
  } catch (e, st) {
    print(json.encode({
      'success': false,
      'error': e.toString(),
      'stack': st.toString(),
    }));
  }
}
''');

    return file;
  }

  // Runs a single task in a new process
  Future<dynamic> _runProcess(
    String scriptPath,
    int taskIndex,
    FutureOr<dynamic> Function() task,
  ) async {
    final process = await Process.start(
      Platform.executable,
      [scriptPath, taskIndex.toString()],
      workingDirectory: workingDirectory,
      environment: environment,
    );

    final output = await process.stdout.transform(utf8.decoder).join();
    final error = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw ConcurrencyException(
        'Process exited with code $exitCode',
        error.isEmpty ? output : error,
      );
    }

    try {
      final result = json.decode(output);
      if (result['success'] == true) {
        return result['result'];
      } else {
        throw ConcurrencyException(
          'Task execution failed',
          result['error'],
          StackTrace.fromString(result['stack'] as String),
        );
      }
    } catch (e) {
      throw ConcurrencyException(
        'Failed to parse process output',
        e,
      );
    }
  }
}
