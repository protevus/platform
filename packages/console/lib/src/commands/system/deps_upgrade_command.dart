import '../melos/melos_command.dart';

/// Command to upgrade dependencies across packages
class DepsUpgradeCommand extends MelosCommand {
  @override
  String get name => 'deps:upgrade';

  @override
  String get description => 'Upgrade dependencies across packages';

  @override
  String get signature =>
      'deps:upgrade {--scope=* : Only upgrade dependencies in packages matching the given name pattern} {--major-versions : Allow upgrading to major versions}';

  @override
  Future<void> handle() async {
    try {
      output.info('Upgrading dependencies...');

      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Upgrading packages matching: $scope');
      }

      // Build the upgrade command
      final command = option<bool>('major-versions') == true
          ? 'dart pub upgrade --major-versions'
          : 'dart pub upgrade';

      // Execute the upgrade
      await melosExec(
        command,
        scope: scope,
        failFast: true,
      );

      output.success('Dependencies upgraded successfully');
    } catch (e) {
      output.error(
          'Failed to upgrade dependencies - see output above for details');
      rethrow;
    }
  }
}
