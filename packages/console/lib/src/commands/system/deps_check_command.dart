import '../melos/melos_command.dart';

/// Command to check for outdated dependencies across packages
class DepsCheckCommand extends MelosCommand {
  @override
  String get name => 'deps:check';

  @override
  String get description => 'Check for outdated dependencies across packages';

  @override
  String get signature =>
      'deps:check {--scope=* : Only check dependencies in packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      output.info('Checking for outdated dependencies...');

      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Checking packages matching: $scope');
      }

      // Execute the outdated check
      await melosExec(
        'dart pub outdated',
        scope: scope,
        failFast: true,
      );

      output.success('Dependency check completed successfully');
    } catch (e) {
      output
          .error('Failed to check dependencies - see output above for details');
      rethrow;
    }
  }
}
