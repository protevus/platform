import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';

/// Contract for process management.
///
/// Platform-specific: Provides system process management following Laravel's
/// architectural patterns for resource management and lifecycle control.
@sealed
abstract class ProcessManagerContract {
  /// Starts a new process.
  ///
  /// Platform-specific: Creates and starts a new system process with
  /// Laravel-style identifier and configuration options.
  ///
  /// Parameters:
  ///   - [id]: Unique identifier for the process.
  ///   - [command]: Command to execute.
  ///   - [arguments]: Command arguments.
  ///   - [workingDirectory]: Optional working directory.
  ///   - [environment]: Optional environment variables.
  ///   - [timeout]: Optional execution timeout.
  ///   - [tty]: Whether to run in a terminal.
  ///   - [enableReadError]: Whether to enable error stream reading.
  Future<ProcessContract> start(
    String id,
    String command,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration? timeout,
    bool tty = false,
    bool enableReadError = true,
  });

  /// Gets a running process by ID.
  ///
  /// Platform-specific: Retrieves process by identifier,
  /// following Laravel's repository pattern.
  ProcessContract? get(String id);

  /// Kills a process.
  ///
  /// Platform-specific: Terminates a process with optional signal,
  /// following Laravel's resource cleanup patterns.
  ///
  /// Parameters:
  ///   - [id]: Process ID to kill.
  ///   - [signal]: Signal to send (default: SIGTERM).
  Future<void> kill(String id, {ProcessSignal signal = ProcessSignal.sigterm});

  /// Kills all managed processes.
  ///
  /// Platform-specific: Bulk process termination,
  /// following Laravel's collection operation patterns.
  Future<void> killAll({ProcessSignal signal = ProcessSignal.sigterm});

  /// Gets process events stream.
  ///
  /// Platform-specific: Event streaming following Laravel's
  /// event broadcasting patterns.
  Stream<ProcessEventContract> get events;

  /// Runs processes in a pool.
  ///
  /// Platform-specific: Concurrent process execution following
  /// Laravel's job queue worker pool patterns.
  ///
  /// Parameters:
  ///   - [processes]: Processes to run.
  ///   - [concurrency]: Max concurrent processes.
  Future<List<ProcessResultContract>> pool(
    List<ProcessContract> processes, {
    int concurrency = 5,
  });

  /// Runs processes in a pipeline.
  ///
  /// Platform-specific: Sequential process execution following
  /// Laravel's pipeline pattern.
  Future<ProcessResultContract> pipeline(List<ProcessContract> processes);

  /// Disposes the manager and all processes.
  ///
  /// Platform-specific: Resource cleanup following Laravel's
  /// service provider cleanup patterns.
  void dispose();
}

/// Contract for process instances.
///
/// Platform-specific: Defines individual process behavior following
/// Laravel's resource management patterns.
@sealed
abstract class ProcessContract {
  /// Gets the process command.
  String get command;

  /// Gets the process ID.
  int? get pid;

  /// Gets process start time.
  DateTime? get startTime;

  /// Gets process end time.
  DateTime? get endTime;

  /// Gets process output stream.
  Stream<List<int>> get output;

  /// Gets process error stream.
  Stream<List<int>> get errorOutput;

  /// Gets process exit code.
  Future<int> get exitCode;

  /// Whether the process is running.
  bool get isRunning;

  /// Starts the process.
  Future<ProcessContract> start();

  /// Runs the process to completion.
  Future<ProcessResultContract> run();

  /// Runs the process with a timeout.
  ///
  /// Parameters:
  ///   - [timeout]: Maximum execution time.
  ///
  /// Throws TimeoutException if process exceeds timeout.
  Future<ProcessResultContract> runWithTimeout(Duration timeout);

  /// Writes input to the process.
  Future<void> write(String input);

  /// Writes multiple lines to the process.
  Future<void> writeLines(List<String> lines);

  /// Kills the process.
  Future<void> kill({ProcessSignal signal = ProcessSignal.sigterm});

  /// Sends a signal to the process.
  bool sendSignal(ProcessSignal signal);

  /// Gets process output as string.
  Future<String> get outputAsString;

  /// Gets process error output as string.
  Future<String> get errorOutputAsString;

  /// Disposes the process.
  Future<void> dispose();
}

/// Contract for process results.
///
/// Platform-specific: Defines process execution results following
/// Laravel's response/result patterns.
@sealed
abstract class ProcessResultContract {
  /// Gets the process ID.
  int get pid;

  /// Gets the exit code.
  int get exitCode;

  /// Gets the process output.
  String get output;

  /// Gets the process error output.
  String get errorOutput;

  /// Gets string representation.
  @override
  String toString() {
    return 'ProcessResult(pid: $pid, exitCode: $exitCode, output: ${output.length} chars, errorOutput: ${errorOutput.length} chars)';
  }
}

/// Contract for process events.
///
/// Platform-specific: Defines process lifecycle events following
/// Laravel's event system patterns.
@sealed
abstract class ProcessEventContract {
  /// Gets the process ID.
  String get id;

  /// Gets the event timestamp.
  DateTime get timestamp;
}

/// Contract for process started events.
///
/// Platform-specific: Defines process start event following
/// Laravel's event naming and structure patterns.
@sealed
abstract class ProcessStartedEventContract extends ProcessEventContract {
  /// Gets the started process.
  ProcessContract get process;

  @override
  String toString() =>
      'ProcessStartedEvent(id: $id, command: ${process.command})';
}

/// Contract for process exited events.
///
/// Platform-specific: Defines process exit event following
/// Laravel's event naming and structure patterns.
@sealed
abstract class ProcessExitedEventContract extends ProcessEventContract {
  /// Gets the exit code.
  int get exitCode;

  @override
  String toString() => 'ProcessExitedEvent(id: $id, exitCode: $exitCode)';
}

/// Contract for process pools.
///
/// Platform-specific: Defines concurrent process execution following
/// Laravel's worker pool patterns.
@sealed
abstract class ProcessPoolContract {
  /// Gets maximum concurrent processes.
  int get concurrency;

  /// Gets active processes.
  List<ProcessContract> get active;

  /// Gets pending processes.
  List<ProcessContract> get pending;

  /// Runs processes in the pool.
  Future<List<ProcessResultContract>> run(List<ProcessContract> processes);
}

/// Contract for process pipelines.
///
/// Platform-specific: Defines sequential process execution following
/// Laravel's pipeline pattern.
@sealed
abstract class ProcessPipelineContract {
  /// Gets pipeline processes.
  List<ProcessContract> get processes;

  /// Runs the pipeline.
  Future<ProcessResultContract> run();
}
