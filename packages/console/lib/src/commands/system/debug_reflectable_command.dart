import '../melos/melos_command.dart';

/// Command to find .reflectable.dart files in packages
class DebugReflectableCommand extends MelosCommand {
  @override
  String get name => 'debug:reflectable';

  @override
  String get description => 'Find .reflectable.dart files in packages';

  @override
  String get signature =>
      'debug:reflectable {--scope=* : Only check packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Checking for .reflectable.dart files in package: $scope');
      } else {
        output.info('Checking for .reflectable.dart files in all packages...');
      }

      // Execute the command
      await executeMelos(
        'exec',
        args: [
          '--',
          'bash',
          '-c',
          'echo "Checking for .reflectable.dart files in {MELOS_PACKAGE_NAME}"; find lib test example -name "*.reflectable.dart" -print 2>/dev/null || true'
        ],
        scope: scope,
        throwOnNonZero: false, // Don't throw if no files found
      );

      output.success('Reflectable files check completed');
    } catch (e) {
      output.error(
          'Failed to check for reflectable files - see output above for details');
      rethrow;
    }
  }
}
