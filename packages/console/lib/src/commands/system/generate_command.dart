import 'package:illuminate_console/console.dart';
import '../melos/melos_command.dart';

/// Command to run code generation across packages
class MelosGenerateCommand extends MelosCommand {
  /// Command arguments
  Map<String, dynamic> arguments = {};

  @override
  Future<void> handle() async {
    await execute();
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Run code generation for packages';

  @override
  String get help => '''
Run code generation across packages in the monorepo.

Usage: artisan generate [options]

Options:
  --scope=<package>  Run code generation only for specific package(s)
  --fail-fast       Stop on first failure
''';

  @override
  Future<void> execute() async {
    final scope = arguments['scope'] as String?;
    final failFast = arguments.containsKey('fail-fast');

    await executeMelos(
      'run',
      args: ['generate:custom'],
      scope: scope,
      failFast: failFast,
    );
  }
}
