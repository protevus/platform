import '../melos/melos_command.dart';

/// Command to generate API documentation for packages
class DocsApiCommand extends MelosCommand {
  @override
  String get name => 'docs:api';

  @override
  String get description => 'Generate API documentation for packages';

  @override
  String get signature =>
      'docs:api {--scope=* : Only generate documentation for packages matching the given name pattern} {--concurrency=1 : Number of packages to process concurrently}';

  @override
  Future<void> handle() async {
    try {
      output.info('Generating API documentation...');

      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Generating docs for packages matching: $scope');
      }

      // Get concurrency option
      final concurrency =
          int.tryParse(option<String>('concurrency') ?? '1') ?? 1;

      // Build command args
      final args = ['--', 'dart', 'doc', '.'];

      // Execute the docs:generate command
      await executeMelos(
        'exec',
        args: args,
        scope: scope,
        concurrency: concurrency,
        throwOnNonZero: true,
      );

      output.success('API documentation generated successfully');
      output.info(
          'Documentation is available in the doc/ directory of each package');
    } catch (e) {
      output.error(
          'Failed to generate API documentation - see output above for details');
      rethrow;
    }
  }
}
