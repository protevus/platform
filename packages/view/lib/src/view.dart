import 'package:path/path.dart' as path;
import 'engine.dart';
import 'factory.dart';

/// Represents a view instance that can be rendered
class View {
  /// The view factory instance
  final Factory factory;

  /// The engine implementation
  final Engine engine;

  /// The name of the view
  final String path;

  /// The data passed to the view
  final Map<String, dynamic> data;

  /// The path to the view file
  String? _path;

  View(this.factory, this.engine, this.path, [this.data = const {}]);

  /// Get the string contents of the view
  Future<String> render() async {
    return await engine.get(this);
  }

  /// Get the evaluated contents of the view
  String toString() {
    return path;
  }

  /// Get the full path to the view
  String getPath() {
    if (_path != null) return _path!;
    _path = factory.finder.find(path);
    return _path!;
  }
}
