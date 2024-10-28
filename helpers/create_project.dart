import 'dart:io';

void main(List<String> args) async {
  // Parse command line arguments
  String? projectType;
  String? category;
  String? name;

  for (var arg in args) {
    final parts = arg.split(':');
    if (parts.length == 2) {
      switch (parts[0]) {
        case 'project_type':
        case 'project-type':
          projectType = parts[1];
          break;
        case 'category':
          category = parts[1];
          break;
        case 'name':
          name = parts[1];
          break;
      }
    }
  }

  // Print received arguments for debugging
  print('Received arguments:');
  print('Project Type: $projectType');
  print('Category: $category');
  print('Name: $name');

  // Validate inputs
  if (projectType == null || category == null || name == null) {
    print('Error: Missing required arguments');
    print(
        'Usage: melos run create project_type:dart|flutter category:type name:project_name');
    exit(1);
  }

  if (projectType != 'dart' && projectType != 'flutter') {
    print('Error: project_type must be either "dart" or "flutter"');
    exit(1);
  }

  // Determine base directory
  final baseDir = projectType == 'flutter' &&
          (category == 'app' || category == 'web' || category == 'desktop')
      ? 'apps'
      : 'packages';

  // Create project directory
  final projectDir = Directory('$baseDir/$name');
  if (await projectDir.exists()) {
    print('Error: Project directory already exists at ${projectDir.path}');
    exit(1);
  }

  try {
    // Ensure the base directory exists
    await Directory(baseDir).create(recursive: true);

    // Create the project using the appropriate command
    final result = await Process.run(
      projectType,
      [
        'create',
        if (projectType == 'flutter') ...[
          '--org',
          'com.example',
          '--project-name',
          name,
          if (category == 'plugin') '--template=plugin',
          if (category == 'package') '--template=package',
          if (category == 'module') '--template=module',
          if (category == 'web') '--platforms=web',
          if (category == 'desktop') '--platforms=windows,macos,linux',
        ] else ...[
          if (category == 'package') '--template=package',
          if (category == 'console') '--template=console',
          if (category == 'server') '--template=server-shelf',
        ],
        projectDir.path,
      ],
    );

    if (result.exitCode != 0) {
      print('Error creating project:');
      print(result.stderr);
      exit(1);
    }

    print('Successfully created $projectType project at ${projectDir.path}');

    // Add additional dependencies based on category
    if (category == 'server') {
      await Process.run('dart', ['pub', 'add', 'shelf_router'],
          workingDirectory: projectDir.path);
      await Process.run('dart', ['pub', 'add', 'dotenv'],
          workingDirectory: projectDir.path);
      await Process.run('dart', ['pub', 'add', 'logger'],
          workingDirectory: projectDir.path);
    }

    if (category == 'desktop') {
      await Process.run('dart', ['pub', 'add', 'window_manager'],
          workingDirectory: projectDir.path);
      await Process.run('dart', ['pub', 'add', 'screen_retriever'],
          workingDirectory: projectDir.path);
    }

    // Format the project
    await Process.run('dart', ['format', projectDir.path]);

    print('Done! 🎉');
    print('To get started, cd into ${projectDir.path}');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
