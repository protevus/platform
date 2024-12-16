import 'view.dart';

/// Interface for view factory.
abstract class ViewFactory {
  /// Determine if a given view exists.
  bool exists(String view);

  /// Get the evaluated view contents for the given path.
  View file(String path,
      [Map<String, dynamic> data = const {},
      Map<String, dynamic> mergeData = const {}]);

  /// Get the evaluated view contents for the given view.
  View make(String view,
      [Map<String, dynamic> data = const {},
      Map<String, dynamic> mergeData = const {}]);

  /// Add a piece of shared data to the environment.
  dynamic share(dynamic key, [dynamic value]);

  /// Register a view composer event.
  List<dynamic> composer(dynamic views, dynamic callback);

  /// Register a view creator event.
  List<dynamic> creator(dynamic views, dynamic callback);

  /// Add a new namespace to the loader.
  ViewFactory addNamespace(String namespace, dynamic hints);

  /// Replace the namespace hints for the given namespace.
  ViewFactory replaceNamespace(String namespace, dynamic hints);
}
