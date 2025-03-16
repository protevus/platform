import 'dart:io';
import 'dart:convert';
import '../../command.dart';

/// Base class for commands that use mkdocs under the hood.
abstract class MkDocsCommand extends Command {
  /// Execute a mkdocs command with the given arguments.
  Future<int> executeMkDocs(
    String command, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    if (interactive) {
      return await executeInteractiveMkDocs(
        command,
        args: args,
        throwOnNonZero: throwOnNonZero,
        env: env,
      );
    }

    final mkdocsArgs = [
      command,
      ...args,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);

    final process = await Process.start(
      'mkdocs',
      mkdocsArgs,
      environment: environment,
    );

    // Stream stdout in real-time
    process.stdout.transform(utf8.decoder).listen((data) {
      output.write(data);
    });

    // Stream stderr in real-time
    process.stderr.transform(utf8.decoder).listen((data) {
      output.error(data);
    });

    // Wait for the process to complete and get exit code
    final exitCode = await process.exitCode;

    if (throwOnNonZero && exitCode != 0) {
      throw Exception('MkDocs command failed with exit code $exitCode');
    }

    return exitCode;
  }

  /// Execute an interactive mkdocs command with the given arguments.
  /// This method inherits stdio to properly handle user input.
  Future<int> executeInteractiveMkDocs(
    String command, {
    List<String> args = const [],
    bool throwOnNonZero = true,
    Map<String, String>? env,
  }) async {
    final mkdocsArgs = [
      command,
      ...args,
    ];

    // Merge provided env with current process env
    final environment = {...Platform.environment};
    if (env != null) environment.addAll(env);

    // Create a process that inherits stdio for interactive input
    final process = await Process.start(
      'mkdocs',
      mkdocsArgs,
      mode: ProcessStartMode.inheritStdio,
      environment: environment,
    );

    // Wait for the process to complete and get exit code
    final exitCode = await process.exitCode;

    if (throwOnNonZero && exitCode != 0) {
      throw Exception('MkDocs command failed with exit code $exitCode');
    }

    return exitCode;
  }

  /// Serve documentation on the specified port.
  Future<int> serve({
    int port = 8000,
    bool livereload = true,
    bool strict = false,
    bool dirtyReload = false,
    String? devAddr,
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = true,
  }) async {
    final args = [
      '--dev-addr',
      devAddr ?? '0.0.0.0:$port',
      if (!livereload) '--no-livereload',
      if (strict) '--strict',
      if (dirtyReload) '--dirtyreload',
    ];

    return await executeMkDocs(
      'serve',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Build documentation.
  Future<int> build({
    bool clean = false,
    bool strict = false,
    String? sitedir,
    bool quiet = false,
    bool useDirectoryUrls = true,
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = false,
  }) async {
    final args = [
      if (clean) '--clean',
      if (strict) '--strict',
      if (sitedir != null) ...['-d', sitedir],
      if (quiet) '--quiet',
      if (!useDirectoryUrls) '--no-directory-urls',
    ];

    return await executeMkDocs(
      'build',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Deploy documentation to GitHub Pages.
  Future<int> ghDeploy({
    bool clean = false,
    bool strict = false,
    String? message,
    bool force = false,
    bool ignorePath = false,
    bool noDirtyReload = false,
    bool throwOnNonZero = true,
    Map<String, String>? env,
    bool interactive = true,
  }) async {
    final args = [
      if (clean) '--clean',
      if (strict) '--strict',
      if (message != null) ...['-m', message],
      if (force) '--force',
      if (ignorePath) '--ignore-version',
      if (noDirtyReload) '--no-directory-urls',
    ];

    return await executeMkDocs(
      'gh-deploy',
      args: args,
      throwOnNonZero: throwOnNonZero,
      env: env,
      interactive: interactive,
    );
  }

  /// Get MkDocs version.
  Future<String?> getVersion({
    bool throwOnNonZero = true,
    Map<String, String>? env,
  }) async {
    final process = await Process.start(
      'mkdocs',
      ['--version'],
      environment: env ?? Platform.environment,
    );

    final output = await process.stdout.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;

    if (throwOnNonZero && exitCode != 0) {
      throw Exception('Failed to get MkDocs version');
    }

    // Extract version from output (e.g. "mkdocs, version 1.4.2")
    final match = RegExp(r'version (\d+\.\d+\.\d+)').firstMatch(output);
    return match?.group(1);
  }

  /// Check if MkDocs is installed and available.
  Future<bool> isInstalled() async {
    try {
      await getVersion(throwOnNonZero: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}
