import 'router.dart';

/// Base interface for all routing styles.
///
/// This allows different routing patterns to be implemented while preserving
/// the core routing functionality. Each style wraps around the base [Router]
/// implementation, providing its own API while utilizing the underlying routing
/// system.
abstract class RoutingStyle<T> {
  /// The underlying router instance that handles actual routing.
  Router<T> get router;

  /// Unique identifier for this routing style.
  String get styleName;

  /// Initialize the routing style.
  ///
  /// This is called when the style is activated through the registry.
  /// Use this to set up any style-specific configuration or state.
  void initialize();

  /// Clean up any resources used by this style.
  ///
  /// This is called when switching to a different style or shutting down.
  void dispose() {}
}

/// Registry for managing different routing styles.
///
/// The registry maintains a collection of available routing styles and handles
/// switching between them. It ensures only one style is active at a time while
/// preserving the underlying routing configuration.
class RoutingStyleRegistry<T> {
  final Map<String, RoutingStyle<T>> _styles = {};
  RoutingStyle<T>? _activeStyle;
  final Router<T> _baseRouter;

  /// Creates a new routing style registry.
  ///
  /// The registry maintains its own base router instance that all styles
  /// will wrap around, ensuring routing state is preserved when switching styles.
  RoutingStyleRegistry() : _baseRouter = Router<T>();

  /// Register a new routing style.
  ///
  /// Each style must have a unique [styleName]. Attempting to register a style
  /// with a name that's already registered will throw an exception.
  ///
  /// ```dart
  /// registry.registerStyle(ExpressStyle(registry.baseRouter));
  /// registry.registerStyle(LaravelStyle(registry.baseRouter));
  /// ```
  void registerStyle(RoutingStyle<T> style) {
    if (_styles.containsKey(style.styleName)) {
      throw StateError(
          'A style with name "${style.styleName}" is already registered');
    }
    _styles[style.styleName] = style;
  }

  /// Activate a registered routing style.
  ///
  /// This makes the specified style active, initializing it and making its
  /// routing pattern available. Any previously active style will be disposed.
  ///
  /// ```dart
  /// registry.useStyle('express'); // Use Express-style routing
  /// registry.useStyle('laravel'); // Switch to Laravel-style routing
  /// ```
  ///
  /// Throws a [StateError] if the style name is not registered.
  void useStyle(String styleName) {
    if (!_styles.containsKey(styleName)) {
      throw StateError('No routing style registered with name "$styleName"');
    }

    // Dispose previous style if exists
    _activeStyle?.dispose();

    // Activate new style
    _activeStyle = _styles[styleName];
    _activeStyle!.initialize();
  }

  /// The currently active routing style.
  ///
  /// Returns null if no style is active.
  RoutingStyle<T>? get activeStyle => _activeStyle;

  /// The underlying router instance.
  ///
  /// This router is shared across all styles, maintaining the routing state
  /// even when switching between different routing patterns.
  Router<T> get baseRouter => _baseRouter;
}

/// Base interface for middleware style adapters.
///
/// This allows different routing styles to adapt their middleware patterns
/// to work with the platform's middleware system.
abstract class MiddlewareStyle<T> {
  /// Convert framework-specific middleware to platform middleware.
  ///
  /// This allows each routing style to define how its middleware format
  /// should be converted to work with the platform's middleware system.
  ///
  /// ```dart
  /// // Example Laravel-style middleware adaptation
  /// T adaptMiddleware(dynamic middleware) {
  ///   if (middleware is String) {
  ///     return resolveMiddlewareFromContainer(middleware);
  ///   }
  ///   return middleware as T;
  /// }
  /// ```
  T adaptMiddleware(dynamic originalMiddleware);
}
