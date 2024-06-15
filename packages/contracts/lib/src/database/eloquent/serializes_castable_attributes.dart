import 'package:your_package_name/eloquent/model.dart';

abstract class SerializesCastableAttributes {
  /// Serialize the attribute when converting the model to an array.
  ///
  /// @param  \Illuminate\Database\Eloquent\Model  $model
  /// @param  string  $key
  /// @param  mixed  $value
  /// @param  array  $attributes
  /// @return mixed
  dynamic serialize(Model model, String key, dynamic value, Map<String, dynamic> attributes);
}
