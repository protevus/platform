import '../base/melos_command.dart';

/// Command to run code generation across packages
class GenerateCommand extends MelosCommand {
  @override
  String get name => 'generate';

  @override
  String get description => 'Run code generation across all packages';

  @override
  String get signature => 'generate';

  @override
  Future<void> handle() async {
    try {
      await melosExec(
        'if grep -q \'build_runner\' pubspec.yaml; then dart run build_runner build --delete-conflicting-outputs; fi',
        throwOnNonZero: false,
        failFast: false,
      );
      output.success('Code generation completed successfully');
    } catch (e) {
      output.error('Code generation failed - see output above for details');
      rethrow;
    }
  }
}
