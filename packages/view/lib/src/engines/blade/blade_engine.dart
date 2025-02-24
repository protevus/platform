import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';
//import 'package:path/path.dart' as path;

//import 'blade_compiler.dart';

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
    // Get the compiled path for the view
    final compiledPath = _compiler.getCompiledPath(path);

    // If the view has expired, recompile it
    if (_compiler.isExpired(path)) {
      _compiler.compile(path);
    }

    // Get the compiled view contents
    final contents = _files.get(compiledPath) ?? '';

    // Evaluate the compiled view with the given data
    return _evaluateView(contents, data);
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

  /// Process the template with variable replacements
  Future<Function> _compileTemplate(String contents) async {
    try {
      return (Map<String, dynamic> data, ViewFactory factory) async {
        return contents.replaceAllMapped(
          RegExp(r'\{\{(.*?)\}\}'),
          (match) => data[match.group(1)?.trim() ?? '']?.toString() ?? '',
        );
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
