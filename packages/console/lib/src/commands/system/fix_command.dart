import '../melos/melos_command.dart';

/// Command to apply automated fixes to Dart source code
class FixCommand extends MelosCommand {
  @override
  String get name => 'fix';

  @override
  String get description => 'Apply automated fixes to Dart source code';

  @override
  String get signature =>
      'fix {--scope=* : Only fix packages matching the given name pattern} {--dry-run : Show which changes would be made but make no changes} {--apply : Apply the proposed changes} {--code= : Only fix a specific diagnostic code}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Fixing package: $scope');
      } else {
        output.info('Fixing all packages...');
      }

      // Handle run mode
      final isDryRun = option<bool>('dry-run') ?? false;
      final shouldApply = option<bool>('apply') ?? false;

      if (isDryRun && shouldApply) {
        throw Exception(
            'Cannot use both --dry-run and --apply at the same time');
      }

      if (isDryRun) {
        output.info('Running in dry-run mode. No changes will be made.');
      } else if (shouldApply) {
        output.info('Running in apply mode. Changes will be made.');
      } else {
        output.info(
            'Running in default mode. Use --dry-run to preview changes or --apply to make changes.');
      }

      // Execute the command
      await executeMelos(
        'exec',
        args: [
          '--fail-fast',
          '--',
          'dart',
          'fix',
          if (isDryRun) '--dry-run',
          if (shouldApply) '--apply',
          if (option<String>('code') != null) ...[
            '--code=${option<String>('code')}',
          ],
          '.',
        ],
        scope: scope,
        throwOnNonZero: true,
      );

      if (isDryRun) {
        output.success('Dry run completed successfully');
      } else if (shouldApply) {
        output.success('Applied fixes successfully');
      } else {
        output.success('Fix completed successfully');
      }
    } catch (e) {
      output.error('Failed to apply fixes - see output above for details');
      rethrow;
    }
  }
}
