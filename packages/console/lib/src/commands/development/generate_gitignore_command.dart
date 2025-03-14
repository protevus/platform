import '../base/melos_command.dart';

/// Command to ensure .gitignore files are properly set up in packages
class GenerateGitignoreCommand extends MelosCommand {
  @override
  String get name => 'generate:gitignore';

  @override
  String get description => 'Set up .gitignore files in packages';

  @override
  String get signature => 'generate:gitignore';

  static const gitignoreContent =
      '''# See https://www.dartlang.org/guides/libraries/private-files

# Artifacts from ide's
.idea/

# Files and directories created by pub
.dart_tool/
.packages
build/

# Directory created by dartdoc
# If you don't generate documentation locally you can remove this line.
doc/api/

# If you're building an application, you may want to check-in your pubspec.lock
pubspec.lock
pubspec_overrides.yaml
''';

  @override
  Future<void> handle() async {
    try {
      output.info('Setting up .gitignore files in packages...');

      // Create a temporary script with the gitignore content
      await executeMelos(
        'exec',
        args: [
          '--',
          'bash',
          '-c',
          '''
          cat > .gitignore << 'EOL'
$gitignoreContent
EOL
          ''',
        ],
        throwOnNonZero: true,
      );

      output.success('.gitignore files have been set up successfully');
    } catch (e) {
      output.error(
          'Failed to set up .gitignore files - see output above for details');
      rethrow;
    }
  }
}
