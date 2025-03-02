import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;

/// Command to create a new middleware class.
class MakeMiddlewareCommand extends Command {
  @override
  String get name => 'make:middleware';

  @override
  String get description => 'Create a new middleware class';

  @override
  String get signature =>
      'make:middleware {name : The name of the middleware class}';

  String _getTemplate(String className, String filename) {
    return '''
import 'package:illuminate_foundation/foundation.dart';

class ${className}Middleware extends IDoxMiddleware {
  @override
  dynamic handle(IDoxRequest req) {
    /// add your logic here
    /// return req (IDoxRequest) to process next to the controller
    /// or throw an error or return Map, String, List etc to return 200 response
    return req;
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
    name = name.toLowerCase().replaceAll('middleware', '');
    name = _pascalToSnake(name);
    final className = _snakeToPascal(name);
    final middlewareName = '$name.middleware';

    final basePath = path.join('lib', 'app', 'http', 'middleware');
    final middlewarePath = path.join(basePath, '$name.middleware.dart');

    final file = File(middlewarePath);
    if (file.existsSync()) {
      output.info('$middlewareName already exists');
      return;
    }

    final directory = Directory(basePath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    file.writeAsStringSync(_getTemplate(className, name));
    output.success('$middlewareName created successfully.');
  }
}
