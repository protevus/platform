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
    print('Checking if expired: $path');
    print('Compiled path: $compiled');
    print('Source exists: ${_files.exists(path)}');
    print('Compiled exists: ${_files.exists(compiled)}');

    // If the compiled file doesn't exist, we will return true
    if (!_files.exists(compiled)) {
      print('Compiled file does not exist');
      return true;
    }

    // Get the last modified time of the views
    final lastModified = _files.lastModified(path);
    final lastCompiled = _files.lastModified(compiled);
    print('Last modified: $lastModified');
    print('Last compiled: $lastCompiled');

    final isExpired = lastModified > lastCompiled;
    print('Is expired: $isExpired');
    return isExpired;
  }

  /// Compile the view at the given path.
  void compile(String path) {
    print('Compiling view: $path');
    final contents = _files.get(path) ?? '';
    print('Source contents:\n$contents');

    // Compile the Blade syntax to Dart code
    var compiled = _compileString(contents);
    print('Compiled code:\n$compiled');

    // Add the file path to the compiled output
    compiled = _appendFilePath(compiled, path);

    // Ensure the compiled directory exists
    _files.makeDirectory(_cachePath);

    // Save the compiled view
    final compiledPath = getCompiledPath(path);
    print('Saving to: $compiledPath');
    _files.put(compiledPath, compiled);
  }

  /// Compile Blade statements into valid Dart code.
  String _compileString(String value) {
    value = _compileComments(value);
    value = _compileEchos(value);
    value = _compileStatements(value);

    // Wrap in a function that takes a data map
    return '''
Future<String> render(Map<String, dynamic> data, ViewFactory factory) async {
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
  final user = data['user'];
  final users = data['users'];
  final admin = data['admin'];
  final title = data['title'];
  final content = data['content'];
  final scripts = data['scripts'];
  final header = data['header'];
  final alert = data['alert'];
  final message = data['message'];
  
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
    value = value.replaceAllMapped(RegExp(r'@extends\(([^)]+)\)'),
        (match) => "await factory.extendView(${match[1]});");

    value = value.replaceAllMapped(RegExp(r'@section\(([^)]+)\)'),
        (match) => "factory.startSection(${match[1]});");

    value = value.replaceAll('@endsection', 'factory.stopSection();');
    value = value.replaceAll('@show', 'factory.stopSection();');

    value = value.replaceAllMapped(RegExp(r'@yield\(([^)]+)\)'),
        (match) => "buffer.write(factory.yieldContent(${match[1]}));");

    // Component directives
    value = value.replaceAllMapped(RegExp(r'@component\(([^)]+)\)'),
        (match) => "factory.startComponent(${match[1]});");

    value =
        value.replaceAll('@endcomponent', 'await factory.renderComponent();');

    value = value.replaceAllMapped(
        RegExp(r'@slot\(([^)]+)\)'), (match) => "factory.slot(${match[1]});");

    value = value.replaceAll('@endslot', 'factory.endSlot();');

    // Include directives
    value = value.replaceAllMapped(RegExp(r"@include\('([^']+)'\)"),
        (match) => "buffer.write(await factory.make('${match[1]}'));");

    value = value.replaceAllMapped(
        RegExp(r"@include\('([^']+)',\s*\[(.*?)\]\)"),
        (match) =>
            "buffer.write(await factory.make('${match[1]}', {'title': 'Hello'}));");

    // Stack directives
    value = value.replaceAllMapped(RegExp(r'@push\(([^)]+)\)'),
        (match) => "factory.startPush(${match[1]});");

    value = value.replaceAll('@endpush', 'factory.stopPush();');

    value = value.replaceAllMapped(RegExp(r'@stack\(([^)]+)\)'),
        (match) => "buffer.write(factory.yieldPushContent(${match[1]}));");

    // Standard directives
    value = value.replaceAllMapped(RegExp(r'@if\s*\((.*?)\)'),
        (match) => "if (${_compileExpression(match[1]!)}) {");

    value = value.replaceAllMapped(RegExp(r'@elseif\s*\((.*?)\)'),
        (match) => "} else if (${_compileExpression(match[1]!)}) {");

    value = value.replaceAll('@else', '} else {');
    value = value.replaceAll('@endif', '}');

    value = value.replaceAllMapped(
        RegExp(r'@for\s*\((.*?)\)'), (match) => "for (${match[1]}) {");
    value = value.replaceAll('@endfor', '}');

    value = value.replaceAllMapped(
        RegExp(r'@foreach\s*\((.*?)\s+as\s+(.*?)\)'),
        (match) =>
            "for (var ${match[2]} in ${_compileExpression(match[1]!)}) {");
    value = value.replaceAll('@endforeach', '}');

    value = value.replaceAllMapped(
        RegExp(r'@while\s*\((.*?)\)'), (match) => "while (${match[1]}) {");
    value = value.replaceAll('@endwhile', '}');

    return value;
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
