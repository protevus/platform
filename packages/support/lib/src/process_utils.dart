import 'dart:convert';
import 'dart:io';

/// A class that provides utilities for process management and execution.
///
/// This class offers functionality to safely escape command arguments and
/// execute system commands in a controlled manner.
class ProcessUtils {
  /// Private constructor to prevent instantiation
  ProcessUtils._();

  /// Characters that need escaping in shell arguments.
  static const List<String> _specialChars = [
    ' ',
    '\t',
    '\n',
    '\r',
    '\f',
    '\v',
    '"',
    "'",
    r'\',
    r'$',
    '`',
  ];

  /// Escape a string to be used as a shell argument.
  static String escape(String argument) {
    if (argument.isEmpty) {
      return '""';
    }
    if (Platform.isWindows) {
      // On Windows, wrap with quotes if contains spaces
      if (argument.contains(' ')) {
        return _escapeWindowsArgument(argument);
      }
      return argument;
    }
    // On Unix-like systems, escape special characters
    return _escapeUnixArgument(argument);
  }

  /// Escape an argument for Windows.
  static String _escapeWindowsArgument(String argument) {
    if (argument.contains('"')) {
      final escaped = argument.replaceAll('"', r'\"');
      return '"$escaped"';
    }
    return '"$argument"';
  }

  /// Escape an argument for Unix-like systems.
  static String _escapeUnixArgument(String argument) {
    if (!_specialChars.any((char) => argument.contains(char))) {
      return argument;
    }

    final buffer = StringBuffer();
    for (final char in argument.split('')) {
      if (_specialChars.contains(char)) {
        buffer.write('\\');
      }
      buffer.write(char);
    }
    return buffer.toString();
  }

  /// Escape an array of arguments to be used as shell arguments.
  static List<String> escapeArray(List<String> arguments) {
    return List<String>.from(arguments.map(escape));
  }

  /// Execute a command and return its output.
  static Future<ProcessResult> run(
    String command,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding stdoutEncoding = systemEncoding,
    Encoding stderrEncoding = systemEncoding,
  }) async {
    try {
      return await Process.run(
        command,
        escapeArray(arguments),
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding,
      );
    } on ProcessException catch (e) {
      throw ProcessException(
        e.executable,
        e.arguments,
        'Failed to execute process: ${e.message}',
        e.errorCode,
      );
    }
  }

  /// Start a process and return a [Process] object.
  static Future<Process> start(
    String command,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    try {
      return await Process.start(
        command,
        escapeArray(arguments),
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        mode: mode,
      );
    } on ProcessException catch (e) {
      throw ProcessException(
        e.executable,
        e.arguments,
        'Failed to start process: ${e.message}',
        e.errorCode,
      );
    }
  }

  /// Execute a command and stream its output.
  static Future<int> stream(
    String command,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    void Function(String)? onOutput,
    void Function(String)? onError,
  }) async {
    final process = await start(
      command,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
    );

    process.stdout.listen(
      (data) {
        final output = String.fromCharCodes(data).trim();
        if (output.isNotEmpty) {
          onOutput?.call(output);
        }
      },
    );

    process.stderr.listen(
      (data) {
        final error = String.fromCharCodes(data).trim();
        if (error.isNotEmpty) {
          onError?.call(error);
        }
      },
    );

    return await process.exitCode;
  }

  /// Kill a process and all its subprocesses.
  static Future<void> kill(
    Process process, [
    ProcessSignal signal = ProcessSignal.sigterm,
  ]) async {
    if (Platform.isWindows) {
      await run('taskkill', ['/F', '/T', '/PID', process.pid.toString()]);
    } else {
      process.kill(signal);
    }
  }

  /// Check if a process is still running.
  static Future<bool> isRunning(Process process) async {
    try {
      return process.exitCode.then((_) => false).timeout(
            Duration.zero,
            onTimeout: () => true,
          );
    } catch (_) {
      return false;
    }
  }
}
