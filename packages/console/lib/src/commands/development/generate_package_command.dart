import '../base/melos_command.dart';

/// Command to run code generation for a specific package
class GeneratePackageCommand extends MelosCommand {
  @override
  String get name => 'generate:package';

  @override
  String get description => 'Run code generation for a specific package';

  @override
  String get signature => '''generate:package 
{package : The package to run code generation for}''';

  @override
  Future<void> handle() async {
    final package = argument<String>('package');
    final fullPackage = 'illuminate_$package';

    try {
      output.newLine();
      output.info('Running code generation for package: $fullPackage');
      output.writeln('----------------------------------------');

      await melosExec(
        'if grep -q \'build_runner\' pubspec.yaml; then dart run build_runner build --delete-conflicting-outputs; fi',
        scope: fullPackage,
        throwOnNonZero: false,
      );
      output.success('Code generation completed successfully');
    } catch (e) {
      output.error('Code generation failed - see output above for details');
      rethrow;
    }
  }
}
