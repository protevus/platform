import 'dart:io';
import 'dart:convert';
import '../base/melos_command.dart';

/// Command to create a new project from a template
class CreateTemplateCommand extends MelosCommand {
  @override
  String get name => 'create:template';

  @override
  String get description =>
      'Create a new project from a template in the templates directory';

  @override
  String get signature =>
      'create:template {template_name : Name of the template to use} {type : Project type (dart or flutter)} {name : Name of the new project}';

  @override
  Future<void> handle() async {
    try {
      // Get arguments
      final templateName = argument<String>('template_name');
      final type = argument<String>('type');
      final name = argument<String>('name');

      // Validate project type
      if (!['dart', 'flutter'].contains(type?.toLowerCase() ?? '')) {
        throw ArgumentError('Project type must be either "dart" or "flutter"');
      }

      output.info(
          'Creating $type project "$name" from template "$templateName"...');

      // Execute the script directly
      final process = await Process.start(
        'dart',
        [
          'run',
          'helpers/create_from_template.dart',
          'template_name:$templateName',
          'type:$type',
          'name:$name',
        ],
      );

      // Stream output in real time
      process.stdout.transform(utf8.decoder).listen(output.write);
      process.stderr.transform(utf8.decoder).listen(output.error);

      // Wait for process to complete
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw Exception('Process exited with code $exitCode');
      }

      output.success('Project created successfully');
    } catch (e) {
      output.error('Failed to create project - see output above for details');
      rethrow;
    }
  }
}
