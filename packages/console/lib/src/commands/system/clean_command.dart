import 'package:illuminate_console/console.dart';
import '../melos/melos_command.dart';

/// Command to clean build artifacts and generated files
class MelosCleanCommand extends MelosCommand {
  /// Command arguments
  Map<String, dynamic> arguments = {};

  @override
  Future<void> handle() async {
    await execute();
  }

  @override
  String get name => 'clean';

  @override
  String get description => 'Clean build artifacts and generated files';

  @override
  String get help => '''
Clean build artifacts and generated files across packages in the monorepo.

Usage: artisan clean [options]

Options:
  --scope=<package>  Clean only specific package(s)
  --fail-fast       Stop on first failure
''';

  Future<void> execute() async {
    final scope = arguments['scope'] as String?;
    final failFast = arguments.containsKey('fail-fast');

    await executeMelos(
      'run',
      args: ['clean'],
      scope: scope,
      failFast: failFast,
    );
  }
}
