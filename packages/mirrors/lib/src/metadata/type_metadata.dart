import 'package:platform_mirrors/mirrors.dart';

/// Represents metadata about a type.
class TypeMetadata {
  /// The actual type this metadata represents.
  final Type type;

  /// The name of the type.
  final String name;

  /// The properties defined on this type.
  final Map<String, PropertyMetadata> properties;

  /// The methods defined on this type.
  final Map<String, MethodMetadata> methods;

  /// The constructors defined on this type.
  final List<ConstructorMetadata> constructors;

  /// The supertype of this type, if any.
  final TypeMetadata? supertype;

  /// The interfaces this type implements.
  final List<TypeMetadata> interfaces;

  /// The mixins this type uses.
  final List<TypeMetadata> mixins;

  /// Any attributes (annotations) on this type.
  final List<Object> attributes;

  /// Type parameters for generic types.
  final List<TypeParameterMetadata> typeParameters;

  /// Type arguments if this is a generic type instantiation.
  final List<TypeMetadata> typeArguments;

  /// Creates a new type metadata instance.
  const TypeMetadata({
    required this.type,
    required this.name,
    required this.properties,
    required this.methods,
    required this.constructors,
    this.supertype,
    this.interfaces = const [],
    this.mixins = const [],
    this.attributes = const [],
    this.typeParameters = const [],
    this.typeArguments = const [],
  });

  /// Whether this type is generic (has type parameters).
  bool get isGeneric => typeParameters.isNotEmpty;

  /// Whether this is a generic type instantiation.
  bool get isGenericInstantiation => typeArguments.isNotEmpty;

  /// Gets a property by name, throwing if not found.
  PropertyMetadata getProperty(String name) {
    final property = properties[name];
    if (property == null) {
      throw MemberNotFoundException(name, type);
    }
    return property;
  }

  /// Gets a method by name, throwing if not found.
  MethodMetadata getMethod(String name) {
    final method = methods[name];
    if (method == null) {
      throw MemberNotFoundException(name, type);
    }
    return method;
  }

  /// Gets the default constructor, throwing if not found.
  ConstructorMetadata get defaultConstructor {
    return constructors.firstWhere(
      (c) => c.name.isEmpty,
      orElse: () => throw ReflectionException(
        'No default constructor found for type "$name"',
      ),
    );
  }

  /// Gets a named constructor, throwing if not found.
  ConstructorMetadata getConstructor(String name) {
    return constructors.firstWhere(
      (c) => c.name == name,
      orElse: () => throw ReflectionException(
        'Constructor "$name" not found for type "$type"',
      ),
    );
  }
}
