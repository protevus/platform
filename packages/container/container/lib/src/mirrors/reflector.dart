/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:mirrors' as dart;
import 'package:platform_container/container.dart';
import 'package:quiver/core.dart';

/// A [Reflector] implementation that forwards to `dart:mirrors`.
///
/// This class provides reflection capabilities by leveraging the `dart:mirrors` library.
/// It allows for runtime introspection of classes, functions, types, and instances.
///
/// Key features:
/// - Reflects classes, functions, types, and instances
/// - Provides access to class and function metadata
/// - Supports reflection of generic types and futures
/// - Allows invocation of reflected functions
///
/// Note: This reflector is primarily useful on the server-side where reflection is fully supported.
/// It may not be suitable for client-side Dart applications due to limitations in reflection support.
///
/// Usage:
/// ```dart
/// final reflector = MirrorsReflector();
/// final classReflection = reflector.reflectClass(MyClass);
/// final functionReflection = reflector.reflectFunction(myFunction);
/// final typeReflection = reflector.reflectType(int);
/// final instanceReflection = reflector.reflectInstance(myObject);
/// ```
///
/// Be aware of the performance implications when using reflection extensively,
/// as it can impact runtime performance and increase code size.
class MirrorsReflector extends Reflector {
  /// Creates a new instance of [MirrorsReflector].
  ///
  /// This constructor initializes the [MirrorsReflector] instance.
  const MirrorsReflector();

  /// Retrieves the name of a symbol as a string.
  ///
  /// This method overrides the base implementation to use the `dart:mirrors` library
  /// for converting a [Symbol] to its corresponding string representation.
  ///
  /// Parameters:
  ///   - [symbol]: The [Symbol] whose name is to be retrieved.
  ///
  /// Returns:
  ///   A [String] representing the name of the given symbol.
  ///
  /// Example:
  ///   ```dart
  ///   final name = getName(#someSymbol);
  ///   print(name); // Outputs: "someSymbol"
  ///   ```
  @override
  String getName(Symbol symbol) => dart.MirrorSystem.getName(symbol);

  /// Reflects a class and returns a [ReflectedClass] instance.
  ///
  /// This method takes a [Type] parameter [clazz] and uses dart:mirrors to create
  /// a reflection of the class. It returns a [_ReflectedClassMirror] which
  /// implements [ReflectedClass].
  ///
  /// Parameters:
  ///   - [clazz]: The [Type] of the class to reflect.
  ///
  /// Returns:
  ///   A [ReflectedClass] instance representing the reflected class.
  ///
  /// Throws:
  ///   - [ArgumentError] if the provided [clazz] is not a class.
  ///
  /// Example:
  ///   ```dart
  ///   final reflector = MirrorsReflector();
  ///   final classReflection = reflector.reflectClass(MyClass);
  ///   ```
  @override
  ReflectedClass reflectClass(Type clazz) {
    var mirror = dart.reflectType(clazz);

    if (mirror is dart.ClassMirror) {
      return _ReflectedClassMirror(mirror);
    } else {
      throw ArgumentError('$clazz is not a class.');
    }
  }

  /// Reflects a function and returns a [ReflectedFunction] instance.
  ///
  /// This method takes a [Function] parameter [function] and uses dart:mirrors to create
  /// a reflection of the function. It returns a [_ReflectedMethodMirror] which
  /// implements [ReflectedFunction].
  ///
  /// Parameters:
  ///   - [function]: The [Function] to reflect.
  ///
  /// Returns:
  ///   A [ReflectedFunction] instance representing the reflected function.
  ///
  /// Example:
  ///   ```dart
  ///   final reflector = MirrorsReflector();
  ///   final functionReflection = reflector.reflectFunction(myFunction);
  ///   ```
  @override
  ReflectedFunction reflectFunction(Function function) {
    var closure = dart.reflect(function) as dart.ClosureMirror;
    return _ReflectedMethodMirror(closure.function, closure);
  }

