abstract class Engine {
  /// Get the evaluated contents of the view.
  ///
  /// @param  String path
  /// @param  Map<String, dynamic> data
  /// @return String
  String get(String path, {Map<String, dynamic> data = const {}});
}
