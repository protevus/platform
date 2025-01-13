/// Blade template engine for Dart
library blade;

import 'package:source_span/source_span.dart';

import 'src/ast/ast.dart';
import 'src/compiler/compiler.dart';
import 'src/engine/engine.dart';
import 'src/config.dart';

export 'src/ast/ast.dart';
export 'src/compiler/compiler.dart';
export 'src/engine/engine.dart';
export 'src/config.dart';

/// Creates a new Blade template engine instance
Blade blade({BladeConfig config = const BladeConfig()}) => Blade(config);

/// The main entry point for the Blade template engine
class Blade {
  /// The configuration options
  final BladeConfig config;

  /// The compiler instance
  late final Compiler _compiler;

  /// The engine instance
  late final Engine _engine;

  /// Creates a new Blade instance with the given configuration
  Blade(this.config) {
    _compiler = Compiler(config);
    _engine = Engine(config);
  }

  /// Compiles a template string into executable code
  Future<String> compile(String template, {String? path}) async {
    try {
      var source = SourceFile.fromString(template, url: path);
      return await _compiler.compile(source);
    } catch (e, stackTrace) {
      if (e is BladeError) rethrow;
      var source = SourceFile.fromString(template, url: path);
      throw BladeError(
        BladeErrorSeverity.error,
        'Failed to compile template: $e',
        source.span(0),
        e,
      );
    }
  }

  /// Renders a template with the given data
  Future<String> render(String template, Map<String, dynamic> data,
      {String? path}) async {
    var compiled = await compile(template, path: path);
    return await _engine.render(compiled, data);
  }

  /// Registers a custom directive
  void directive(String name, DirectiveHandler handler) {
    if (name.startsWith('@')) {
      name = name.substring(1);
    }
    (config.directives as Map<String, DirectiveHandler>)[name] = handler;
  }

  /// Registers a custom component
  void component(String name, ComponentFactory factory) {
    (config.components as Map<String, ComponentFactory>)[name] = factory;
  }

  /// Creates a new child Blade instance with additional configuration
  Blade extend(BladeConfig config) {
    return Blade(BladeConfig(
      cache: config.cache,
      minify: config.minify,
      debug: config.debug,
      directives: {
        ...this.config.directives,
        ...config.directives,
      },
      components: {
        ...this.config.components,
        ...config.components,
      },
    ));
  }

  /// Clear the template cache
  void clearCache() {
    _engine.clearCache();
  }
}
