import 'model.dart';

/// A generic type parameter for the get method.
typedef TGet = dynamic;

/// A generic type parameter for the set method.
typedef TSet = dynamic;

/// An abstract class representing a contract for casting attributes.
abstract class CastsAttributes {
  /// Transforms the attribute from the underlying model values.
  ///
  /// [model] - The model instance.
  /// [key] - The attribute key.
  /// [value] - The attribute value.
  /// [attributes] - The attributes array.
  ///
  /// Returns the transformed attribute value.
  TGet? get(Model model, String key, dynamic value, Map<String, dynamic> attributes);

  /// Transforms the attribute to its underlying model values.
  ///
  /// [model] - The model instance.
  /// [key] - The attribute key.
  /// [value] - The attribute value to be set.
  /// [attributes] - The attributes array.
  ///
  /// Returns the transformed attribute value.
  dynamic set(Model model, String key, TSet? value, Map<String, dynamic> attributes);
}