  /// Reflects a given type and returns a [ReflectedType] instance.
  ///
  /// This method takes a [Type] parameter and uses dart:mirrors to create
  /// a reflection of the type. It returns either a [_ReflectedClassMirror]
  /// or a [_ReflectedTypeMirror] depending on whether the reflected type
  /// is a class or not.
  ///
  /// Parameters:
  ///   - [type]: The [Type] to reflect.
  ///
  /// Returns:
  ///   A [ReflectedType] instance representing the reflected type.
  ///
  /// If the reflected type doesn't have a reflected type (i.e., [hasReflectedType] is false),
  /// it returns a reflection of the `dynamic` type instead.
  ///
  /// Example:
  ///   ```dart
  ///   final reflector = MirrorsReflector();
  ///   final typeReflection = reflector.reflectType(int);
  ///   ```
  @override
  ReflectedType reflectType(Type type) {
    var mirror = dart.reflectType(type);

    if (!mirror.hasReflectedType) {
      return reflectType(dynamic);
    } else {
      if (mirror is dart.ClassMirror) {
        return _ReflectedClassMirror(mirror);
      } else {
        return _ReflectedTypeMirror(mirror);
      }
    }
  }

  /// Reflects a Future of a given type and returns a [ReflectedType] instance.
  ///
  /// This method takes a [Type] parameter and creates a reflection of a Future
  /// that wraps that type. It first reflects the inner type, then constructs
  /// a Future type with that inner type as its type argument.
  ///
  /// Parameters:
  ///   - [type]: The [Type] to be wrapped in a Future.
  ///
  /// Returns:
  ///   A [ReflectedType] instance representing the reflected Future<Type>.
  ///
  /// Throws:
  ///   - [ArgumentError] if the provided [type] is not a class or type.
  ///
  /// Example:
  ///   ```dart
  ///   final reflector = MirrorsReflector();
  ///   final futureIntReflection = reflector.reflectFutureOf(int);
  ///   // This will reflect Future<int>
  ///   ```
  @override
  ReflectedType reflectFutureOf(Type type) {
    var inner = reflectType(type);
    dart.TypeMirror localMirror;
    if (inner is _ReflectedClassMirror) {
      localMirror = inner.mirror;
    } else if (inner is _ReflectedTypeMirror) {
      localMirror = inner.mirror;
    } else {
      throw ArgumentError('$type is not a class or type.');
    }

    var future = dart.reflectType(Future, [localMirror.reflectedType]);
    return _ReflectedClassMirror(future as dart.ClassMirror);
  }

  /// Reflects an instance of an object and returns a [ReflectedInstance].
  ///
  /// This method takes an [Object] parameter and uses dart:mirrors to create
  /// a reflection of the object instance. It returns a [_ReflectedInstanceMirror]
  /// which implements [ReflectedInstance].
  ///
  /// Parameters:
  ///   - [object]: The object instance to reflect.
  ///
  /// Returns:
  ///   A [ReflectedInstance] representing the reflected object instance.
  ///
  /// Example:
  ///   ```dart
  ///   final reflector = MirrorsReflector();
  ///   final instanceReflection = reflector.reflectInstance(myObject);
  ///   ```
  @override
  ReflectedInstance reflectInstance(Object object) {
    return _ReflectedInstanceMirror(dart.reflect(object));
  }
}

/// Represents a reflected type parameter using dart:mirrors.
///
/// This class extends [ReflectedTypeParameter] and wraps a [dart.TypeVariableMirror]
/// to provide reflection capabilities for type parameters in Dart.
///
/// The class extracts the name of the type parameter from the mirror and passes
/// it to the superclass constructor.
///
/// This is typically used internally by the reflection system to represent
/// type parameters of generic classes or methods.
class _ReflectedTypeParameter extends ReflectedTypeParameter {
  /// The [dart.TypeVariableMirror] instance representing the reflected type parameter.
  ///
  /// This mirror provides access to the details of the type parameter, such as its name,
  /// bounds, and other metadata. It is used internally by the [_ReflectedTypeParameter]
  /// class to implement reflection capabilities for type parameters.
  final dart.TypeVariableMirror mirror;

  /// Constructs a [_ReflectedTypeParameter] instance.
  ///
  /// This constructor takes a [dart.TypeVariableMirror] and initializes the
  /// [_ReflectedTypeParameter] with the name of the type parameter extracted
  /// from the mirror.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.TypeVariableMirror] representing the type parameter.
  ///
  /// The constructor uses [dart.MirrorSystem.getName] to extract the name of the
  /// type parameter from the mirror's [simpleName] and passes it to the superclass
  /// constructor.
  _ReflectedTypeParameter(this.mirror)
      : super(dart.MirrorSystem.getName(mirror.simpleName));
}

