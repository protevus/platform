import 'view.dart';

/// Abstract engine interface for view rendering
abstract class Engine {
  /// Get the evaluated contents of the view
  Future<String> get(View view);

  /// Add a piece of shared data to the engine
  void share(String key, dynamic value);

  /// Get all of the shared data for the engine
  Map<String, dynamic> getShared();
}
