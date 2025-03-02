import 'dart:io';
import 'package:illuminate_console/console.dart';
import 'package:path/path.dart' as path;

/// Command to create a new controller class.
class MakeControllerCommand extends Command {
  @override
  String get name => 'make:controller';

  @override
  String get description => 'Create a new controller class';

  @override
  String get signature =>
      'make:controller {name : The name of the controller class} {--r|resource : Create a resource controller} {--w|websocket : Create a websocket controller}';

  String _getBasicTemplate(String className, String filename) {
    return '''
import 'package:illuminate_foundation/foundation.dart';

class ${className}Controller {
  Future<dynamic> index(DoxRequest req) async {
    /// write your logic here
  }
}

${className}Controller ${_toPascalWithFirstLetterLowerCase(className)}Controller = ${className}Controller();
''';
  }

  String _getWebSocketTemplate(String className, String filename) {
    return '''
import 'package:dox_websocket/dox_websocket.dart';

class ${className}Controller {
  void index(WebsocketEmitter emitter, dynamic message) async {
    /// write your logic here
  }
}
''';
  }

  String _getResourceTemplate(String className, String filename) {
    return '''
import 'package:illuminate_foundation/foundation.dart';

class ${className}Controller {
  /// GET /resource
  Future<dynamic> index(DoxRequest req) async {}

  /// GET /resource/create
  Future<dynamic> create(DoxRequest req) async {}

  /// POST /resource
  Future<dynamic> store(DoxRequest req) async {}

  /// GET /resource/{id}
  Future<dynamic> show(DoxRequest req, String id) async {}

  /// GET /resource/{id}/edit
  Future<dynamic> edit(DoxRequest req, String id) async {}

  /// PUT|PATCH /resource/{id}
  Future<dynamic> update(DoxRequest req, String id) async {}

  /// DELETE /resource/{id}
  Future<dynamic> destroy(DoxRequest req, String id) async {}
}

${className}Controller ${_toPascalWithFirstLetterLowerCase(className)}Controller = ${className}Controller();
''';
  }

  String _toPascalWithFirstLetterLowerCase(String input) {
    String pascal = _snakeToPascal(input);
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
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
    final isResource = option<bool>('resource') ?? false;
    final isWebsocket = option<bool>('websocket') ?? false;

    name = name.toLowerCase().replaceAll('controller', '');
    name = _pascalToSnake(name);
    final className = _snakeToPascal(name);
    final controllerName = '$name.controller';

    final basePath = isWebsocket
        ? path.join('lib', 'app', 'ws', 'controllers')
        : path.join('lib', 'app', 'http', 'controllers');
    final controllerPath = path.join(basePath, '$name.controller.dart');

    final file = File(controllerPath);
    if (file.existsSync()) {
      output.info('$controllerName already exists');
      return;
    }

    String template;
    if (isWebsocket) {
      template = _getWebSocketTemplate(className, name);
    } else if (isResource) {
      template = _getResourceTemplate(className, name);
    } else {
      template = _getBasicTemplate(className, name);
    }

    final directory = Directory(basePath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    file.writeAsStringSync(template);
    output.success('$controllerName created successfully.');
  }
}
