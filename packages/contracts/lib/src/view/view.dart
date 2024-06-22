
import "package:protevus_contracts/support.dart";

abstract class View extends Renderable {
  /// Get the name of the view.
  String name();

  /// Add a piece of data to the view.
  ///
  /// @param String|Map key
  /// @param dynamic value
  /// @return View
  View with(dynamic key, [dynamic value]);

  /// Get the array of view data.
  Map<String, dynamic> getData();
}
