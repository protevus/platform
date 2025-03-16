import 'dart:io';
import 'package:belatuk_code_buffer/belatuk_code_buffer.dart';
import 'package:belatuk_symbol_table/belatuk_symbol_table.dart';

import '../core/renderer.dart';
import '../text/parser.dart';
import 'engine.dart';
import 'finder.dart';

/// The default Blade template engine.
class BladeEngine implements ViewEngine {
  final Renderer _renderer;
  final ViewFinder _finder;
  final Map<String, dynamic> _shared = {};
  final Map<String, String> _cache = {};
  final Map<String, Function> _creators = {};
  final Map<String, Function> _composers = {};

  BladeEngine(this._renderer, this._finder);

  @override
  String get name => 'blade';

  @override
  List<String> get extensions => ['.blade.html'];

  @override
  Future<String> get(String path, Map<String, dynamic> data) async {
    try {
      // Get view name from path
      final view = path.split('/').last.split('.').first;

      // Call creators
      if (_creators.containsKey(view)) {
        final result = await _creators[view]!();
        if (result is Map) {
          data = {...data, ...result};
        }
      }

      // Call composers before creating scope
      if (_composers.containsKey(view)) {
        await _composers[view]!(data);
      }

      // Create data scope with shared data
      final scope = SymbolTable(values: {
        ..._shared,
        ...data,
      });

      // Parse template
      final template = await File(path).readAsString();
      final document = parseDocument(template, sourceUrl: path)!;

      // Create output buffer
      final buffer = CodeBuffer();

      // Render using core renderer
      _renderer.render(document, buffer, scope);

      return buffer.toString();
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool exists(String view) {
    // Check cache first
    if (_cache.containsKey(view)) {
      return true;
    }

    // Try to find the view
    final path = find(view);
    return path != null;
  }

  @override
  String? find(String view) {
    // Check cache first
    if (_cache.containsKey(view)) {
      return _cache[view];
    }

    // Use finder to locate view
    final path = _finder.find(view);
    if (path != null) {
      _cache[view] = path;
    }

    return path;
  }

  @override
  void creator(dynamic views, Function callback) {
    if (views is String) {
      _creators[views] = callback;
    } else if (views is List) {
      for (var view in views) {
        _creators[view] = callback;
      }
    }
  }

  @override
  void creators(Map<Function, List<String>> creators) {
    for (var entry in creators.entries) {
      for (var view in entry.value) {
        _creators[view] = entry.key;
      }
    }
  }

  @override
  void composer(dynamic views, Function callback) {
    if (views is String) {
      _composers[views] = callback;
    } else if (views is List) {
      for (var view in views) {
        _composers[view] = callback;
      }
    }
  }

  @override
  void composers(Map<Function, List<String>> composers) {
    for (var entry in composers.entries) {
      for (var view in entry.value) {
        _composers[view] = entry.key;
      }
    }
  }

  @override
  void share(String key, dynamic value) {
    _shared[key] = value;
  }

  @override
  Map<String, dynamic> get shared => Map.unmodifiable(_shared);

  @override
  bool isCached(String view) => _cache.containsKey(view);

  @override
  String? getCachedPath(String view) => _cache[view];

  @override
  void flushCache() => _cache.clear();
}
