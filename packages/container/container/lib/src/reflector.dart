/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

/// Abstract class representing a reflector for introspection of Dart types and instances.
///
/// This class provides methods to reflect on various Dart constructs such as classes,
/// functions, types, and instances. It allows for runtime inspection and manipulation
/// of code elements.
///
/// The methods in this class are designed to be implemented by concrete reflector
/// classes, potentially using different reflection mechanisms (e.g., mirrors, code
/// generation).
///
/// Note: The `reflectFutureOf` method throws an `UnsupportedError` by default and
/// requires `dart:mirrors` for implementation.
abstract class Reflector {
  /// Constructs a new [Reflector] instance.
  ///
  /// This constructor is declared as `const` to allow for compile-time constant creation
  /// of [Reflector] instances. Subclasses of [Reflector] may override this constructor
  /// to provide their own initialization logic if needed.
  const Reflector();

  String? getName(Symbol symbol);

  ReflectedClass? reflectClass(Type clazz);

  ReflectedFunction? reflectFunction(Function function);

  ReflectedType? reflectType(Type type);

  ReflectedInstance? reflectInstance(Object object);

  ReflectedType reflectFutureOf(Type type) {
    throw UnsupportedError('`reflectFutureOf` requires `dart:mirrors`.');
  }
}

/// Represents a reflected instance of an object.
///
/// This abstract class provides a way to introspect and manipulate object instances
/// at runtime. It encapsulates information about the object's type, class, and the
/// actual object instance (reflectee).
///
/// The [type] property represents the reflected type of the instance.
/// The [clazz] property represents the reflected class of the instance.
/// The [reflectee] property holds the actual object instance being reflected.
///
/// This class also provides methods for comparing instances and accessing fields.
///
/// Use the [getField] method to retrieve a reflected instance of a specific field.
abstract class ReflectedInstance {
  final ReflectedType type;
  final ReflectedClass clazz;
  final Object? reflectee;

  const ReflectedInstance(this.type, this.clazz, this.reflectee);

  @override
  int get hashCode => hash2(type, clazz);

  @override
  bool operator ==(other) =>
      other is ReflectedInstance && other.type == type && other.clazz == clazz;

  ReflectedInstance getField(String name);
}

/// Represents a reflected type in the Dart language.
///
/// This abstract class encapsulates information about a Dart type, including its name,
/// type parameters, and the actual Dart [Type] it represents.
///
/// The [name] property holds the name of the type.
/// The [typeParameters] list contains the type parameters if the type is generic.
/// The [reflectedType] property holds the actual Dart [Type] being reflected.
///
/// This class provides methods for creating new instances of the type, comparing types,
/// and checking type assignability.
///
/// The [newInstance] method allows for dynamic creation of new instances of the type.
/// The [isAssignableTo] method checks if this type is assignable to another type.
///
/// This class also overrides [hashCode] and [operator ==] for proper equality comparisons.
abstract class ReflectedType {
  final String name;
  final List<ReflectedTypeParameter> typeParameters;
  final Type reflectedType;

  const ReflectedType(this.name, this.typeParameters, this.reflectedType);

  @override
  int get hashCode => hash3(name, typeParameters, reflectedType);

  @override
  bool operator ==(other) =>
      other is ReflectedType &&
      other.name == name &&
      const ListEquality<ReflectedTypeParameter>()
          .equals(other.typeParameters, typeParameters) &&
      other.reflectedType == reflectedType;

  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]);

  bool isAssignableTo(ReflectedType? other);
}

/// Represents a reflected class in the Dart language.
///
/// This abstract class extends [ReflectedType] and provides additional information
/// specific to classes, including annotations, constructors, and declarations.
///
/// The [annotations] list contains reflected instances of annotations applied to the class.
/// The [constructors] list contains reflected functions representing the class constructors.
/// The [declarations] list contains reflected declarations (fields, methods, etc.) of the class.
///
/// This class overrides [hashCode] and [operator ==] to include the additional properties
/// in equality comparisons and hash code calculations.
abstract class ReflectedClass extends ReflectedType {
  final List<ReflectedInstance> annotations;
  final List<ReflectedFunction> constructors;
  final List<ReflectedDeclaration> declarations;

  const ReflectedClass(
      String name,
      List<ReflectedTypeParameter> typeParameters,
      this.annotations,
      this.constructors,
      this.declarations,
      Type reflectedType)
      : super(name, typeParameters, reflectedType);

  @override
  int get hashCode =>
      hash4(super.hashCode, annotations, constructors, declarations);

