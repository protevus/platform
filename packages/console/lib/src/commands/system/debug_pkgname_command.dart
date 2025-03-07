import '../melos/melos_command.dart';

/// Command to display package names using melos environment variables
class DebugPkgnameCommand extends MelosCommand {
  @override
  String get name => 'debug:pkgname';

  @override
  String get description =>
      'Display package names using melos environment variables';

  @override
  String get signature =>
      'debug:pkgname {--scope=* : Only show package names for packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Showing package name for: $scope');
      } else {
        output.info('Showing package names for all packages...');
      }

      // Execute the command
      await executeMelos(
        'exec',
        args: ['--', 'echo', 'Package name is {MELOS_PACKAGE_NAME}'],
        scope: scope,
        throwOnNonZero: true,
      );

      output.success('Package names displayed successfully');
    } catch (e) {
      output.error(
          'Failed to display package names - see output above for details');
      rethrow;
    }
  }
}