/// Represents a reflected type using dart:mirrors.
///
/// This class extends [ReflectedType] and wraps a [dart.TypeMirror]
/// to provide reflection capabilities for types in Dart.
///
/// The class extracts the name and type variables from the mirror and passes
/// them to the superclass constructor. It also implements type comparison
/// through the [isAssignableTo] method.
///
/// Note that this class represents types that are not classes, and therefore
/// cannot be instantiated. Attempting to call [newInstance] will throw a
/// [ReflectionException].
///
/// This is typically used internally by the reflection system to represent
/// non-class types like interfaces, mixins, or type aliases.
class _ReflectedTypeMirror extends ReflectedType {
  /// The [dart.TypeMirror] instance representing the reflected type.
  ///
  /// This mirror provides access to the details of the type, such as its name,
  /// type variables, and other metadata. It is used internally by the
  /// [_ReflectedTypeMirror] class to implement reflection capabilities for types.
  final dart.TypeMirror mirror;

  /// Constructs a [_ReflectedTypeMirror] instance.
  ///
  /// This constructor takes a [dart.TypeMirror] and initializes the
  /// [_ReflectedTypeMirror] with the following:
  /// - The name of the type extracted from the mirror's [simpleName].
  /// - A list of [_ReflectedTypeParameter] objects created from the mirror's type variables.
  /// - The reflected type of the mirror.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.TypeMirror] representing the type to be reflected.
  ///
  /// The constructor uses [dart.MirrorSystem.getName] to extract the name of the
  /// type from the mirror's [simpleName]. It also maps the mirror's type variables
  /// to [_ReflectedTypeParameter] objects and passes them along with the reflected
  /// type to the superclass constructor.
  _ReflectedTypeMirror(this.mirror)
      : super(
          dart.MirrorSystem.getName(mirror.simpleName),
          mirror.typeVariables.map((m) => _ReflectedTypeParameter(m)).toList(),
          mirror.reflectedType,
        );

  /// Checks if this reflected class is assignable to another reflected type.
  ///
  /// This method determines whether an instance of this class can be assigned
  /// to a variable of the type represented by [other].
  ///
  /// Parameters:
  ///   - [other]: The [ReflectedType] to check against.
  ///
  /// Returns:
  ///   - `true` if this class is assignable to [other].
  ///   - `false` otherwise, including when [other] is not a [_ReflectedClassMirror]
  ///     or [_ReflectedTypeMirror].
  ///
  /// The method uses dart:mirrors' [isAssignableTo] to perform the actual check
  /// when [other] is either a [_ReflectedClassMirror] or [_ReflectedTypeMirror].
  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other is _ReflectedClassMirror) {
      return mirror.isAssignableTo(other.mirror);
    } else if (other is _ReflectedTypeMirror) {
      return mirror.isAssignableTo(other.mirror);
    } else {
      return false;
    }
  }

  /// Throws a [ReflectionException] when attempting to create a new instance.
  ///
  /// This method is intended to be overridden by classes that represent
  /// instantiable types. For non-instantiable types (like interfaces or
  /// abstract classes), this method throws an exception.
  ///
  /// Parameters:
  ///   - [constructorName]: The name of the constructor to invoke.
  ///   - [positionalArguments]: A list of positional arguments for the constructor.
  ///   - [namedArguments]: An optional map of named arguments for the constructor.
  ///   - [typeArguments]: An optional list of type arguments for generic classes.
  ///
  /// Throws:
  ///   [ReflectionException]: Always thrown with a message indicating that
  ///   this type cannot be instantiated.
  ///
  /// Example:
  ///   ```dart
  ///   // This will always throw a ReflectionException
  ///   reflectedType.newInstance('defaultConstructor', []);
  ///   ```
  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic>? namedArguments, List<Type>? typeArguments]) {
    throw ReflectionException(
        '$name is not a class, and therefore cannot be instantiated.');
  }
}

/// Represents a reflected class using dart:mirrors.
///
/// This class extends [ReflectedClass] and wraps a [dart.ClassMirror]
/// to provide reflection capabilities for Dart classes.
///
/// Key features:
/// - Reflects class name, type parameters, constructors, and declarations
/// - Provides access to class metadata (annotations)
/// - Supports type comparison through [isAssignableTo]
/// - Allows creation of new instances of the reflected class
///
/// This class is typically used internally by the reflection system to
/// represent classes and their members.
class _ReflectedClassMirror extends ReflectedClass {
  /// The [dart.ClassMirror] representing the reflected class.
  ///
  /// This mirror is used to extract information about the class, such as
  /// its name, type parameters, constructors, and declarations.
  ///
  /// See also:
  /// - [dart.ClassMirror] for more details about the mirror system.
  final dart.ClassMirror mirror;

