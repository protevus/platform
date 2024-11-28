/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Contract for reflected type parameters
abstract class ReflectedTypeParameterContract {
  /// Gets the name of the type parameter
  String get name;
}

/// Contract for reflected types
abstract class ReflectedTypeContract {
  /// Gets the name of the type
  String get name;

  /// Gets the type parameters if the type is generic
  List<ReflectedTypeParameterContract> get typeParameters;

  /// Gets the actual Dart type being reflected
  Type get reflectedType;

  /// Checks if this type is assignable to another type
  bool isAssignableTo(ReflectedTypeContract? other);

  /// Creates a new instance of this type
  ReflectedInstanceContract newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]);
}

/// Contract for reflected parameters
abstract class ReflectedParameterContract {
  /// Gets the parameter name
  String get name;

  /// Gets the parameter annotations
  List<ReflectedInstanceContract> get annotations;

  /// Gets the parameter type
  ReflectedTypeContract get type;

  /// Whether the parameter is required
  bool get isRequired;

  /// Whether the parameter is named
  bool get isNamed;
}

/// Contract for reflected functions
abstract class ReflectedFunctionContract {
  /// Gets the function name
  String get name;

  /// Gets the function's type parameters
  List<ReflectedTypeParameterContract> get typeParameters;

  /// Gets the function's annotations
  List<ReflectedInstanceContract> get annotations;

  /// Gets the function's return type
  ReflectedTypeContract? get returnType;

  /// Gets the function's parameters
  List<ReflectedParameterContract> get parameters;

  /// Whether the function is a getter
  bool get isGetter;

  /// Whether the function is a setter
  bool get isSetter;

  /// Invokes the function
  ReflectedInstanceContract invoke(Invocation invocation);
}

/// Contract for reflected declarations
abstract class ReflectedDeclarationContract {
  /// Gets the declaration name
  String get name;

  /// Whether the declaration is static
  bool get isStatic;

  /// Gets the associated function if any
  ReflectedFunctionContract? get function;
}

/// Contract for reflected classes
abstract class ReflectedClassContract extends ReflectedTypeContract {
  /// Gets the class annotations
  List<ReflectedInstanceContract> get annotations;

  /// Gets the class constructors
  List<ReflectedFunctionContract> get constructors;

  /// Gets the class declarations
  List<ReflectedDeclarationContract> get declarations;
}

/// Contract for reflected instances
abstract class ReflectedInstanceContract {
  /// Gets the instance type
  ReflectedTypeContract get type;

  /// Gets the instance class
  ReflectedClassContract get clazz;

  /// Gets the actual instance being reflected
  Object? get reflectee;

  /// Gets a field value
  ReflectedInstanceContract getField(String name);
}

/// Core reflector contract for type introspection.
///
/// This contract defines the interface for reflection capabilities,
/// allowing runtime inspection and manipulation of types, classes,
/// functions, and instances.
abstract class ReflectorContract {
  /// Gets the name from a symbol
  String? getName(Symbol symbol);

  /// Reflects a class type
  ReflectedClassContract? reflectClass(Type clazz);

  /// Reflects a function
  ReflectedFunctionContract? reflectFunction(Function function);

  /// Reflects a type
  ReflectedTypeContract? reflectType(Type type);

  /// Reflects an instance
  ReflectedInstanceContract? reflectInstance(Object object);

  /// Reflects the Future of a type
  ///
  /// Throws:
  ///   - UnsupportedError if dart:mirrors is not available
  ReflectedTypeContract reflectFutureOf(Type type);
}
