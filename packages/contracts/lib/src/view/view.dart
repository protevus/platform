import '../support/renderable.dart';

/// Interface for views.
abstract class View extends Renderable {
  /// Get the name of the view.
  String name();

  /// Add a piece of data to the view.
  View withData(dynamic key, [dynamic value]);

  /// Get the array of view data.
  Map<String, dynamic> getData();
}
