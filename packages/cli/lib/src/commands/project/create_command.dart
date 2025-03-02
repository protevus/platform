import 'dart:convert';
import 'dart:io';
import 'package:illuminate_console/console.dart';

/// Command to create a new project.
class ProjectCreateCommand extends Command {
  @override
  String get name => 'new';

  @override
  String get description => 'Create a new Illuminate application';

  @override
  String get signature =>
      'new {name : The name of the project} {--version= : The version of the project template to use}';

  String _pascalToSnake(String input) {
    final result = StringBuffer();
    for (final letter in input.codeUnits) {
      if (letter >= 65 && letter <= 90) {
        if (result.isNotEmpty) {
          result.write('_');
        }
        result.write(String.fromCharCode(letter + 32));
      } else {
        result.write(String.fromCharCode(letter));
      }
    }
    String finalString = result.toString().replaceAll(RegExp('_+'), '_');
    finalString = finalString.endsWith('_')
        ? finalString.substring(0, finalString.length - 1)
        : finalString;
    return finalString;
  }

  @override
  Future<void> handle() async {
    final projectName = _pascalToSnake(argument<String>('name')!);
    final versionName = option<String>('version');

    final projectFolder = Directory(projectName);

    if (projectFolder.existsSync()) {
      output.error('Folder name "$projectName" already exists');
      return;
    }

    output.success('Project name : $projectName');
    output.success('Creating...');

    final version = await Process.run('curl', [
      'https://api.github.com/repos/dartondox/dox-sample/releases/latest',
      '-s',
    ]);

    final versionData = jsonDecode(version.stdout as String);

    /// use version name if provided, else use latest version
    var latestTag = versionName ?? versionData['name'];

    /// replace v with empty space if there is v in version and join again v
    /// so that it work for both 'v2.0.0' and '2.0.0'
    latestTag = 'v${latestTag.replaceFirst('v', '')}';

    output.success('Version : $latestTag');

    final result = await Process.run('git', [
      'clone',
      '--depth',
      '1',
      '--branch',
      latestTag,
      'https://github.com/dartondox/dox-sample.git',
      projectName
    ]);

    if (result.stderr != null && result.stderr.toString().isNotEmpty) {
      if (result.stderr.toString().contains('Could not find')) {
        output.error(result.stderr.toString());
        return;
      }
    }

    final gitDirectory = Directory('${projectFolder.path}/.git');

    if (!gitDirectory.existsSync()) {
      return;
    }

    /// remove `.git` folder
    gitDirectory.deleteSync(recursive: true);

    // Replace the project name in all files
    final files = projectFolder.listSync(recursive: true);
    for (final file in files) {
      if (file is File) {
        if (!file.path.contains('bin/dox')) {
          final content =
              file.readAsStringSync().replaceAll('sample_app', projectName);
          file.writeAsStringSync(content);
        }
      }
    }

    output.success('Done. Created at - ${projectFolder.path}');
    output.success('Now run:\n');
    output.writeln('    ➢ cd $projectName');
    output.writeln('    ➢ dart pub get');
    output.writeln('    ➢ cp .env.example .env (modify .env variables)');
    output.writeln('    ➢ dox serve\n');
  }
}
