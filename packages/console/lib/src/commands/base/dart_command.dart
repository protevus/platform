import 'dart:io';
import 'package:illuminate_console/console.dart';

/// Base class for commands that use dart under the hood.
abstract class DartCommand extends Command {
  /// Execute a dart command with the given arguments.
  Future<int> executeDart(
    String command, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    if (interactive) {
      return await executeInteractiveDart(
        command,
        args: args,
        throwOnNonZero: throwOnNonZero,
        env: env,
      );
    }

    final dartArgs = [
      command,
      ...args,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);

    final process = await Process.start(
      'dart',
      dartArgs,
      environment: environment,
    );

    // Stream stdout in real-time
    process.stdout.transform(const SystemEncoding().decoder).listen((data) {
      output.write(data);
    });

    // Stream stderr in real-time
    process.stderr.transform(const SystemEncoding().decoder).listen((data) {
      output.error(data);
    });

    // Wait for the process to complete and get exit code
    final exitCode = await process.exitCode;

    if (throwOnNonZero && exitCode != 0) {
      throw Exception('Dart command failed with exit code $exitCode');
    }

    return exitCode;
  }

  /// Execute an interactive dart command with the given arguments.
  /// This method inherits stdio to properly handle user input.
  Future<int> executeInteractiveDart(
    String command, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
  }) async {
    final dartArgs = [
      command,
      ...args,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);

    // Create a process that inherits stdio for interactive input
    final process = await Process.start(
      'dart',
      dartArgs,
      mode: ProcessStartMode.inheritStdio,
      environment: environment,
    );

    // Wait for the process to complete and get exit code
    final exitCode = await process.exitCode;

    if (throwOnNonZero && exitCode != 0) {
      throw Exception('Dart command failed with exit code $exitCode');
    }

    return exitCode;
  }

  /// Execute a pub command with the given arguments.
  Future<int> executePub(
    String command, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'pub',
      args: [command, ...args],
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Execute a test command with the given arguments.
  Future<int> executeTest({
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'test',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Execute a run command with the given arguments.
  Future<int> executeRun(
    String target, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'run',
      args: [target, ...args],
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Execute a compile command with the given arguments.
  Future<int> executeCompile(
    String target, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'compile',
      args: [target, ...args],
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Execute a format command with the given arguments.
  Future<int> executeFormat({
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'format',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Execute an analyze command with the given arguments.
  Future<int> executeAnalyze({
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    return await executeDart(
      'analyze',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }
}
