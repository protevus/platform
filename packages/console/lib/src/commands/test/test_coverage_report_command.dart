import '../melos/melos_command.dart';

/// Command to generate HTML coverage reports from LCOV data
class TestCoverageReportCommand extends MelosCommand {
  @override
  String get name => 'test:coverage:report';

  @override
  String get description =>
      'Generate HTML coverage report from LCOV data for each package';

  @override
  String get signature =>
      'test:coverage:report {--scope=* : Only generate coverage for packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Generating coverage report for package: $scope');
      } else {
        output.info('Generating coverage reports for all packages...');
      }

      // Execute the command
      await executeMelos(
        'exec',
        args: [
          '-c',
          '1',
          '--fail-fast',
          '--',
          'bash',
          '-c',
          'cat << \'EOF\' | bash\nif [ -s coverage/lcov.info ]; then\n  genhtml -o coverage_report coverage/lcov.info\n  echo "Coverage report generated successfully."\nelse\n  echo "No valid coverage data found. Skipping report generation."\nfi\nEOF'
        ],
        scope: scope,
        throwOnNonZero: false, // Don't throw if no coverage data found
      );

      output.success('Coverage report generation completed');
    } catch (e) {
      output.error(
          'Failed to generate coverage reports - see output above for details');
      rethrow;
    }
  }
}
