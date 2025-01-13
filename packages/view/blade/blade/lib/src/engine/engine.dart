import 'package:source_span/source_span.dart';
import '../ast/ast.dart';
import '../config.dart';

/// The runtime engine for executing compiled Blade templates
class Engine {
  /// The configuration for the engine
  final BladeConfig config;

  /// Cache for compiled templates
  final Map<String, String> _cache = {};

  /// Create a new engine with the given configuration
  Engine(this.config);

  /// Render a compiled template with the given data
  Future<String> render(String compiled, Map<String, dynamic> data) async {
    try {
      // Create a new context for this render
      var context = RenderContext(
        data: data,
        config: config,
        engine: this,
      );

      // Execute the compiled template
      return await context.execute(compiled);
    } catch (e, stackTrace) {
      if (e is BladeError) rethrow;
      var source = SourceFile.fromString(compiled);
      throw BladeError(
        BladeErrorSeverity.error,
        'Runtime error: $e',
        source.span(0),
        e,
      );
    }
  }

  /// Include another template with the given data
  Future<String> include(String name, Map<String, dynamic> data) async {
    // Check cache first
    var compiled = config.cache ? _cache[name] : null;

    if (compiled == null) {
      // Load and compile the template
      // This would be implemented by the specific view engine integration
      throw UnimplementedError('Template loading not implemented');
    }

    // Render the included template
    return await render(compiled, data);
  }

  /// Clear the template cache
  void clearCache() {
    _cache.clear();
  }
}

/// Context for rendering a template
class RenderContext {
  /// The data available to the template
  final Map<String, dynamic> data;

  /// The configuration for the engine
  final BladeConfig config;

  /// The engine instance
  final Engine engine;

  /// Stack for tracking section content
  final Map<String, List<String>> _sections = {};

  /// Stack for tracking loops
  final List<Map<String, dynamic>> _loops = [];

  /// Create a new render context
  RenderContext({
    required this.data,
    required this.config,
    required this.engine,
  });

  /// Execute a compiled template
  Future<String> execute(String compiled) async {
    // This would evaluate the compiled template code
    // For now, just return the compiled code for debugging
    return compiled;
  }

  /// Push a new loop context
  void pushLoop(Map<String, dynamic> context) {
    _loops.add(context);
  }

  /// Pop the current loop context
  Map<String, dynamic> popLoop() {
    if (_loops.isEmpty) {
      throw StateError('No active loop');
    }
    return _loops.removeLast();
  }

  /// Get the current loop context
  Map<String, dynamic>? get currentLoop {
    if (_loops.isEmpty) return null;
    return _loops.last;
  }

  /// Start a new section
  void startSection(String name) {
    _sections[name] = [];
  }

  /// End the current section
  List<String> endSection(String name) {
    var content = _sections.remove(name);
    if (content == null) {
      throw StateError('No active section: $name');
    }
    return content;
  }

  /// Get a section's content
  List<String>? getSection(String name) => _sections[name];

  /// Include another template
  Future<String> include(String name, [Map<String, dynamic>? data]) {
    return engine.include(name, {
      ...this.data,
      ...?data,
    });
  }

  /// Get a value from the context
  dynamic getValue(String name) {
    // Check loop variables first
    if (currentLoop != null && currentLoop!.containsKey(name)) {
      return currentLoop![name];
    }

    // Then check data
    return data[name];
  }

  /// Set a value in the context
  void setValue(String name, dynamic value) {
    data[name] = value;
  }
}
