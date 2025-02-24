import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';
import 'package:path/path.dart' as path_util;

/// The Blade template compiler.
class BladeCompiler {
  /// The filesystem instance.
  final Filesystem _files;

  /// The path to the compiled views storage.
  final String _cachePath;

  /// The registered custom directives.
  final Map<String, Function> _customDirectives = {};

  /// The registered conditions.
  final Map<String, Function> _conditions = {};

  /// The view factory instance.
  final ViewFactory _factory;

  /// Create a new Blade compiler instance.
  BladeCompiler(this._files, this._cachePath, this._factory);

  /// Get the path to the compiled version of a view.
  String getCompiledPath(String viewPath) {
    return _files
        .path(path_util.join(_cachePath, _generateCacheName(viewPath)));
  }

  /// Determine if the view at the given path is expired.
  bool isExpired(String path) {
    final compiled = getCompiledPath(path);

    // If the compiled file doesn't exist, we will return true
    if (!_files.exists(compiled)) {
      return true;
    }

    // Get the last modified time of the views
    final lastModified = _files.lastModified(path);
    final lastCompiled = _files.lastModified(compiled);

    return lastModified > lastCompiled;
  }

  /// Compile the view at the given path.
  void compile(String path) {
    final contents = _files.get(path) ?? '';

    // Compile the Blade syntax to Dart code
    var compiled = _compileString(contents);

    // Add the file path to the compiled output
    compiled = _appendFilePath(compiled, path);

    // Ensure the compiled directory exists
    _files.makeDirectory(_cachePath);

    // Save the compiled view
    _files.put(getCompiledPath(path), compiled);
  }

  /// Compile Blade statements into valid Dart code.
  String _compileString(String value) {
    value = _compileComments(value);
    value = _compileEchos(value);
    value = _compileStatements(value);

    // Wrap in a function that takes a data map
    return '''
String render(Map<String, dynamic> data, ViewFactory factory) {
  final buffer = StringBuffer();
  
  // Add helper functions
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
  
  // Add data variables to scope
  ${_compileDataToVariables()}
  
  // Template code
  $value
  
  return buffer.toString();
}
''';
  }

  /// Compile Blade comments into Dart comments.
  String _compileComments(String value) {
    return value.replaceAllMapped(
        RegExp(r'{#(.+?)#}', multiLine: true), (match) => '// ${match[1]}');
  }

  /// Compile Blade echo statements into Dart string interpolation.
  String _compileEchos(String value) {
    // Compile escaped echoes
    value = value.replaceAllMapped(RegExp(r'{{{(.+?)}}}'),
        (match) => "buffer.write(e(${_compileExpression(match[1]!)}));");

    // Compile unescaped echoes
    value = value.replaceAllMapped(RegExp(r'{!!(.+?)!!}'),
        (match) => "buffer.write(${_compileExpression(match[1]!)});");

    // Compile regular echoes
    value = value.replaceAllMapped(RegExp(r'{{(.+?)}}'),
        (match) => "buffer.write(e(${_compileExpression(match[1]!)}));");

    return value;
  }

  /// Compile Blade statements into Dart code.
  String _compileStatements(String value) {
    // Layout directives
    value = value.replaceAllMapped(RegExp(r'@extends\((.*?)\)'),
        (match) => "await factory.extendView(${match[1]});");

    value = value.replaceAllMapped(RegExp(r'@section\((.*?)\)'),
        (match) => "factory.startSection(${match[1]});");

    value = value.replaceAll('@endsection', 'factory.stopSection();');
    value = value.replaceAll('@show', 'factory.stopSection();');

    // Component directives
    value = value.replaceAllMapped(RegExp(r'@component\((.*?)\)'),
        (match) => "factory.startComponent(${match[1]});");

    value =
        value.replaceAll('@endcomponent', 'await factory.renderComponent();');

    value = value.replaceAllMapped(
        RegExp(r'@slot\((.*?)\)'), (match) => "factory.slot(${match[1]});");

    value = value.replaceAll('@endslot', 'factory.endSlot();');

    // Stack directives
    value = value.replaceAllMapped(RegExp(r'@push\((.*?)\)'),
        (match) => "factory.startPush(${match[1]});");

    value = value.replaceAll('@endpush', 'factory.stopPush();');

    // Standard directives
    value = value.replaceAllMapped(RegExp(r'@if\s*\((.*?)\)'),
        (match) => "if (${_compileExpression(match[1]!)}) {");
    value = value.replaceAll('@endif', '}');
    value = value.replaceAll('@else', '} else {');

    value = value.replaceAllMapped(
        RegExp(r'@for\s*\((.*?)\)'), (match) => "for (${match[1]}) {");
    value = value.replaceAll('@endfor', '}');

    value = value.replaceAllMapped(RegExp(r'@foreach\s*\((.*?)\s+as\s+(.*?)\)'),
        (match) => "for (var ${match[2]} in ${match[1]}) {");
    value = value.replaceAll('@endforeach', '}');

    return value;
  }

  /// Convert data map to variable declarations.
  String _compileDataToVariables() {
    return '''
  data.forEach((key, value) {
    // ignore: unused_local_variable
    var \$key = value;
  });
''';
  }

  /// Compile a Blade expression into a Dart expression.
  String _compileExpression(String expression) {
    // Remove whitespace
    expression = expression.trim();

    // Replace . with []
    expression = expression.replaceAllMapped(
        RegExp(r'(\w+)\.(\w+)'), (match) => "${match[1]}['${match[2]}']");

    return expression;
  }

  /// Generate a cache key for the view.
  String _generateCacheName(String path) {
    return '${path.replaceAll(RegExp(r'[\/\\\.]'), '_')}.dart';
  }

  /// Append the file path to the compiled string.
  String _appendFilePath(String contents, String path) {
    return '''
// Generated from: $path
$contents
''';
  }

  /// Register a handler for custom directives.
  void directive(String name, Function handler) {
    if (!RegExp(r'^\w+$').hasMatch(name)) {
      throw ArgumentError(
          'The directive name [$name] is not valid. Directive names must only contain alphanumeric characters and underscores.');
    }

    _customDirectives[name] = handler;
  }

  /// Register an "if" statement directive.
  void if_(String name, Function callback) {
    _conditions[name] = callback;

    directive(name, (expression) {
      return expression.isNotEmpty
          ? 'if (check("$name", $expression)) {'
          : 'if (check("$name")) {';
    });

    directive('end$name', (_) => '}');
  }

  /// Check the result of a condition.
  bool check(String name, [List<dynamic> parameters = const []]) {
    return Function.apply(_conditions[name]!, parameters);
  }

  /// Get the list of custom directives.
  Map<String, Function> get customDirectives =>
      Map.unmodifiable(_customDirectives);

  /// Get the list of registered conditions.
  Map<String, Function> get conditions => Map.unmodifiable(_conditions);
}
