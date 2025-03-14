import '../base/melos_command.dart';

/// Command to run tests across all packages.
class TestCommand extends MelosCommand {
  @override
  String get name => 'test';

  @override
  String get description => 'Run tests across all packages';

  @override
  String get signature => '''test 
{--watch : Watch for changes and rerun tests}
{--filter= : Filter tests by name or file pattern}
{--chain-stack-traces : Show full stack traces for errors}''';

  @override
  Future<void> handle() async {
    final watch = option<bool>('watch') ?? false;
    final filter = option<String>('filter');
    final chainStackTraces = option<bool>('chain-stack-traces') ?? false;

    try {
      output.newLine();
      output.info('Running tests for all packages');
      if (filter != null) output.info('Filter: $filter');
      output.writeln('----------------------------------------');

      final commandParts = [
        'dart',
        'test',
        if (watch) '--watch',
        if (filter != null) '--name',
        if (filter != null) filter,
        if (chainStackTraces) '--chain-stack-traces',
        '--color',
      ];

      try {
        await melosExecDirect(
          commandParts,
          failFast: true,
          concurrency: 1,
        );
        output.newLine();
        output.success('All tests completed successfully');
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
