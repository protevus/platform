import '../base/melos_command.dart';

/// Command to serve generated API documentation
class ApiServeCommand extends MelosCommand {
  @override
  String get name => 'api:serve';

  @override
  String get description => 'Serve generated API documentation';

  @override
  String get signature =>
      'api:serve {--scope=* : Only serve documentation for packages matching the given name pattern} {--port=8080 : Port to serve documentation on}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Serving docs for packages matching: $scope');
      } else {
        output.info('Serving documentation for all packages...');
      }

      // Get port option
      final port = option<String>('port') ?? '8080';

      // Build command args
      final args = ['--'];
      args.addAll(['dhttpd', '--path', 'doc/api']);
      args.addAll(['--port', port]);

      // Check if documentation exists
      final checkResult = await executeMelos(
        'exec',
        args: [
          '--',
          'test',
          '-d',
          'doc/api',
        ],
        scope: scope,
        throwOnNonZero: false,
      );

      // Check if docs exist
      if (checkResult != 0) {
        output.warning(
            'Documentation not found. Run docs:api first to generate documentation.');
        return;
      }

      // Execute the serve command
      await executeMelos(
        'exec',
        args: args,
        scope: scope,
        throwOnNonZero: true,
      );

      output.success('Documentation server started successfully');
      output.info('View documentation at http://localhost:$port');
    } catch (e) {
      output.error(
          'Failed to start documentation server - see output above for details');
      rethrow;
    }
  }
}
