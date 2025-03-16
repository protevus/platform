import 'engine.dart';

/// Factory for managing view engines.
class ViewFactory {
  final Map<String, ViewEngine> _engines = {};
  final Map<String, String> _extensions = {};
  final Map<String, dynamic> _shared = {};

  /// Register a new engine.
  void register(ViewEngine engine) {
    _engines[engine.name] = engine;

    // Map extensions to engine
    for (var ext in engine.extensions) {
      _extensions[ext] = engine.name;
    }
  }

  /// Get an engine by name.
  ViewEngine? engine(String name) => _engines[name];

  /// Get the default engine.
  ViewEngine get defaultEngine {
    if (_engines.isEmpty) {
      throw Exception('No view engines registered.');
    }
    return _engines.values.first;
  }

  /// Make a view using the appropriate engine.
  Future<String> make(String view, [Map<String, dynamic>? data]) async {
    final engine = _resolveEngine(view);

    // Merge shared data
    final viewData = {
      ..._shared,
      ...?data,
    };

    return engine.get(view, viewData);
  }

  /// Share data with all views.
  void share(String key, dynamic value) {
    _shared[key] = value;

    // Share with all engines
    for (var engine in _engines.values) {
      engine.share(key, value);
    }
  }

  /// Get all shared data.
  Map<String, dynamic> get shared => Map.unmodifiable(_shared);

  /// Resolve the engine for a view.
  ViewEngine _resolveEngine(String view) {
    // Get extension
    final ext = view.split('.').last;

    // Find engine for extension
    final engineName = _extensions[ext];
    if (engineName != null) {
      final engine = _engines[engineName];
      if (engine != null) {
        return engine;
      }
    }

    // Use default engine
    return defaultEngine;
  }
}
