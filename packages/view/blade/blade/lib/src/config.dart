import 'ast/components.dart';
import 'ast/ast.dart';

/// Configuration options for the Blade template engine
class BladeConfig {
  /// Whether to cache compiled templates
  final bool cache;

  /// Whether to minify output HTML
  final bool minify;

  /// Whether to enable debug mode
  final bool debug;

  /// Custom directives to register
  final Map<String, DirectiveHandler> directives;

  /// Custom components to register
  final Map<String, ComponentFactory> components;

  /// Create a new configuration
  const BladeConfig({
    this.cache = true,
    this.minify = false,
    this.debug = false,
    this.directives = const {},
    this.components = const {},
  });

  /// Create a new configuration with some values overridden
  BladeConfig copyWith({
    bool? cache,
    bool? minify,
    bool? debug,
    Map<String, DirectiveHandler>? directives,
    Map<String, ComponentFactory>? components,
  }) {
    return BladeConfig(
      cache: cache ?? this.cache,
      minify: minify ?? this.minify,
      debug: debug ?? this.debug,
      directives: directives ?? Map.from(this.directives),
      components: components ?? Map.from(this.components),
    );
  }
}

/// Function type for custom directive handlers
typedef DirectiveHandler = String Function(String? parameters);

/// Function type for component factories
typedef ComponentFactory = Component Function(Map<String, dynamic> attributes);

/// Function type for error handlers
typedef ErrorHandler = void Function(BladeError error);
