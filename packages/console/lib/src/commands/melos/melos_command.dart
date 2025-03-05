import 'dart:io';
import 'package:illuminate_console/console.dart';

/// Base class for commands that use melos under the hood.
abstract class MelosCommand extends Command {
  /// Execute a melos command with the given arguments.
  Future<int> executeMelos(
    String command, {
    List<String> args = const [],
    String? scope,
    bool failFast = false,
    int? concurrency,
    bool throwOnNonZero = true,
    Map<String, String>? env,
  }) async {
    final melosArgs = [
      command,
      if (scope != null) '--scope=$scope',
      if (failFast) '--fail-fast',
      if (concurrency != null) '-c',
      if (concurrency != null) '$concurrency',
      ...args,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);
    if (scope != null) environment['MELOS_SCOPE'] = scope;

    final process = await Process.start(
      'melos',
      melosArgs,
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
      throw Exception('Melos command failed with exit code $exitCode');
    }

    return exitCode;
  }

  /// Execute a command in all or specific packages using melos exec.
  Future<int> melosExec(
    String command, {
    String? scope,
    bool failFast = false,
    int? concurrency,
    bool throwOnNonZero = true,
  }) async {
    return await executeMelos(
      'exec',
      args: ['--', command],
      scope: scope,
      failFast: failFast,
      concurrency: concurrency,
    );
  }

  /// Run a command directly with melos exec.
  Future<int> melosExecDirect(
    List<String> commandParts, {
    String? scope,
    bool failFast = false,
    int? concurrency,
    bool throwOnNonZero = true,
    Map<String, String>? env,
  }) async {
    final melosArgs = [
      'exec',
      if (scope != null) '--scope=$scope',
      if (failFast) '--fail-fast',
      if (concurrency != null) '-c',
      if (concurrency != null) '$concurrency',
      '--',
      ...commandParts,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);
    if (scope != null) environment['MELOS_SCOPE'] = scope;

    final process = await Process.start(
      'melos',
      melosArgs,
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
      throw Exception('Melos command failed with exit code $exitCode');
    }

    return exitCode;
  }
}
