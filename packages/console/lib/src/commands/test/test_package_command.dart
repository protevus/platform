import '../melos/melos_command.dart';

/// Command to run tests for a specific package.
class TestPackageCommand extends MelosCommand {
  @override
  String get name => 'test:package';

  @override
  String get description => 'Run tests for a specific package';

  @override
  String get signature => '''test:package 
{package : The package to run tests for}
{--watch : Watch for changes and rerun tests}
{--filter= : Filter tests by name or file pattern}
{--coverage : Generate coverage reports}
{--chain-stack-traces : Show full stack traces for errors}''';

  @override
  Future<void> handle() async {
    final package = argument<String>('package');
    final watch = option<bool>('watch') ?? false;
    final filter = option<String>('filter');
    final coverage = option<bool>('coverage') ?? false;
    final chainStackTraces = option<bool>('chain-stack-traces') ?? false;

    try {
      output.newLine();
      final fullPackage = 'illuminate_$package';
      output.info('Running tests for package: $fullPackage');
      if (filter != null) output.info('Filter: $filter');
      output.writeln('----------------------------------------');

      try {
        // Run tests using melos exec
        await melosExecDirect(
          [
            'dart',
            'test',
            if (watch) '--watch',
            if (filter != null) '--name',
            if (filter != null) filter,
            if (chainStackTraces) '--chain-stack-traces',
            '--color',
          ],
          scope: fullPackage,
          failFast: true,
          concurrency: 1,
        );

        // Handle coverage if requested
        if (coverage) {
          output.info('Generating coverage report...');

          // Add coverage package
          await melosExecDirect(
            ['dart', 'pub', 'add', '--dev', 'coverage'],
            scope: fullPackage,
          );

          // Activate coverage
          await melosExecDirect(
            ['dart', 'pub', 'global', 'activate', 'coverage'],
            scope: fullPackage,
          );

          // Generate coverage report
          await melosExecDirect(
            [
              'dart',
              'pub',
              'global',
              'run',
              'coverage:format_coverage',
              '--lcov',
              '--in=coverage',
              '--out=coverage/lcov.info',
              '--packages=.dart_tool/package_config.json',
              '--report-on=lib',
            ],
            scope: fullPackage,
          );

          // Remove coverage package
          await melosExecDirect(
            ['dart', 'pub', 'remove', 'coverage'],
            scope: fullPackage,
          );
        }
        output.newLine();
        output.success('Tests completed successfully');

        if (coverage) {
          output.info('Coverage report generated at coverage/lcov.info');
        }
      } catch (e) {
        output.newLine();
        output.error('Tests failed - see output above for details');
        return;
      }
    } catch (e) {
      output.newLine();
      output.error('Error running tests: $e');
      rethrow;
    }
  }
}