  /// Constructs a [_ReflectedClassMirror] instance.
  ///
  /// This constructor takes a [dart.ClassMirror] and initializes the
  /// [_ReflectedClassMirror] with the following:
  /// - The name of the class extracted from the mirror's [simpleName].
  /// - A list of [_ReflectedTypeParameter] objects created from the mirror's type variables.
  /// - Empty lists for constructors and annotations (these are populated elsewhere).
  /// - A list of declarations obtained from the [_declarationsOf] method.
  /// - The reflected type of the mirror.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.ClassMirror] representing the class to be reflected.
  ///
  /// The constructor uses [dart.MirrorSystem.getName] to extract the name of the
  /// class from the mirror's [simpleName]. It also maps the mirror's type variables
  /// to [_ReflectedTypeParameter] objects and uses [_declarationsOf] to get the
  /// class declarations. These are then passed to the superclass constructor.
  _ReflectedClassMirror(this.mirror)
      : super(
          dart.MirrorSystem.getName(mirror.simpleName),
          mirror.typeVariables.map((m) => _ReflectedTypeParameter(m)).toList(),
          [],
          [],
          _declarationsOf(mirror),
          mirror.reflectedType,
        );

  /// Retrieves a list of reflected constructors from a given [dart.ClassMirror].
  ///
  /// This static method iterates through the declarations of the provided [mirror],
  /// identifies the constructor methods, and creates [ReflectedFunction] instances
  /// for each constructor found.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.ClassMirror] representing the class to examine.
  ///
  /// Returns:
  ///   A [List] of [ReflectedFunction] objects, each representing a constructor
  ///   of the class.
  ///
  /// The method specifically looks for [dart.MethodMirror] instances that are
  /// marked as constructors (i.e., [isConstructor] is true). Each identified
  /// constructor is wrapped in a [_ReflectedMethodMirror] and added to the
  /// returned list.
  static List<ReflectedFunction> _constructorsOf(dart.ClassMirror mirror) {
    var out = <ReflectedFunction>[];

    for (var key in mirror.declarations.keys) {
      var value = mirror.declarations[key];

      if (value is dart.MethodMirror && value.isConstructor) {
        out.add(_ReflectedMethodMirror(value));
      }
    }

    return out;
  }

  /// Retrieves a list of reflected declarations from a given [dart.ClassMirror].
  ///
  /// This static method iterates through the declarations of the provided [mirror],
  /// identifies non-constructor methods, and creates [ReflectedDeclaration] instances
  /// for each method found.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.ClassMirror] representing the class to examine.
  ///
  /// Returns:
  ///   A [List] of [ReflectedDeclaration] objects, each representing a non-constructor
  ///   method of the class.
  ///
  /// The method specifically looks for [dart.MethodMirror] instances that are
  /// not constructors (i.e., [isConstructor] is false). Each identified
  /// method is wrapped in a [_ReflectedDeclarationMirror] and added to the
  /// returned list.
  static List<ReflectedDeclaration> _declarationsOf(dart.ClassMirror mirror) {
    var out = <ReflectedDeclaration>[];

    for (var key in mirror.declarations.keys) {
      var value = mirror.declarations[key];

      if (value is dart.MethodMirror && !value.isConstructor) {
        out.add(
            _ReflectedDeclarationMirror(dart.MirrorSystem.getName(key), value));
      }
    }

    return out;
  }

  /// Retrieves the annotations (metadata) associated with this reflected class.
  ///
  /// This getter method overrides the base implementation to provide access to
  /// the class-level annotations using dart:mirrors. It maps each metadata mirror
  /// to a [_ReflectedInstanceMirror] and returns them as a list.
  ///
  /// Returns:
  ///   A [List] of [ReflectedInstance] objects, each representing an annotation
  ///   applied to this class.
  ///
  /// Example:
  ///   ```dart
  ///   @MyAnnotation()
  ///   class MyClass {}
  ///
  ///   // Assuming we have a reflection of MyClass
  ///   final classReflection = reflector.reflectClass(MyClass);
  ///   final annotations = classReflection.annotations;
  ///   // annotations will contain a ReflectedInstance of MyAnnotation
  ///   ```
  ///
  /// Note: This method relies on the [dart.ClassMirror]'s metadata property
  /// and creates a new [_ReflectedInstanceMirror] for each annotation.
  @override
  List<ReflectedInstance> get annotations =>
      mirror.metadata.map((m) => _ReflectedInstanceMirror(m)).toList();

