import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'concerns/manages_components.dart';
import 'concerns/manages_fragments.dart';
import 'concerns/manages_inheritance.dart';
import 'concerns/manages_layouts.dart';
import 'concerns/manages_loops.dart';
import 'concerns/manages_stacks.dart';
import 'contracts/base.dart';
import 'contracts/view.dart';
import 'engines/engine_resolver.dart';
import 'view.dart';

/// The View Factory implementation.
class ViewFactory
    with
        ManagesLayouts,
        ManagesInheritance,
        ManagesLoops,
        ManagesStacks,
        ManagesComponents,
        ManagesFragments
    implements ViewFactoryContract {
  /// The engine resolver instance.
  final EngineResolver _engines;

  /// The view finder implementation.
  final ViewFinder _finder;

  /// Data that should be available to all templates.
  final Map<String, dynamic> _shared = {};

  /// The view creator events.
  final Map<String, List<Function>> _creators = {};

  /// The view composer events.
  final Map<String, List<Function>> _composers = {};

  /// The extension to engine bindings.
  final Map<String, String> _extensions = {
    'html': 'file',
    'dart': 'template',
  };

  /// Create a new factory instance.
  ViewFactory(EngineResolver engines, ViewFinder finder)
      : _engines = engines,
        _finder = finder {
    // Register default engines
    _engines.register('file', () => FileEngine());
    _engines.register('template', () => TemplateEngine());
  }

  @override
  Future<View> make(String view, [Map<String, dynamic>? data]) async {
    final normalizedView = _normalizeName(view);
    final path = _finder.find(normalizedView);

    final viewInstance = _viewInstance(
      normalizedView,
      path,
      data ?? {},
    );

    callCreator(viewInstance);
    callComposer(viewInstance);

    return viewInstance;
  }

  @override
  bool exists(String view) {
    try {
      _finder.find(_normalizeName(view));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void share(String key, dynamic value) {
    _shared[key] = value;
  }

  @override
  void addLocation(String location) {
    _finder.addLocation(location);
  }

  @override
  ViewFactoryContract addNamespace(String namespace, List<String> hints) {
    _finder.addNamespace(namespace, hints);
    return this;
  }

  @override
  void addExtension(String extension, String engine) {
    _finder.addExtension(extension);
    _extensions[extension] = engine;
  }

  @override
  Map<String, dynamic> get shared => Map.unmodifiable(_shared);

  @override
  bool isCached(String view) {
    final normalizedView = _normalizeName(view);
    return (_finder as FileViewFinder)._viewCache.containsKey(normalizedView);
  }

  @override
  String? getCachedPath(String view) {
    final normalizedView = _normalizeName(view);
    return (_finder as FileViewFinder)._viewCache[normalizedView];
  }

  @override
  void flushCache() {
    _finder.flush();
  }

  @override
  Future<void> extendView(String name, [Map<String, dynamic>? data]) async {
    if (currentView == null) {
      throw ViewException(
          'Cannot extend view: no view is currently being rendered.');
    }

    // Create the parent view
    final parentView = await make(name, data);
    currentView!.parent = parentView;
  }

  @override
  void flushState() {
    flushSections();
    flushLoops();
    flushStacks();
    flushComponents();
    flushFragments();
    super.flushState();
  }

  @override
  void creator(dynamic views, Function callback) {
    final viewsList = views is List ? views : [views];

    for (final view in viewsList) {
      final normalizedView = _normalizeName(view.toString());
      _creators[normalizedView] ??= [];
      _creators[normalizedView]!.add(callback);
    }
  }

  @override
  void creators(Map<Function, List<String>> creators) {
    creators.forEach((callback, views) {
      creator(views, callback);
    });
  }

  @override
  void callCreator(View view) {
    final creators = _creators[view.name];
    if (creators != null) {
      for (final callback in creators) {
        callback(view);
      }
    }
  }

  @override
  void composer(dynamic views, Function callback) {
    final viewsList = views is List ? views : [views];

    for (final view in viewsList) {
      final normalizedView = _normalizeName(view.toString());
      _composers[normalizedView] ??= [];
      _composers[normalizedView]!.add(callback);
    }
  }

  @override
  void composers(Map<Function, List<String>> composers) {
    composers.forEach((callback, views) {
      composer(views, callback);
    });
  }

  @override
  void callComposer(View view) {
    final composers = _composers[view.name];
    if (composers != null) {
      for (final callback in composers) {
        callback(view);
      }
    }
  }

  /// Create a new view instance.
  View _viewInstance(String view, String path, Map<String, dynamic> data) {
    return ViewImpl(
      this,
      _getEngineFromPath(path),
      view,
      path,
      data,
    );
  }

  /// Get the appropriate view engine for the given path.
  ViewEngine _getEngineFromPath(String filePath) {
    final extension = path.extension(filePath).replaceFirst('.', '');
    final engineName = _extensions[extension];

    if (engineName == null) {
      throw ViewException('Unrecognized extension in file: $filePath');
    }

    return _engines.resolve(engineName);
  }

  /// Normalize a view name.
  String _normalizeName(String name) {
    return name.replaceAll('.', '/');
  }
}

/// The View Finder implementation.
class FileViewFinder implements ViewFinder {
  /// The list of view paths.
  final List<String> _paths = [];

  /// The list of namespace hints.
  final Map<String, List<String>> _hints = {};

  /// The list of registered extensions.
  final Set<String> _extensions = {'html', 'dart'};

  /// The cache of located views.
  final Map<String, String> _viewCache = {};

  @override
  String find(String name) {
    // Check if the view is in cache
    if (_viewCache.containsKey(name)) {
      return _viewCache[name]!;
    }

    final path =
        name.contains('::') ? _findNamespacedView(name) : _findInPaths(name);

    // Cache the result
    _viewCache[name] = path;
    return path;
  }

  @override
  void addLocation(String location) {
    _paths.add(location);
  }

  @override
  void addNamespace(String namespace, List<String> hints) {
    _hints[namespace] = hints;
  }

  /// Add a valid view extension.
  @override
  void addExtension(String extension) {
    _extensions.add(extension);
  }

  @override
  void flush() {
    _viewCache.clear();
  }

  /// Find a namespaced view.
  String _findNamespacedView(String name) {
    final segments = name.split('::');
    if (segments.length != 2) {
      throw ViewException('Invalid view name format: $name');
    }

    final namespace = segments[0];
    final view = segments[1];

    if (!_hints.containsKey(namespace)) {
      throw ViewException('Namespace not found: $namespace');
    }

    return _findInPaths(view, _hints[namespace]);
  }

  /// Find the view in the given paths.
  String _findInPaths(String name, [List<String>? paths]) {
    paths ??= _paths;

    for (final basePath in paths) {
      for (final extension in _extensions) {
        final filePath = path.join(
          basePath,
          '$name.$extension',
        );

        if (File(filePath).existsSync()) {
          return filePath;
        }
      }
    }

    throw ViewException('View not found: $name');
  }
}
