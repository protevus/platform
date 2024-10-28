import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  // Parse command line arguments
  String? templateName;
  String? projectType;
  String? name;

  for (var arg in args) {
    final parts = arg.split(':');
    if (parts.length == 2) {
      switch (parts[0]) {
        case 'template_name':
          templateName = parts[1];
          break;
        case 'type':
          projectType = parts[1];
          break;
        case 'name':
          name = parts[1];
          break;
      }
    }
  }

  // Print received arguments for debugging
  print('Received arguments:');
  print('Template Name: $templateName');
  print('Project Type: $projectType');
  print('Name: $name');

  // Validate inputs
  if (templateName == null || projectType == null || name == null) {
    print('Error: Missing required arguments');
    print(
        'Usage: melos run template template_name:name type:dart|flutter name:project_name');
    exit(1);
  }

  if (projectType != 'dart' && projectType != 'flutter') {
    print('Error: type must be either "dart" or "flutter"');
    exit(1);
  }

  // Convert name to snake_case
  final snakeCaseName = name
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)?.toLowerCase()}',
      )
      .toLowerCase()
      .replaceFirst(RegExp(r'^_'), '');

  // Determine directories
  final templateDir = Directory('templates/$templateName');
  final targetBaseDir = (projectType == 'flutter') ? 'apps' : 'packages';
  final targetDir = Directory('$targetBaseDir/$snakeCaseName');

  // Validate template exists
  if (!await templateDir.exists()) {
    print('Error: Template "$templateName" not found in templates directory');
    print('Available templates:');
    await for (var entity in Directory('templates').list()) {
      if (entity is Directory) {
        print('  - ${path.basename(entity.path)}');
      }
    }
    exit(1);
  }

  // Check if target directory already exists
  if (await targetDir.exists()) {
    print('Error: Target directory already exists at ${targetDir.path}');
    exit(1);
  }

  try {
    // Create target directory
    await targetDir.create(recursive: true);

    // Copy template files
    await _copyDirectory(templateDir, targetDir);

    // Process template files
    await _processTemplateFiles(targetDir, {
      'PROJECT_NAME': name,
      'PROJECT_NAME_SNAKE_CASE': snakeCaseName,
      'PROJECT_NAME_PASCAL_CASE': _toPascalCase(name),
      'PROJECT_NAME_CAMEL_CASE': _toCamelCase(name),
      'CREATION_TIMESTAMP': DateTime.now().toIso8601String(),
    });

    // Update pubspec.yaml if it exists
    final pubspecFile = File('${targetDir.path}/pubspec.yaml');
    if (await pubspecFile.exists()) {
      await _updatePubspec(pubspecFile, name);
    }

    print(
        'Successfully created project from template "$templateName" at ${targetDir.path}');
    print('Done! 🎉');
    print('To get started, cd into ${targetDir.path}');
  } catch (e) {
    print('Error: $e');
    // Cleanup on error
    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
    exit(1);
  }
}

Future<void> _copyDirectory(Directory source, Directory target) async {
  await for (var entity in source.list(recursive: false)) {
    final targetPath =
        path.join(target.path, path.relative(entity.path, from: source.path));

    if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
      await _copyDirectory(entity, Directory(targetPath));
    } else if (entity is File) {
      await entity.copy(targetPath);
    }
  }
}

Future<void> _processTemplateFiles(
    Directory directory, Map<String, String> replacements) async {
  await for (var entity in directory.list(recursive: true)) {
    if (entity is File) {
      if (path.extension(entity.path) == '.tmpl') {
        // Process template file
        String content = await entity.readAsString();
        for (var entry in replacements.entries) {
          content = content.replaceAll('{{${entry.key}}}', entry.value);
        }

        // Write processed content to new file without .tmpl extension
        final newPath = entity.path.replaceAll('.tmpl', '');
        await File(newPath).writeAsString(content);
        await entity.delete(); // Remove template file
      } else {
        // Process regular file (only process certain file types)
        final ext = path.extension(entity.path);
        if (['.dart', '.yaml', '.md', '.json'].contains(ext)) {
          String content = await entity.readAsString();
          for (var entry in replacements.entries) {
            content = content.replaceAll('{{${entry.key}}}', entry.value);
          }
          await entity.writeAsString(content);
        }
      }
    }
  }
}

Future<void> _updatePubspec(File pubspecFile, String projectName) async {
  final content = await pubspecFile.readAsString();
  final yaml = loadYaml(content);

  // Create new pubspec content with updated name
  final newContent = content.replaceFirst(
    RegExp(r'name:.*'),
    'name: $projectName',
  );

  await pubspecFile.writeAsString(newContent);
}

String _toPascalCase(String input) {
  return input
      .split(RegExp(r'[_\- ]'))
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join('');
}

String _toCamelCase(String input) {
  final pascal = _toPascalCase(input);
  return pascal[0].toLowerCase() + pascal.substring(1);
}