  /// Retrieves a list of reflected constructors for this class.
  ///
  /// This getter method overrides the base implementation to provide access to
  /// the constructors of the reflected class using dart:mirrors. It uses the
  /// static [_constructorsOf] method to extract and wrap each constructor
  /// in a [ReflectedFunction] object.
  ///
  /// Returns:
  ///   A [List] of [ReflectedFunction] objects, each representing a constructor
  ///   of this class.
  ///
  /// Example:
  ///   ```dart
  ///   final classReflection = reflector.reflectClass(MyClass);
  ///   final constructors = classReflection.constructors;
  ///   // constructors will contain ReflectedFunction objects for each
  ///   // constructor in MyClass
  ///   ```
  ///
  /// Note: This method relies on the [dart.ClassMirror]'s declarations and
  /// the [_constructorsOf] method to identify and create reflections of
  /// the class constructors.
  @override
  List<ReflectedFunction> get constructors => _constructorsOf(mirror);

  /// Checks if this reflected type is assignable to another reflected type.
  ///
  /// This method determines whether an instance of this type can be assigned
  /// to a variable of the type represented by [other].
  ///
  /// Parameters:
  ///   - [other]: The [ReflectedType] to check against.
  ///
  /// Returns:
  ///   - `true` if this type is assignable to [other].
  ///   - `false` otherwise, including when [other] is not a [_ReflectedClassMirror]
  ///     or [_ReflectedTypeMirror].
  ///
  /// The method uses dart:mirrors' [isAssignableTo] to perform the actual check
  /// when [other] is either a [_ReflectedClassMirror] or [_ReflectedTypeMirror].
  @override
  bool isAssignableTo(ReflectedType? other) {
    if (other is _ReflectedClassMirror) {
      return mirror.isAssignableTo(other.mirror);
    } else if (other is _ReflectedTypeMirror) {
      return mirror.isAssignableTo(other.mirror);
    } else {
      return false;
    }
  }

  /// Creates a new instance of the reflected class.
  ///
  /// This method instantiates a new object of the class represented by this
  /// [_ReflectedClassMirror] using the specified constructor and arguments.
  ///
  /// Parameters:
  ///   - [constructorName]: The name of the constructor to invoke. Use an empty
  ///     string for the default constructor.
  ///   - [positionalArguments]: A list of positional arguments to pass to the constructor.
  ///   - [namedArguments]: An optional map of named arguments to pass to the constructor.
  ///   - [typeArguments]: An optional list of type arguments for generic classes.
  ///
  /// Returns:
  ///   A [ReflectedInstance] representing the newly created instance.
  ///
  /// Throws:
  ///   May throw exceptions if the constructor invocation fails, e.g., due to
  ///   invalid arguments or if the class cannot be instantiated.
  ///
  /// Note:
  ///   This implementation currently does not use the [namedArguments] or
  ///   [typeArguments] parameters. They are included for API compatibility.
  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic>? namedArguments, List<Type>? typeArguments]) {
    return _ReflectedInstanceMirror(
        mirror.newInstance(Symbol(constructorName), positionalArguments));
  }

  /// Checks if this [_ReflectedClassMirror] is equal to another object.
  ///
  /// This method overrides the default equality operator to provide a custom
  /// equality check for [_ReflectedClassMirror] instances.
  ///
  /// Parameters:
  ///   - [other]: The object to compare with this [_ReflectedClassMirror].
  ///
  /// Returns:
  ///   - `true` if [other] is also a [_ReflectedClassMirror] and has the same
  ///     [mirror] as this instance.
  ///   - `false` otherwise.
  ///
  /// This implementation ensures that two [_ReflectedClassMirror] instances
  /// are considered equal if and only if they reflect the same class (i.e.,
  /// their underlying [dart.ClassMirror]s are the same).
  @override
  bool operator ==(other) {
    return other is _ReflectedClassMirror && other.mirror == mirror;
  }

  /// Generates a hash code for this [_ReflectedClassMirror].
  ///
  /// This method overrides the default [hashCode] implementation to provide
  /// a consistent hash code for [_ReflectedClassMirror] instances.
  ///
  /// The hash code is generated using the [hash2] function from the Quiver
  /// library, combining the [mirror] object and an empty string. The empty
  /// string is used as a second parameter to maintain compatibility with
  /// the [hash2] function, which requires two arguments.
  ///
  /// Returns:
  ///   An [int] representing the hash code of this [_ReflectedClassMirror].
  ///
  /// Note:
  ///   This hash code implementation ensures that two [_ReflectedClassMirror]
  ///   instances with the same [mirror] will have the same hash code, which
  ///   is consistent with the equality check implemented in the [operator ==].
  @override
  int get hashCode => hash2(mirror, " ");
}

