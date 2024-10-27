import 'dart:async';
import 'package:path/path.dart' as path;
import 'engine.dart';
import 'finder.dart';
import 'view.dart';
import 'exceptions.dart';

/// The view factory implementation
class Factory {
  /// The view finder implementation
  final ViewFinder finder;

  /// The engine resolver callback
  final FutureOr<Engine> Function(String) engineResolver;

  /// The extension to engine mappings
  final Map<String, String> extensions;

  /// The shared data for the factory
  final Map<String, dynamic> _shared = {};

  /// The view composers
  final Map<String, List<Function(View)>> _composers = {};

  /// The view creators
  final Map<String, List<Function(View)>> _creators = {};

  Factory(this.finder, this.engineResolver, [this.extensions = const {}]);

  /// Create a new view instance
  Future<View> make(String path, [Map<String, dynamic> data = const {}]) async {
    String normalizedPath = _normalizePath(path);
    
    // Determine the engine for this view
    String extension = path.split('.').last;
    String engineName = extensions[extension] ?? 'file';
    Engine engine = await engineResolver(engineName);

    // Create the view instance
    View view = View(this, engine, normalizedPath, {..._shared, ...data});

    // Call creators
    _callCreators(view);
    
    // Call composers
    _callComposers(view);

    return view;
  }

  /// Add a piece of shared data to the factory
  void share(String key, dynamic value) {
    _shared[key] = value;
  }

  /// Register a view composer
  void composer(String path, Function(View) callback) {
    _composers.putIfAbsent(path, () => []).add(callback);
  }

  /// Register a view creator
  void creator(String path, Function(View) callback) {
    _creators.putIfAbsent(path, () => []).add(callback);
  }

  /// Call the creators for a given view
  void _callCreators(View view) {
    List<Function(View)>? creators = _creators[view.path];
    creators?.forEach((creator) => creator(view));
  }

  /// Call the composers for a given view
  void _callComposers(View view) {
    List<Function(View)>? composers = _composers[view.path];
    composers?.forEach((composer) => composer(view));
  }

  /// Normalize the given view path
  String _normalizePath(String path) {
    return path.replaceAll('.', '/');
  }
}
