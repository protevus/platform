import 'dart:io';
import '../base/melos_command.dart';

/// Command to run static analysis across packages
class AnalyzeCommand extends MelosCommand {
  /// Command arguments
  Map<String, dynamic> arguments = {};

  @override
  Future<void> handle() async {
    await execute();
  }

  @override
  String get name => 'analyze';

  @override
  String get description => 'Run static analysis on packages';

  @override
  String get help => '''
Run static analysis across packages in the monorepo.

Usage: artisan analyze [options]

Options:
  --scope=<package>  Run analysis only for specific package(s)
  --fail-fast       Stop on first failure
''';

  @override
  Future<void> execute() async {
    final scope = arguments['scope'] as String?;
    final failFast = arguments.containsKey('fail-fast');

    final exitCode = await executeMelos(
      'run',
      args: ['analyze'],
      scope: scope,
      failFast: failFast,
      throwOnNonZero: false,
    );

    // Exit with the same code as the analyze command
    exit(exitCode);
  }
}