/// Represents a reflected declaration using dart:mirrors.
///
/// This class extends [ReflectedDeclaration] and wraps a [dart.MethodMirror]
/// to provide reflection capabilities for method declarations in Dart.
///
/// Key features:
/// - Reflects the name and static nature of the declaration
/// - Provides access to the underlying method as a [ReflectedFunction]
///
/// This class is typically used internally by the reflection system to
/// represent method declarations within a class.
class _ReflectedDeclarationMirror extends ReflectedDeclaration {
  /// The [dart.MethodMirror] instance representing the reflected method.
  ///
  /// This mirror provides access to the details of the method, such as its name,
  /// parameters, return type, and other metadata. It is used internally by the
  /// [_ReflectedDeclarationMirror] class to implement reflection capabilities
  /// for method declarations.
  final dart.MethodMirror mirror;

  /// Constructs a [_ReflectedDeclarationMirror] instance.
  ///
  /// This constructor initializes a new [_ReflectedDeclarationMirror] with the given [name]
  /// and [mirror]. It uses the [dart.MethodMirror]'s [isStatic] property to determine
  /// if the declaration is static, and passes `null` as the initial value for the function.
  ///
  /// Parameters:
  ///   - [name]: A [String] representing the name of the declaration.
  ///   - [mirror]: A [dart.MethodMirror] representing the reflected method.
  ///
  /// The constructor calls the superclass constructor with the provided [name],
  /// the [isStatic] property from the [mirror], and `null` for the function parameter.
  _ReflectedDeclarationMirror(String name, this.mirror)
      : super(name, mirror.isStatic, null);

  /// Determines if this declaration is static.
  ///
  /// This getter overrides the base implementation to provide information
  /// about whether the reflected declaration is static or not. It directly
  /// accesses the [isStatic] property of the underlying [dart.MethodMirror].
  ///
  /// Returns:
  ///   A [bool] value:
  ///   - `true` if the declaration is static.
  ///   - `false` if the declaration is not static (i.e., it's an instance method).
  ///
  /// This property is useful for determining the nature of the reflected
  /// declaration, particularly when working with class methods and properties.
  @override
  bool get isStatic => mirror.isStatic;

  /// Retrieves a [ReflectedFunction] representation of this declaration.
  ///
  /// This getter overrides the base implementation to provide a [ReflectedFunction]
  /// that represents the method associated with this declaration. It creates a new
  /// [_ReflectedMethodMirror] instance using the underlying [dart.MethodMirror].
  ///
  /// Returns:
  ///   A [ReflectedFunction] object that represents the method of this declaration.
  ///
  /// This property is useful for accessing detailed information about the method,
  /// such as its parameters, return type, and other attributes, in a way that's
  /// consistent with the reflection API.
  @override
  ReflectedFunction get function => _ReflectedMethodMirror(mirror);
}

/// Represents a reflected instance of an object using dart:mirrors.
///
/// This class extends [ReflectedInstance] and wraps a [dart.InstanceMirror]
/// to provide reflection capabilities for object instances in Dart.
///
/// Key features:
/// - Reflects the type and runtime type of the instance
/// - Provides access to the underlying object (reflectee)
/// - Allows retrieval of field values through reflection
///
/// This class is typically used internally by the reflection system to
/// represent instances of objects and provide reflective access to their fields.
class _ReflectedInstanceMirror extends ReflectedInstance {
  /// The [dart.InstanceMirror] representing the reflected instance.
  ///
  /// This mirror provides access to the details of the object instance, such as its type,
  /// fields, and methods. It is used internally by the [_ReflectedInstanceMirror] class
  /// to implement reflection capabilities for object instances.
  ///
  /// The mirror allows for dynamic inspection and manipulation of the object's state
  /// and behavior at runtime, enabling powerful reflection features.
  final dart.InstanceMirror mirror;