  @override
  bool operator ==(other) =>
      other is ReflectedClass &&
      super == other &&
      const ListEquality<ReflectedInstance>()
          .equals(other.annotations, annotations) &&
      const ListEquality<ReflectedFunction>()
          .equals(other.constructors, constructors) &&
      const ListEquality<ReflectedDeclaration>()
          .equals(other.declarations, declarations);
}

/// Represents a reflected declaration in the Dart language.
///
/// This class encapsulates information about a declaration within a class or object,
/// such as a method, field, or property.
///
/// The [name] property holds the name of the declaration.
/// The [isStatic] property indicates whether the declaration is static.
/// The [function] property, if non-null, represents the reflected function associated
/// with this declaration (applicable for methods and some properties).
///
/// This class provides methods for comparing declarations and calculating hash codes.
/// It overrides [hashCode] and [operator ==] for proper equality comparisons.
class ReflectedDeclaration {
  final String name;
  final bool isStatic;
  final ReflectedFunction? function;

  const ReflectedDeclaration(this.name, this.isStatic, this.function);

  @override
  int get hashCode => hash3(name, isStatic, function);

  @override
  bool operator ==(other) =>
      other is ReflectedDeclaration &&
      other.name == name &&
      other.isStatic == isStatic &&
      other.function == function;
}

/// Represents a reflected function in the Dart language.
///
/// This abstract class encapsulates information about a function, including its name,
/// type parameters, annotations, return type, parameters, and whether it's a getter or setter.
///
/// The [name] property holds the name of the function.
/// The [typeParameters] list contains the type parameters if the function is generic.
/// The [annotations] list contains reflected instances of annotations applied to the function.
/// The [returnType] property represents the function's return type (if applicable).
/// The [parameters] list contains the function's parameters.
/// The [isGetter] and [isSetter] properties indicate if the function is a getter or setter.
///
/// This class provides methods for comparing functions and calculating hash codes.
/// It also includes an [invoke] method for dynamically calling the function.
///
/// This class overrides [hashCode] and [operator ==] for proper equality comparisons.
abstract class ReflectedFunction {
  final String name;
  final List<ReflectedTypeParameter> typeParameters;
  final List<ReflectedInstance> annotations;
  final ReflectedType? returnType;
  final List<ReflectedParameter> parameters;
  final bool isGetter, isSetter;

  const ReflectedFunction(this.name, this.typeParameters, this.annotations,
      this.parameters, this.isGetter, this.isSetter,
      {this.returnType});

  @override
  int get hashCode => hashObjects([
        name,
        typeParameters,
        annotations,
        returnType,
        parameters,
        isGetter,
        isSetter
      ]);

  @override
  bool operator ==(other) =>
      other is ReflectedFunction &&
      other.name == name &&
      const ListEquality<ReflectedTypeParameter>()
          .equals(other.typeParameters, typeParameters) &&
      const ListEquality<ReflectedInstance>()
          .equals(other.annotations, annotations) &&
      other.returnType == returnType &&
      const ListEquality<ReflectedParameter>()
          .equals(other.parameters, other.parameters) &&
      other.isGetter == isGetter &&
      other.isSetter == isSetter;

  ReflectedInstance invoke(Invocation invocation);
}

/// Represents a reflected parameter in the Dart language.
///
/// This class encapsulates information about a function or method parameter,
/// including its name, annotations, type, and properties such as whether it's
/// required or named.
///
/// Properties:
/// - [name]: The name of the parameter.
/// - [annotations]: A list of reflected instances of annotations applied to the parameter.
/// - [type]: The reflected type of the parameter.
/// - [isRequired]: Indicates whether the parameter is required.
/// - [isNamed]: Indicates whether the parameter is a named parameter.
///
/// This class provides methods for comparing parameters and calculating hash codes.
/// It overrides [hashCode] and [operator ==] for proper equality comparisons.
class ReflectedParameter {
  final String name;
  final List<ReflectedInstance> annotations;
  final ReflectedType type;
  final bool isRequired;
  final bool isNamed;

  const ReflectedParameter(
      this.name, this.annotations, this.type, this.isRequired, this.isNamed);

  @override
  int get hashCode =>
      hashObjects([name, annotations, type, isRequired, isNamed]);

  @override
  bool operator ==(other) =>
      other is ReflectedParameter &&
      other.name == name &&
      const ListEquality<ReflectedInstance>()
          .equals(other.annotations, annotations) &&
      other.type == type &&
      other.isRequired == isRequired &&
      other.isNamed == isNamed;
}

class ReflectedTypeParameter {
  final String name;

  const ReflectedTypeParameter(this.name);

  @override
  int get hashCode => hashObjects([name]);

  @override
  bool operator ==(other) =>
      other is ReflectedTypeParameter && other.name == name;
}
