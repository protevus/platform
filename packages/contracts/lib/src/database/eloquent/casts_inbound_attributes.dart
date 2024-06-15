import 'package:your_package/database/model.dart';

abstract class CastsInboundAttributes {
  /// Transform the attribute to its underlying model values.
  ///
  /// @param  Model  model
  /// @param  String  key
  /// @param  dynamic  value
  /// @param  Map<String, dynamic>  attributes
  /// @return dynamic
  dynamic set(Model model, String key, dynamic value, Map<String, dynamic> attributes);
}