  /// Constructs a [_ReflectedInstanceMirror] instance.
  ///
  /// This constructor initializes a new [_ReflectedInstanceMirror] with the given [mirror].
  /// It uses the [dart.InstanceMirror]'s [type] property to create [_ReflectedClassMirror]
  /// instances for both the type and runtime type of the reflected instance.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.InstanceMirror] representing the reflected instance.
  ///
  /// The constructor calls the superclass constructor with:
  ///   - A [_ReflectedClassMirror] of the instance's type
  ///   - A [_ReflectedClassMirror] of the instance's runtime type
  ///   - The [reflectee] of the mirror, which is the actual object being reflected
  ///
  /// This setup allows the [_ReflectedInstanceMirror] to provide access to both
  /// the compile-time and runtime type information of the reflected instance,
  /// as well as the underlying object itself.
  _ReflectedInstanceMirror(this.mirror)
      : super(_ReflectedClassMirror(mirror.type),
            _ReflectedClassMirror(mirror.type), mirror.reflectee);

  /// Retrieves the value of a field from the reflected instance.
  ///
  /// This method allows access to field values of the object represented by this
  /// [_ReflectedInstanceMirror] through reflection.
  ///
  /// Parameters:
  ///   - [name]: A [String] representing the name of the field to retrieve.
  ///
  /// Returns:
  ///   A [ReflectedInstance] representing the value of the specified field.
  ///   This returned instance is wrapped in a [_ReflectedInstanceMirror].
  ///
  /// Throws:
  ///   May throw exceptions if the field does not exist or if access is not allowed.
  ///
  /// Example:
  ///   ```dart
  ///   var fieldValue = reflectedInstance.getField('myField');
  ///   ```
  ///
  /// Note:
  ///   This method uses the underlying [dart.InstanceMirror]'s [getField] method
  ///   to perform the actual field access.
  @override
  ReflectedInstance getField(String name) {
    return _ReflectedInstanceMirror(mirror.getField(Symbol(name)));
  }
}

/// Represents a reflected method using dart:mirrors.
///
/// This class extends [ReflectedFunction] and wraps a [dart.MethodMirror]
/// to provide reflection capabilities for methods in Dart.
///
/// Key features:
/// - Reflects method name, parameters, and return type
/// - Provides access to method metadata (annotations)
/// - Supports invocation of the reflected method (if a ClosureMirror is available)
///
/// The class uses both [dart.MethodMirror] and optionally [dart.ClosureMirror]
/// to represent and potentially invoke the reflected method.
///
/// Usage:
/// - Created internally by the reflection system to represent methods
/// - Can be used to inspect method details or invoke the method if a ClosureMirror is provided
///
/// Note:
/// - Invocation is only possible if a ClosureMirror is provided during construction
/// - Throws a StateError if invoke is called without a ClosureMirror
class _ReflectedMethodMirror extends ReflectedFunction {
  /// The [dart.MethodMirror] instance representing the reflected method.
  ///
  /// This mirror provides access to the details of the method, such as its name,
  /// parameters, return type, and other metadata. It is used internally by the
  /// [_ReflectedMethodMirror] class to implement reflection capabilities
  /// for methods.
  ///
  /// The [dart.MethodMirror] is a crucial component in the reflection process,
  /// allowing for introspection of method properties and behavior at runtime.
  final dart.MethodMirror mirror;

  /// An optional [dart.ClosureMirror] representing the closure of the reflected method.
  ///
  /// This field is used to store a [dart.ClosureMirror] when the reflected method
  /// is associated with a callable object (i.e., a closure). The presence of this
  /// mirror enables the [invoke] method to directly call the reflected method.
  ///
  /// If this field is null, it indicates that the reflected method cannot be
  /// directly invoked through this [_ReflectedMethodMirror] instance.
  ///
  /// Note:
  /// - This field is crucial for supporting method invocation via reflection.
  /// - It's typically set when reflecting on instance methods or standalone functions.
  /// - For class-level method declarations that aren't bound to an instance,
  ///   this field may be null.
  final dart.ClosureMirror? closureMirror;

