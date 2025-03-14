import '../base/melos_command.dart';

/// Command to list Dart files in packages
class ListFilesCommand extends MelosCommand {
  @override
  String get name => 'list:files';

  @override
  String get description => 'List Dart files in packages';

  @override
  String get signature =>
      'list:files {--scope=* : Only list files for packages matching the given name pattern} {--relative : Show paths relative to package root} {--generated : Include generated files}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Listing Dart files for package: $scope');
      } else {
        output.info('Listing Dart files for all packages...');
      }

      // Build command
      final findCmd = [
        'find',
        '.',
        '-type',
        'f',
        '-name',
        '"*.dart"',
      ];

      // Exclude generated files unless specified
      if (option<bool>('generated') != true) {
        findCmd.addAll([
          '!',
          '-path',
          '*/.dart_tool/*',
          '!',
          '-path',
          '*/build/*',
          '!',
          '-path',
          '*/.pub-cache/*',
        ]);
      }

      // Build full command with relative path handling and sorting
      final cmd = option<bool>('relative') == true
          ? '${findCmd.join(' ')} | grep "\\.dart\$" | sed "s|^\\./||" | sort'
          : '${findCmd.join(' ')} | grep "\\.dart\$" | sort';

      // Execute the command through bash
      await executeMelos(
        'exec',
        args: ['--', 'bash', '-c', cmd],
        scope: scope,
        throwOnNonZero: true,
      );

      output.success('Dart files listed successfully');
    } catch (e) {
      output.error('Failed to list Dart files - see output above for details');
      rethrow;
    }
  }
}
