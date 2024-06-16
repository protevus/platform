import 'view.dart';

abstract class Factory {
  /// Determine if a given view exists.
  ///
  /// @param  String  view
  /// @return bool
  bool exists(String view);

  /// Get the evaluated view contents for the given path.
  ///
  /// @param  String  path
  /// @param  Map<String, dynamic>  data
  /// @param  Map<String, dynamic>  mergeData
  /// @return View
  View file(String path, {Map<String, dynamic>? data, Map<String, dynamic>? mergeData});

  /// Get the evaluated view contents for the given view.
  ///
  /// @param  String  view
  /// @param  Map<String, dynamic>  data
  /// @param  Map<String, dynamic>  mergeData
  /// @return View
  View make(String view, {Map<String, dynamic>? data, Map<String, dynamic>? mergeData});

  /// Add a piece of shared data to the environment.
  ///
  /// @param  dynamic  key
  /// @param  dynamic  value
  /// @return dynamic
  dynamic share(dynamic key, {dynamic value});

  /// Register a view composer event.
  ///
  /// @param  dynamic  views
  /// @param  dynamic  callback
  /// @return List
  List composer(dynamic views, dynamic callback);

  /// Register a view creator event.
  ///
  /// @param  dynamic  views
  /// @param  dynamic  callback
  /// @return List
  List creator(dynamic views, dynamic callback);

  /// Add a new namespace to the loader.
  ///
  /// @param  String  namespace
  /// @param  dynamic  hints
  /// @return Factory
  Factory addNamespace(String namespace, dynamic hints);

  /// Replace the namespace hints for the given namespace.
  ///
  /// @param  String  namespace
  /// @param  dynamic  hints
  /// @return Factory
  Factory replaceNamespace(String namespace, dynamic hints);
}
