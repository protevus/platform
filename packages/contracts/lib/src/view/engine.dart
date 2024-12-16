/// Interface for view engines.
abstract class Engine {
  /// Get the evaluated contents of the view.
  String get(String path, [Map<String, dynamic> data = const {}]);
}