  /// Constructs a [_ReflectedMethodMirror] instance.
  ///
  /// This constructor initializes a new [_ReflectedMethodMirror] with the given [mirror]
  /// and optional [closureMirror]. It extracts various properties from the [dart.MethodMirror]
  /// to populate the superclass constructor.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.MethodMirror] representing the reflected method.
  ///   - [closureMirror]: An optional [dart.ClosureMirror] for method invocation.
  ///
  /// The constructor initializes the following:
  ///   - Method name from the mirror's [simpleName]
  ///   - An empty list of reflected type parameters
  ///   - Metadata (annotations) as [_ReflectedInstanceMirror] objects
  ///   - Reflected parameters using [_reflectParameter]
  ///   - Getter and setter flags from the mirror
  ///   - Return type, using [dynamic] if the mirror doesn't have a reflected type
  ///
  /// This setup allows the [_ReflectedMethodMirror] to provide comprehensive
  /// reflection capabilities for the method, including its signature, metadata,
  /// and potential invocation (if a [closureMirror] is provided).
  _ReflectedMethodMirror(this.mirror, [this.closureMirror])
      : super(
            dart.MirrorSystem.getName(mirror.simpleName),
            <ReflectedTypeParameter>[],
            mirror.metadata
                .map((mirror) => _ReflectedInstanceMirror(mirror))
                .toList(),
            mirror.parameters.map(_reflectParameter).toList(),
            mirror.isGetter,
            mirror.isSetter,
            returnType: !mirror.returnType.hasReflectedType
                ? const MirrorsReflector().reflectType(dynamic)
                : const MirrorsReflector()
                    .reflectType(mirror.returnType.reflectedType));

  /// Reflects a parameter of a method using dart:mirrors.
  ///
  /// This static method creates a [ReflectedParameter] instance from a given [dart.ParameterMirror].
  /// It extracts various properties from the mirror to construct a comprehensive reflection of the parameter.
  ///
  /// Parameters:
  ///   - [mirror]: A [dart.ParameterMirror] representing the parameter to be reflected.
  ///
  /// Returns:
  ///   A [ReflectedParameter] instance containing the reflected information of the parameter.
  ///
  /// The method extracts the following information:
  ///   - Parameter name from the mirror's [simpleName]
  ///   - Metadata (annotations) as [_ReflectedInstanceMirror] objects
  ///   - Parameter type, reflected using [MirrorsReflector]
  ///   - Whether the parameter is required (not optional)
  ///   - Whether the parameter is named
  ///
  /// This method is typically used internally by the reflection system to create
  /// parameter reflections for method signatures.
  static ReflectedParameter _reflectParameter(dart.ParameterMirror mirror) {
    return ReflectedParameter(
        dart.MirrorSystem.getName(mirror.simpleName),
        mirror.metadata
            .map((mirror) => _ReflectedInstanceMirror(mirror))
            .toList(),
        const MirrorsReflector().reflectType(mirror.type.reflectedType),
        !mirror.isOptional,
        mirror.isNamed);
  }

  /// Invokes the reflected method with the given invocation details.
  ///
  /// This method allows for dynamic invocation of the reflected method using the
  /// provided [Invocation] object. It requires that a [closureMirror] was provided
  /// during the construction of this [_ReflectedMethodMirror].
  ///
  /// Parameters:
  ///   - [invocation]: An [Invocation] object containing the details of the method call,
  ///     including the method name, positional arguments, and named arguments.
  ///
  /// Returns:
  ///   A [ReflectedInstance] representing the result of the method invocation.
  ///
  /// Throws:
  ///   - [StateError] if this [_ReflectedMethodMirror] was created without a [closureMirror],
  ///     indicating that direct invocation is not possible.
  ///
  /// Example:
  ///   ```dart
  ///   var result = reflectedMethod.invoke(Invocation.method(#methodName, [arg1, arg2]));
  ///   ```
  ///
  /// Note:
  ///   This method relies on the presence of a [closureMirror] to perform the actual
  ///   invocation. If no [closureMirror] is available, it means the reflected method
  ///   cannot be directly invoked, and an error will be thrown.
  @override
  ReflectedInstance invoke(Invocation invocation) {
    if (closureMirror == null) {
      throw StateError(
          'This object was reflected without a ClosureMirror, and therefore cannot be directly invoked.');
    }

    return _ReflectedInstanceMirror(closureMirror!.invoke(invocation.memberName,
        invocation.positionalArguments, invocation.namedArguments));
  }
}
