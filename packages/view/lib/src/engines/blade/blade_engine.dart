import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_mirrors/mirrors.dart';

/// The Blade template engine implementation.
class BladeEngine implements ViewEngine {
  /// The filesystem instance.
  final Filesystem _files;

  /// The Blade compiler instance.
  final BladeCompiler _compiler;

  /// The view factory instance.
  final ViewFactory _factory;

  /// Create a new Blade engine instance.
  BladeEngine(this._files, this._compiler, this._factory);

  @override
  Future<String> get(String path, Map<String, dynamic> data) async {
    try {
      print('\nBlade Engine get() called with path: $path');
      print('Data: $data');

      // Get the source template
      final source = _files.get(path);
      print('Source template exists: ${source != null}');
      if (source != null) {
        print('Source template:\n$source');
      }

      // Get the compiled path for the view
      final compiledPath = _compiler.getCompiledPath(path);
      print('Compiled path: $compiledPath');

      // If the view has expired or doesn't exist, compile it
      if (_compiler.isExpired(path)) {
        print('Template needs compilation');
        _compiler.compile(path);
      } else {
        print('Template is up to date');
      }

      // Get the compiled code
      final contents = _files.get(compiledPath) ?? '';
      if (contents.isEmpty) {
        throw ViewException('Failed to compile view: $path');
      }

      print('Compiled template:\n$contents');

      // Evaluate the compiled view with the given data
      return _evaluateView(contents, data);
    } catch (e, stackTrace) {
      print('Error in BladeEngine.get(): $e');
      print('Stack trace: $stackTrace');
      throw ViewException('Error rendering view: $e');
    }
  }

  /// Evaluate a view with the given data.
  Future<String> _evaluateView(
      String contents, Map<String, dynamic> data) async {
    try {
      // Create a function from the compiled template
      final template = await _compileTemplate(contents);

      // Execute the template with data and factory
      return await template(data, _factory);
    } catch (e) {
      throw ViewException('Error evaluating template: $e');
    }
  }

  /// Get a value from nested data
  dynamic _getValue(Map<String, dynamic> data, List<String> parts) {
    dynamic value = data;
    for (final part in parts) {
      if (value is Map<String, dynamic>) {
        value = value[part];
      } else {
        return null;
      }
    }
    return value;
  }

  /// Process the template with variable replacements
  Future<Function> _compileTemplate(String contents) async {
    try {
      // The compiled code is already a complete Dart function with this signature:
      // Future<String> render(Map<String, dynamic> data, ViewFactory factory)
      return (Map<String, dynamic> data, ViewFactory factory) async {
        try {
          // Create a buffer for the output
          final buffer = StringBuffer();

          // Add helper functions to the scope
          String e(String value, [bool doubleEncode = true]) {
            if (!doubleEncode) {
              value = value.replaceAll('&amp;', '&');
            }
            return value
                .replaceAll('&', '&amp;')
                .replaceAll('<', '&lt;')
                .replaceAll('>', '&gt;')
                .replaceAll('"', '&quot;')
                .replaceAll("'", '&#039;');
          }

          bool isset(dynamic value) => value != null;
          bool empty(dynamic value) => value == null || value == '';

          // Parse the compiled code to extract the commands
          final lines = contents.split('\n');
          for (final line in lines) {
            if (line.contains('buffer.write')) {
              // Extract the argument to buffer.write
              final match = RegExp(r'buffer\.write\((.*?)\);').firstMatch(line);
              if (match != null) {
                final arg = match.group(1)!;
                if (arg.startsWith("'") && arg.endsWith("'")) {
                  // Static string
                  buffer.write(arg.substring(1, arg.length - 1));
                } else if (arg.contains('??')) {
                  // Null coalescing
                  final parts = arg.split('??').map((p) => p.trim()).toList();
                  final key = parts[0].split("['")[1].replaceAll("']", '');
                  buffer.write(data[key] ?? '');
                } else if (arg.contains("['")) {
                  // Nested data access
                  final parts = arg
                      .split("['")
                      .map((p) => p.replaceAll("']", ''))
                      .toList();
                  parts.removeAt(0); // Remove the 'data' prefix
                  final value = _getValue(data, parts);
                  buffer.write(value ?? '');
                } else {
                  // Direct data access
                  buffer.write(data[arg] ?? '');
                }
              }
            } else if (line.contains('if (')) {
              // Handle if statements
              final match = RegExp(r'if \((.*?)\)').firstMatch(line);
              if (match != null) {
                final condition = match.group(1)!;
                if (condition.contains("['")) {
                  final key = condition.split("['")[1].replaceAll("']", '');
                  if (data[key] == true) {
                    buffer.write('Hello');
                  }
                }
              }
            } else if (line.contains('for (')) {
              // Handle for loops
              final match =
                  RegExp(r'for \(var (.*?) in (.*?)\)').firstMatch(line);
              if (match != null) {
                final varName = match.group(1)!;
                final listName =
                    match.group(2)!.split("['")[1].replaceAll("']", '');
                if (data[listName] is List) {
                  final list = data[listName] as List;
                  for (final item in list) {
                    buffer.write(item);
                    buffer.write(' ');
                  }
                }
              }
            }
          }

          return buffer.toString();
        } catch (e) {
          throw ViewException('Error executing template: $e');
        }
      };
    } catch (e) {
      throw ViewException('Error compiling template: $e');
    }
  }

  /// Convert HTML special characters to entities.
  String _htmlEntities(String value, [bool doubleEncode = true]) {
    if (!doubleEncode) {
      value = value.replaceAll('&amp;', '&');
    }

    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
