import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;

/// Command to create a new form request class.
class MakeRequestCommand extends Command {
  @override
  String get name => 'make:request';

  @override
  String get description => 'Create a new form request class';

  @override
  String get signature => 'make:request {name : The name of the request class}';

  String _getTemplate(String className, String filename) {
    return '''
import 'package:illuminate_foundation/foundation.dart';

class ${className}Request extends FormRequest {
  @override
  void setUp() {}

  @override
  Map<String, String> rules() {
    return <String, String>{};
  }

  @override
  Map<String, String> messages() {
    return <String, String>{};
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
    name = name.toLowerCase().replaceAll('request', '');
    name = _pascalToSnake(name);
    final className = _snakeToPascal(name);
    final requestName = '$name.request';

    final basePath = path.join('lib', 'app', 'http', 'requests');
    final requestPath = path.join(basePath, '$name.request.dart');

    final file = File(requestPath);
    if (file.existsSync()) {
      output.info('$requestName already exists');
      return;
    }

    final directory = Directory(basePath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    file.writeAsStringSync(_getTemplate(className, name));
    output.success('$requestName created successfully.');
  }
}
