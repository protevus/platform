import '../base/melos_command.dart';

/// Command to display package paths using melos environment variables
class DebugPkgpathCommand extends MelosCommand {
  @override
  String get name => 'debug:pkgpath';

  @override
  String get description =>
      'Display package paths using melos environment variables';

  @override
  String get signature =>
      'debug:pkgpath {--scope=* : Only show package paths for packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Showing package path for: $scope');
      } else {
        output.info('Showing package paths for all packages...');
      }

      // Execute the command
      await executeMelos(
        'exec',
        args: ['--', 'echo', 'Package path is {MELOS_PACKAGE_PATH}'],
        scope: scope,
        throwOnNonZero: true,
      );

      output.success('Package paths displayed successfully');
    } catch (e) {
      output.error(
          'Failed to display package paths - see output above for details');
      rethrow;
    }
  }
}
