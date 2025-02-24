import 'dart:async';

import 'contracts/base.dart';
import 'contracts/view.dart';

/// The main View implementation.
class ViewImpl implements View {
  /// The view factory instance.
  final ViewFactoryContract _factory;

  /// The engine implementation.
  final ViewEngine _engine;

  /// The name of the view.
  @override
  final String name;

  /// The path to the view file.
  @override
  final String path;

  /// The array of view data.
  @override
  final Map<String, dynamic> data;

  /// The parent view being extended.
  View? _parent;

  @override
  View? get parent => _parent;

  @override
  set parent(View? view) {
    _parent = view;
  }

  @override
  bool get hasParent => _parent != null;

  /// Create a new view instance.
  ViewImpl(
    this._factory,
    this._engine,
    this.name,
    this.path, [
    Map<String, dynamic>? data,
  ]) : data = Map<String, dynamic>.from(data ?? {});

  @override
  View withData(String key, dynamic value) {
    data[key] = value;
    return this;
  }

  @override
  View withManyData(Map<String, dynamic> additionalData) {
    data.addAll(additionalData);
    return this;
  }

  /// Get the evaluated contents of the view.
  @override
  Future<String> render() async {
    try {
      // Start rendering this view
      _factory.startRender(this);

      // Gather all data including shared data from factory
      final allData = _gatherData();

      // Get the contents using the engine
      final contents = await _engine.get(path, allData);

      // If this view has a parent, render it
      if (hasParent) {
        return await parent!.render();
      }

      // Stop rendering this view
      _factory.stopRender();

      return contents;
    } catch (e, stackTrace) {
      throw ViewException(
        'Error rendering view "$name"',
        e is ViewException ? e : '$e\n$stackTrace',
      );
    }
  }

  /// Get the data bound to the view instance.
  Map<String, dynamic> _gatherData() {
    final allData = Map<String, dynamic>.from(_factory.shared)..addAll(data);

    // Handle any nested renderable views
    for (final entry in allData.entries) {
      if (entry.value is View) {
        allData[entry.key] = (entry.value as View).render();
      }
    }

    return allData;
  }

  @override
  Map<String, dynamic> toArray() =>
      Map<String, dynamic>.unmodifiable(_gatherData());

  @override
  String toHtml() => toString();

  @override
  String toString() => 'View($name)';
}
