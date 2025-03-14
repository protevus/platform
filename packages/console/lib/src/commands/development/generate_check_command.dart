import '../base/melos_command.dart';

/// Command to check code generation status across packages
class GenerateCheckCommand extends MelosCommand {
  @override
  String get name => 'generate:check';

  @override
  String get description => 'Check code generation status across packages';

  @override
  String get signature => 'generate:check';

  @override
  Future<void> handle() async {
    try {
      output.newLine();
      output.info('Checking code generation status across packages');
      output.writeln('----------------------------------------');

      final command = '''
if grep -q 'build_runner' pubspec.yaml; then
  if [ -n "\$(find lib test example -name '*.g.dart' -o -name '*.freezed.dart' -o -name '*.reflectable.dart' 2>/dev/null)" ]; then
    echo "Package {MELOS_PACKAGE_NAME} needs code generation."
  else
    echo "Package {MELOS_PACKAGE_NAME} has build_runner but no generated files found."
  fi
else
  echo "Package {MELOS_PACKAGE_NAME} does not use build_runner."
fi''';

      await melosExec(
        command,
        throwOnNonZero: false,
      );
      output.newLine();
      output.success('Check completed successfully');
    } catch (e) {
      output.error('Check failed - see output above for details');
      rethrow;
    }
  }
}
