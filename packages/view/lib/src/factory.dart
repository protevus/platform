import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/mirrors.dart';
import 'package:illuminate_events/events.dart';

import 'concerns/manages_components.dart';
import 'concerns/manages_events.dart';
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
        ManagesFragments,
        ManagesEvents
    implements ViewFactoryContract {
  /// The engine resolver instance.
  final EngineResolver _engines;

  /// The view finder implementation.
  final ViewFinder _finder;

  /// Data that should be available to all templates.
  final Map<String, dynamic> _shared = {};

  /// The event dispatcher instance.
  @override
  final EventDispatcher events;

  /// The IoC container instance.
  @override
  final Container container;

  /// The extension to engine bindings.
  final Map<String, String> _extensions = {
    'html': 'file',
    'dart': 'template',
  };

  /// Create a new factory instance.
  ViewFactory(EngineResolver engines, ViewFinder finder)
      : _engines = engines,
        _finder = finder,
        container = Container(MirrorsReflector()),
        events = EventDispatcher() {
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
  @override
  String normalizeName(String name) {
    return name.replaceAll('.', '/');
  }

  String _normalizeName(String name) {
    return normalizeName(name);
  }

  @override
  List<Function> creators(Map<Function, List<String>> creators) {
    final registered = <Function>[];
    creators.forEach((callback, views) {
      registered.addAll(creator(views, callback));
    });
    return registered;
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
