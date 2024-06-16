//import 'package:your_package_name/htmlable.dart';

abstract class DeferringDisplayableValue {
  /// Resolve the displayable value that the class is deferring.
  ///
  /// @return Htmlable or String
  dynamic resolveDisplayableValue(); // Return type is dynamic to allow Htmlable or String
}
