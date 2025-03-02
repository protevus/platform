import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;

/// Command to create a new model class.
class MakeModelCommand extends Command {
  @override
  String get name => 'make:model';

  @override
  String get description => 'Create a new model class';

  @override
  String get signature =>
      'make:model {name : The name of the model class} {--m|migration : Create a migration file for the model}';

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

  String _snakeToPascal(String input) {
    final parts = input.split('_');
    final result = StringBuffer();
    for (final part in parts) {
      if (part.isNotEmpty) {
        result.write('${part[0].toUpperCase()}${part.substring(1)}');
      }
    }
    return result.toString().isEmpty ? input : result.toString();
  }

  @override
  Future<void> handle() async {
    final name = argument<String>('name')!;
    final createMigration = option<bool>('migration') ?? false;

    final snakeCase = _pascalToSnake(name);
    final className = _snakeToPascal(snakeCase);

    // Create model file
    final modelDir = path.join('lib', 'app', 'models', snakeCase);
    final modelPath = path.join(modelDir, '$snakeCase.model.dart');

    final modelContent = '''
import 'package:illuminate_database/query_builder.dart';

part '$snakeCase.model.g.dart';

@DoxModel()
class $className extends ${className}Generator {
  @override
  List<String> get hidden => <String>[];
}
''';

    final modelDirectory = Directory(modelDir);
    if (!modelDirectory.existsSync()) {
      modelDirectory.createSync(recursive: true);
    }

    final modelFile = File(modelPath);
    modelFile.writeAsStringSync(modelContent);

    output.success('Model [$className] created successfully.');

    if (createMigration) {
      final timestamp = DateTime.now()
          .toUtc()
          .toString()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final tableName = snakeCase;
      final migrationClassName = _snakeToPascal('create_${tableName}_table');
      final migrationPath = path.join('database', 'migrations',
          '${timestamp}_create_${tableName}_table.dart');

      final migrationContent = '''
import 'package:illuminate_database/database.dart';

class $migrationClassName implements Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('$tableName', (table) {
      table.id();
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.drop('$tableName');
  }
}
''';

      final migrationDirectory = Directory(path.dirname(migrationPath));
      if (!migrationDirectory.existsSync()) {
        migrationDirectory.createSync(recursive: true);
      }

      final migrationFile = File(migrationPath);
      migrationFile.writeAsStringSync(migrationContent);

      output.success('Migration [$migrationClassName] created successfully.');
    }
  }
}
