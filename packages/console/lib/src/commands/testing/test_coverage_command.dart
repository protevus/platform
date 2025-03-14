import '../base/melos_command.dart';

/// Command to run tests with coverage and generate LCOV reports
class TestCoverageCommand extends MelosCommand {
  @override
  String get name => 'test:coverage';

  @override
  String get description =>
      'Run tests with coverage and generate LCOV report for each package';

  @override
  String get signature =>
      'test:coverage {--scope=* : Only run coverage for packages matching the given name pattern}';

  @override
  Future<void> handle() async {
    try {
      // Handle scoped execution
      final scopes = option<List<String>>('scope');
      String? scope;
      if (scopes != null && scopes.isNotEmpty) {
        scope = scopes.first;
        output.info('Running coverage for package: $scope');
      } else {
        output.info('Running coverage for all packages...');
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
          '''
          set -e  # Exit on errors for package operations
          dart pub add --dev coverage
          dart pub global activate coverage
          
          # Run tests with coverage (allow failures)
          set +e
          dart test --coverage=coverage
          set -e
          
          # Generate coverage report
          dart pub global run coverage:format_coverage -l --packages=.dart_tool/package_config.json --report-on=lib/ -i coverage -o coverage/lcov.info
          dart pub remove coverage
          '''
        ],
        scope: scope,
        throwOnNonZero: true,
      );

      output.success('Coverage completed successfully');
      output.info('LCOV reports are available in coverage/lcov.info');
      output.info('Run test:coverage:report to generate HTML reports');
    } catch (e) {
      output.error('Failed to run coverage - see output above for details');
      rethrow;
    }
  }
}
