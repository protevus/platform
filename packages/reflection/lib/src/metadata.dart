import 'package:platform_reflection/mirrors.dart';

/// Represents metadata about a type parameter.
class TypeParameterMetadata {
  /// The name of the type parameter (e.g., 'T', 'E').
  final String name;

  /// The type of the parameter.
  final Type type;

  /// The upper bound of the type parameter, if any.
  final Type? bound;

  /// Any attributes (annotations) on this type parameter.
  final List<Object> attributes;

  /// Creates a new type parameter metadata instance.
  const TypeParameterMetadata({
    required this.name,
    required this.type,
    this.bound,
    this.attributes = const [],
  });
}

/// Represents metadata about a parameter.
class ParameterMetadata {
  /// The name of the parameter.
  final String name;

  /// The type of the parameter.
  final Type type;

  /// Whether this parameter is required.
  final bool isRequired;

  /// Whether this parameter is named.
  final bool isNamed;

  /// The default value for this parameter, if any.
  final Object? defaultValue;

  /// Any attributes (annotations) on this parameter.
  final List<Object> attributes;

  /// Creates a new parameter metadata instance.
  const ParameterMetadata({
    required this.name,
    required this.type,
    required this.isRequired,
    this.isNamed = false,
    this.defaultValue,
    this.attributes = const [],
  });
}

/// Represents metadata about a type's property.
class PropertyMetadata {
  /// The name of the property.
  final String name;

  /// The type of the property.
  final Type type;

  /// Whether the property can be read.
  final bool isReadable;

  /// Whether the property can be written to.
  final bool isWritable;

  /// Any attributes (annotations) on this property.
  final List<Object> attributes;

  /// Creates a new property metadata instance.
  const PropertyMetadata({
    required this.name,
    required this.type,
    this.isReadable = true,
    this.isWritable = true,
    this.attributes = const [],
  });
}

/// Represents metadata about a type's method.
class MethodMetadata {
  /// The name of the method.
  final String name;

  /// The parameter types of the method in order.
  final List<Type> parameterTypes;

  /// Detailed metadata about each parameter.
  final List<ParameterMetadata> parameters;

  /// Whether the method is static.
  final bool isStatic;

  /// Whether the method returns void.
  final bool returnsVoid;

  /// The return type of the method.
  final Type returnType;

  /// Any attributes (annotations) on this method.
  final List<Object> attributes;

  /// Type parameters for generic methods.
  final List<TypeParameterMetadata> typeParameters;

  /// Creates a new method metadata instance.
  const MethodMetadata({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    this.isStatic = false,
    this.attributes = const [],
    this.typeParameters = const [],
  });

  /// Validates the given arguments against this method's parameter types.
  bool validateArguments(List<Object?> arguments) {
    if (arguments.length != parameterTypes.length) return false;

    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg != null && arg.runtimeType != parameterTypes[i]) {
        return false;
      }
    }

    return true;
  }
}

/// Represents metadata about a type's constructor.
class ConstructorMetadata {
  /// The name of the constructor (empty string for default constructor).
  final String name;

  /// The parameter types of the constructor in order.
  final List<Type> parameterTypes;

  /// The names of the parameters if they are named parameters.
  final List<String>? parameterNames;

  /// Detailed metadata about each parameter.
  final List<ParameterMetadata> parameters;

  /// Any attributes (annotations) on this constructor.
  final List<Object> attributes;

  /// Creates a new constructor metadata instance.
  const ConstructorMetadata({
    this.name = '',
    required this.parameterTypes,
    required this.parameters,
    this.parameterNames,
    this.attributes = const [],
  });

  /// Whether this constructor uses named parameters.
  bool get hasNamedParameters => parameterNames != null;

  /// Validates the given arguments against this constructor's parameter types.
  bool validateArguments(List<Object?> arguments) {
    if (arguments.length != parameterTypes.length) return false;

    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg != null && arg.runtimeType != parameterTypes[i]) {
        return false;
      }
    }

    return true;
  }
}

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

/// Represents metadata about a function.
class FunctionMetadata {
  /// The parameters of the function.
  final List<ParameterMetadata> parameters;

  /// Whether the function returns void.
  final bool returnsVoid;

  /// The return type of the function.
  final Type returnType;

  /// Type parameters for generic functions.
  final List<TypeParameterMetadata> typeParameters;

  /// Creates a new function metadata instance.
  const FunctionMetadata({
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    this.typeParameters = const [],
  });

  /// Validates the given arguments against this function's parameters.
  bool validateArguments(List<Object?> arguments) {
    if (arguments.length != parameters.length) return false;

    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg != null && arg.runtimeType != parameters[i].type) {
        return false;
      }
    }

    return true;
  }
}
