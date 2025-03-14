import '../base/melos_command.dart';

/// Command to create new packages or applications
class CreateCommand extends MelosCommand {
  @override
  String get name => 'create';

  @override
  String get description => 'Create a new package or application';

  @override
  String get help => '''
Creates a new Dart package or Flutter application in the appropriate directory.

Available categories for Dart:
  - package     : Basic Dart package
  - console     : Command-line application
  - server      : Server-side application
  - desktop     : Desktop application
  - plugin      : Dart plugin

Available categories for Flutter:
  - app         : Mobile application
  - web         : Web application
  - desktop     : Desktop application
  - plugin      : Flutter plugin
  - module      : Flutter module
  - package     : Flutter package
''';

  @override
  String get signature =>
      'create {--type=dart : Project type (dart or flutter)} {--category= : Project category (see help for available categories)} {--name= : Project name}';

  /// Valid categories for Dart projects
  static const dartCategories = {
    'package': 'Basic Dart package',
    'console': 'Command-line application',
    'server': 'Server-side application',
    'desktop': 'Desktop application',
    'plugin': 'Dart plugin',
  };

  /// Valid categories for Flutter projects
  static const flutterCategories = {
    'app': 'Mobile application',
    'web': 'Web application',
    'desktop': 'Desktop application',
    'plugin': 'Flutter plugin',
    'module': 'Flutter module',
    'package': 'Flutter package',
  };

  @override
  Future<void> handle() async {
    // Validate type
    final type = option<String>('type')?.toLowerCase() ?? 'dart';
    if (type != 'dart' && type != 'flutter') {
      throw ArgumentError('Type must be either "dart" or "flutter"');
    }

    // Validate category
    final category = option<String>('category');
    if (category == null || category.isEmpty) {
      throw ArgumentError('Category is required');
    }

    final validCategories = type == 'dart' ? dartCategories : flutterCategories;
    if (!validCategories.containsKey(category)) {
      throw ArgumentError(
          'Invalid category "$category" for $type. See help for available categories.');
    }

    // Validate name
    final name = option<String>('name');
    if (name == null || name.isEmpty) {
      throw ArgumentError('Project name is required');
    }

    try {
      output.info('Creating new $type ${validCategories[category]} "$name"...');

      // Execute the create command
      await executeMelos(
        'run',
        args: [
          'create',
          '--',
          "project_type:$type",
          "category:$category",
          "name:$name",
        ],
        throwOnNonZero: true,
      );

      output.success('Project created successfully');
    } catch (e) {
      output.error('Failed to create project - see output above for details');
      rethrow;
    }
  }
}
