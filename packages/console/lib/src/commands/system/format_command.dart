import '../melos/melos_command.dart';

/// Command to format all Dart files in the repository
class FormatCommand extends MelosCommand {
  @override
  String get name => 'format';

  @override
  String get description => 'Format all Dart files in the repository';

  @override
  String get signature => '''format 
{--line-length= : Wrap lines longer than this length}
{--output=show : Show output (show), write to files (write), or write with colored diffs (diff)}
{--set-exit-if-changed : Return exit code 1 if there were any formatting changes}
{--fix : Apply all style fixes}''';

  @override
  Future<void> handle() async {
    try {
      output.newLine();
      output.info('Formatting Dart files...');
      output.writeln('----------------------------------------');

      final lineLength = option<String>('line-length');
      final outputMode = option<String>('output');
      final setExitIfChanged = option<bool>('set-exit-if-changed') ?? false;
      final fix = option<bool>('fix') ?? false;

      final args = [
        'dart',
        'format',
        '.',
        if (lineLength != null) '--line-length=$lineLength',
        if (outputMode != null) '--output=$outputMode',
        if (setExitIfChanged) '--set-exit-if-changed',
        if (fix) '--fix',
      ];

      await melosExec(args.join(' '), throwOnNonZero: false);

      output.newLine();
      output.success('Formatting completed successfully');
    } catch (e) {
      output.error('Formatting failed - see output above for details');
      rethrow;
    }
  }
}
