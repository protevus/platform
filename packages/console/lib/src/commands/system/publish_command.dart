import '../melos/melos_command.dart';

/// Command to publish packages that have changed
class PublishCommand extends MelosCommand {
  @override
  String get name => 'publish';

  @override
  String get description => 'Publish packages that have changed';

  @override
  String get signature =>
      'publish {--dry-run : Check which packages would be published without actually publishing} {--no-dry-run : Actually publish the packages} {--git-tag-version : Create git tags for published versions}';

  @override
  Future<void> handle() async {
    final args = <String>[];

    // Map command options to melos args
    if (option<bool>('dry-run') == true) args.add('--dry-run');
    if (option<bool>('no-dry-run') == true) args.add('--no-dry-run');
    if (option<bool>('git-tag-version') == true) args.add('--git-tag-version');

    try {
      // Show what we're about to do
      if (option<bool>('dry-run') == true) {
        output.info('Checking which packages would be published (dry run)...');
      } else {
        output.info('Publishing packages...');
      }

      // Execute melos publish command
      final exitCode =
          await executeMelos('publish', args: args, throwOnNonZero: false);

      // Handle result
      if (exitCode == 0) {
        if (option<bool>('dry-run') == true) {
          output.success('Publish check completed successfully');
        } else {
          output.success('Packages published successfully');
        }
      } else if (option<bool>('dry-run') == true) {
        // For dry run, just show info since cancellation is expected
        output.info(
            'Publish check completed - see above for what would be published');
      } else {
        output
            .error('Failed to publish packages - see output above for details');
        throw Exception('Publish command failed with exit code $exitCode');
      }
    } catch (e) {
      if (option<bool>('dry-run') != true) {
        output
            .error('Failed to publish packages - see output above for details');
        rethrow;
      }
    }
  }
}
