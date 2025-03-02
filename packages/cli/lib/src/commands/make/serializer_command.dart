import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;

/// Command to create a new serializer class.
class MakeSerializerCommand extends Command {
  @override
  String get name => 'make:serializer';

  @override
  String get description => 'Create a new serializer class';

  @override
  String get signature =>
      'make:serializer {name : The name of the serializer class}';

  String _getTemplate(String className, String filename) {
    return '''
import 'package:illuminate_foundation/foundation.dart';

import '../../../app/models/$filename/$filename.model.dart';

class ${className}Serializer extends Serializer<$className> {
  ${className}Serializer(super.data);

  @override
  Map<String, dynamic> convert($className m) {
    return <String, dynamic>{};
  }
}
''';
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
    var name = argument<String>('name')!;
    name = name.toLowerCase().replaceAll('serializer', '');
    name = _pascalToSnake(name);
    final className = _snakeToPascal(name);
    final serializerName = '$name.serializer';

    final basePath = path.join('lib', 'app', 'http', 'serializers');
    final serializerPath = path.join(basePath, '$name.serializer.dart');

    final file = File(serializerPath);
    if (file.existsSync()) {
      output.info('$serializerName already exists');
      return;
    }

    final directory = Directory(basePath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    file.writeAsStringSync(_getTemplate(className, name));
    output.success('$serializerName created successfully.');
  }
}
