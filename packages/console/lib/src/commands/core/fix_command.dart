import '../base/dart_command.dart';

/// Command to apply automated fixes to Dart source code
class FixCommand extends DartCommand {
  @override
  String get name => 'fix';

  @override
  String get description => 'Apply automated fixes to Dart source code';

  @override
  String get signature => '''fix 
{--dry-run : Show which changes would be made but make no changes}
{--apply : Apply the proposed changes}
{--code= : Only fix a specific diagnostic code}
{--fail-fast : Stop on first failure}
{--verbose : Show detailed output}
{--target= : Target directory or file to fix}''';

  @override
  Future<void> handle() async {
    try {
      final args = <String>[];

      // Handle run mode
      final isDryRun = option<bool>('dry-run') ?? false;
      final shouldApply = option<bool>('apply') ?? false;

      if (isDryRun && shouldApply) {
        throw Exception(
            'Cannot use both --dry-run and --apply at the same time');
      }

      if (isDryRun) {
        output.info('Running in dry-run mode. No changes will be made.');
        args.add('--dry-run');
      } else if (shouldApply) {
        output.info('Running in apply mode. Changes will be made.');
        args.add('--apply');
      } else {
        output.info(
            'Running in default mode. Use --dry-run to preview changes or --apply to make changes.');
      }

      // Add optional flags
      if (option<bool>('fail-fast') == true) args.add('--fail-fast');
      if (option<bool>('verbose') == true) args.add('--verbose');

      // Add code filter if specified
      final code = option<String>('code');
      if (code != null) {
        args.add('--code=$code');
      }

      // Add target path
      final target = option<String>('target') ?? '.';
      args.add(target);

      output.newLine();
      output.info('Running dart fix...');
      output.writeln('----------------------------------------');

      // Run fix command with interactive mode for proper output
      await executeDart(
        'fix',
        args: args,
        interactive: true,
        throwOnNonZero: false,
      );

      output.newLine();
      if (isDryRun) {
        output.success('Dry run completed successfully');
      } else if (shouldApply) {
        output.success('Applied fixes successfully');
      } else {
        output.success('Fix completed successfully');
      }
    } catch (e) {
      output.newLine();
      output.error('Failed to apply fixes - see output above for details');
      rethrow;
    }
  }
}
