import 'property_info.dart';
import 'method_info.dart';
import 'constructor_info.dart';

/// Information about a type.
///
/// Contains metadata about a type including:
/// - The type itself
/// - Properties defined on the type
/// - Methods defined on the type
/// - Constructors defined on the type
class TypeInfo {
  /// The type being described
  final Type type;

  /// List of properties defined on this type
  final List<PropertyInfo> properties;

  /// List of methods defined on this type
  final List<MethodInfo> methods;

  /// List of constructors defined on this type
  final List<ConstructorInfo> constructors;

  /// Creates a new [TypeInfo] instance.
  ///
  /// All parameters are required:
  /// - [type]: The type being described
  /// - [properties]: List of properties defined on the type
  /// - [methods]: List of methods defined on the type
  /// - [constructors]: List of constructors defined on the type
  const TypeInfo({
    required this.type,
    required this.properties,
    required this.methods,
    required this.constructors,
  });

  @override
  String toString() => 'TypeInfo(type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypeInfo &&
        other.type == type &&
        _listEquals(other.properties, properties) &&
        _listEquals(other.methods, methods) &&
        _listEquals(other.constructors, constructors);
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      Object.hashAll(properties),
      Object.hashAll(methods),
      Object.hashAll(constructors),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
