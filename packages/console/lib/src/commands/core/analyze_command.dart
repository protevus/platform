import '../base/dart_command.dart';

/// Command to run static analysis across packages
class AnalyzeCommand extends DartCommand {
  @override
  String get name => 'analyze';

  @override
  String get description => 'Run static analysis on packages';

  @override
  String get signature => '''analyze 
{--fail-fast : Stop on first failure}
{--fatal-infos : Treat info level issues as fatal}
{--fatal-warnings : Treat warning level issues as fatal}
{--no-hints : Do not show hint level issues}
{--no-lints : Do not show lint level issues}
{--no-package-updates : Do not check for package updates}''';

  @override
  Future<void> handle() async {
    final args = <String>[];

    // Add flag options
    if (option<bool>('fail-fast') == true) args.add('--fail-fast');
    if (option<bool>('fatal-infos') == true) args.add('--fatal-infos');
    if (option<bool>('fatal-warnings') == true) args.add('--fatal-warnings');
    if (option<bool>('no-hints') == true) args.add('--no-hints');
    if (option<bool>('no-lints') == true) args.add('--no-lints');
    if (option<bool>('no-package-updates') == true)
      args.add('--no-package-updates');

    try {
      output.newLine();
      output.info('Running static analysis...');
      output.writeln('----------------------------------------');

      // Run analyze with interactive mode for proper output
      await executeAnalyze(
        args: args,
        interactive: true,
        throwOnNonZero: false,
      );

      output.newLine();
      output.success('Analysis completed successfully');
    } catch (e) {
      output.newLine();
      output.error('Analysis failed - see output above for details');
      rethrow;
    }
  }
}
