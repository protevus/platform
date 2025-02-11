/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:illuminate_container/container.dart';

/// A cache to store symbol names.
///
/// This map associates [Symbol] objects with their corresponding string representations.
/// It's used to avoid repeated parsing of symbol names, improving performance
/// when retrieving symbol names multiple times.
final Map<Symbol, String?> _symbolNames = <Symbol, String?>{};

/// A [Reflector] implementation that performs no actual reflection,
/// instead returning empty objects on every invocation.
///
/// Use this in contexts where you know you won't need any reflective capabilities.
///
/// This class provides a lightweight alternative to full reflection when reflection
/// functionality is not required. It returns empty or placeholder objects for all
/// reflection operations, which can be useful in scenarios where reflection is
/// expected but not actually used, or when you want to minimize the overhead of
/// reflection in certain parts of your application.
///
/// The [EmptyReflector] includes:
/// - A static [RegExp] for extracting symbol names without reflection.
/// - Methods to return empty implementations of [ReflectedClass], [ReflectedInstance],
///   [ReflectedType], and [ReflectedFunction].
/// - A [getName] method that uses a cache to store and retrieve symbol names.
///
/// This implementation can be particularly useful in testing scenarios or in
/// production environments where reflection is not needed but the interface
/// expecting reflection capabilities needs to be satisfied.
class EmptyReflector extends Reflector {
  /// A [RegExp] that can be used to extract the name of a symbol without reflection.
  ///
  /// This regular expression pattern matches the string representation of a Dart [Symbol],
  /// which typically looks like 'Symbol("symbolName")'. It captures the symbol name
  /// (the part between the quotes) in a capturing group.
  ///
  /// Usage:
  /// ```dart
  /// String symbolString = 'Symbol("exampleSymbol")';
  /// Match? match = symbolRegex.firstMatch(symbolString);
  /// String? symbolName = match?.group(1); // Returns "exampleSymbol"
  /// ```
  ///
  /// This is particularly useful in contexts where reflection is not available
  /// or desired, allowing for symbol name extraction through string manipulation.
  static final RegExp symbolRegex = RegExp(r'Symbol\("([^"]+)"\)');

  /// Creates an instance of [EmptyReflector].
  ///
  /// This constructor doesn't take any parameters and creates a lightweight
  /// reflector that provides empty implementations for all reflection operations.
  /// It's useful in scenarios where reflection capabilities are expected but not
  /// actually used, or when you want to minimize the overhead of reflection.
  const EmptyReflector();

  /// Retrieves the name of a given [Symbol].
  ///
  /// This method attempts to extract the name of the provided [symbol] using
  /// the [symbolRegex]. If the name hasn't been cached before, it will be
  /// computed and stored in the [_symbolNames] cache for future use.
  ///
  /// The method works as follows:
  /// 1. It checks if the symbol's name is already in the cache.
  /// 2. If not found, it uses [putIfAbsent] to compute the name:
  ///    a. It converts the symbol to a string.
  ///    b. It applies the [symbolRegex] to extract the name.
  ///    c. If a match is found, it returns the first captured group (the name).
  /// 3. The computed name (or null if not found) is stored in the cache and returned.
  ///
  /// @param symbol The [Symbol] whose name is to be retrieved.
  /// @return The name of the symbol as a [String], or null if the name couldn't be extracted.
  @override
  String? getName(Symbol symbol) {
    return _symbolNames.putIfAbsent(
        symbol, () => symbolRegex.firstMatch(symbol.toString())?.group(1));
  }

  /// Returns an empty [ReflectedClass] instance for any given [Type].
  ///
  /// This method is part of the [EmptyReflector] implementation and always
  /// returns a constant instance of [_EmptyReflectedClass], regardless of
  /// the input [clazz].
  ///
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides non-functional placeholders for reflection operations.
  ///
  /// @param clazz The [Type] to reflect, which is ignored in this implementation.
  /// @return A constant [_EmptyReflectedClass] instance.
  @override
  ReflectedClass reflectClass(Type clazz) {
    return const _EmptyReflectedClass();
  }

  /// Returns an empty [ReflectedInstance] for any given object.
  ///
  /// This method is part of the [EmptyReflector] implementation and always
  /// returns a constant instance of [_EmptyReflectedInstance], regardless of
  /// the input [object].
  ///
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides non-functional placeholders for reflection operations.
  ///
  /// @param object The object to reflect, which is ignored in this implementation.
  /// @return A constant [_EmptyReflectedInstance].
  @override
  ReflectedInstance reflectInstance(Object object) {
    return const _EmptyReflectedInstance();
  }

  /// Returns an empty [ReflectedType] for any given [Type].
  ///
  /// This method is part of the [EmptyReflector] implementation and always
  /// returns a constant instance of [_EmptyReflectedType], regardless of
  /// the input [type].
  ///
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides non-functional placeholders for reflection operations.
  ///
  /// @param type The [Type] to reflect, which is ignored in this implementation.
  /// @return A constant [_EmptyReflectedType] instance.
  @override
  ReflectedType reflectType(Type type) {
    return const _EmptyReflectedType();
  }

  /// Returns an empty [ReflectedFunction] for any given [Function].
  ///
  /// This method is part of the [EmptyReflector] implementation and always
  /// returns a constant instance of [_EmptyReflectedFunction], regardless of
  /// the input [function].
  ///
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides non-functional placeholders for reflection operations.
  ///
  /// @param function The [Function] to reflect, which is ignored in this implementation.
  /// @return A constant [_EmptyReflectedFunction] instance.
  @override
  ReflectedFunction reflectFunction(Function function) {
    return const _EmptyReflectedFunction();
  }
}

/// An empty implementation of [ReflectedClass] used by [EmptyReflector].
///
/// This class provides a non-functional placeholder for reflection operations
/// on classes. It is designed to be used in contexts where reflection capabilities
/// are expected but not actually needed or desired.
///
/// Key features:
/// - Extends [ReflectedClass] with minimal implementation.
/// - Constructor initializes with empty or default values for all properties.
/// - [newInstance] method throws an [UnsupportedError] if called.
/// - [isAssignableTo] method only returns true if compared with itself.
///
/// This implementation is consistent with the purpose of [EmptyReflector],
/// providing a lightweight alternative when full reflection capabilities are not required.
class _EmptyReflectedClass extends ReflectedClass {
  /// Constructs an empty [_EmptyReflectedClass] instance.
  ///
  /// This constructor initializes the instance with empty or default values for all properties.
  ///
  /// @param name The name of the class, set to '(empty)'.
  /// @param typeParameters The list of type parameters, set to an empty list.
  /// @param instances The list of instances, set to an empty list.
  /// @param functions The list of functions, set to an empty list.
  /// @param declarations The list of declarations, set to an empty list.
  /// @param type The underlying [Type] of the class, set to [Object].
  const _EmptyReflectedClass()
      : super(
            '(empty)',
            const <ReflectedTypeParameter>[],
            const <ReflectedInstance>[],
            const <ReflectedFunction>[],
            const <ReflectedDeclaration>[],
            Object);

  /// Creates a new instance of the reflected class.
  ///
  /// This method is part of the [_EmptyReflectedClass] implementation and always
  /// throws an [UnsupportedError] when called. This behavior is consistent with
  /// the purpose of [EmptyReflector], which provides non-functional placeholders
  /// for reflection operations.
  ///
  /// @param constructorName The name of the constructor to invoke.
  /// @param positionalArguments A list of positional arguments for the constructor.
  /// @param namedArguments An optional map of named arguments for the constructor.
  /// @param typeArguments An optional list of type arguments for generic classes.
  /// @throws UnsupportedError Always thrown when this method is called.
  /// @return This method never returns as it always throws an exception.
  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic>? namedArguments, List<Type>? typeArguments]) {
    throw UnsupportedError(
        'Classes reflected via an EmptyReflector cannot be instantiated.');
  }

  /// Checks if this empty reflected class is assignable to another reflected type.
  ///
  /// This method is part of the [_EmptyReflectedClass] implementation and always
  /// returns true only if the [other] type is the same instance as this one.
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides minimal functionality for reflection operations.
  ///
  /// @param other The [ReflectedType] to check against.
  /// @return true if [other] is the same instance as this, false otherwise.
  @override
  bool isAssignableTo(ReflectedType? other) {
    return other == this;
  }
}

/// An empty implementation of [ReflectedType] used by [EmptyReflector].
///
/// This class provides a non-functional placeholder for reflection operations
/// on types. It is designed to be used in contexts where reflection capabilities
/// are expected but not actually needed or desired.
///
/// Key features:
/// - Extends [ReflectedType] with minimal implementation.
/// - Constructor initializes with empty or default values for all properties.
/// - [newInstance] method throws an [UnsupportedError] if called.
/// - [isAssignableTo] method only returns true if compared with itself.
///
/// This implementation is consistent with the purpose of [EmptyReflector],
/// providing a lightweight alternative when full reflection capabilities are not required.
class _EmptyReflectedType extends ReflectedType {
  /// Constructs an empty [_EmptyReflectedType] instance.
  ///
  /// This constructor initializes the instance with empty or default values for all properties.
  ///
  /// @param name The name of the type, set to '(empty)'.
  /// @param typeParameters The list of type parameters, set to an empty list.
  /// @param type The underlying [Type], set to [Object].
  const _EmptyReflectedType()
      : super('(empty)', const <ReflectedTypeParameter>[], Object);

  /// Creates a new instance of the reflected type.
  ///
  /// This method is part of the [_EmptyReflectedType] implementation and always
  /// throws an [UnsupportedError] when called. This behavior is consistent with
  /// the purpose of [EmptyReflector], which provides non-functional placeholders
  /// for reflection operations.
  ///
  /// @param constructorName The name of the constructor to invoke.
  /// @param positionalArguments A list of positional arguments for the constructor.
  /// @param namedArguments An optional map of named arguments for the constructor.
  /// @param typeArguments An optional list of type arguments for generic types.
  /// @throws UnsupportedError Always thrown when this method is called.
  /// @return This method never returns as it always throws an exception.
  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    throw UnsupportedError(
        'Types reflected via an EmptyReflector cannot be instantiated.');
  }

  /// Checks if this empty reflected type is assignable to another reflected type.
  ///
  /// This method is part of the [_EmptyReflectedType] implementation and always
  /// returns true only if the [other] type is the same instance as this one.
  /// This behavior is consistent with the purpose of [EmptyReflector],
  /// which provides minimal functionality for reflection operations.
  ///
  /// @param other The [ReflectedType] to check against.
  /// @return true if [other] is the same instance as this, false otherwise.
  @override
  bool isAssignableTo(ReflectedType? other) {
    return other == this;
  }
}

/// An empty implementation of [ReflectedInstance] used by [EmptyReflector].
///
/// This class provides a non-functional placeholder for reflection operations
/// on instances. It is designed to be used in contexts where reflection capabilities
/// are expected but not actually needed or desired.
///
/// Key features:
/// - Extends [ReflectedInstance] with minimal implementation.
/// - Constructor initializes with empty or default values for all properties.
/// - [getField] method throws an [UnsupportedError] if called.
///
/// This implementation is consistent with the purpose of [EmptyReflector],
/// providing a lightweight alternative when full reflection capabilities are not required.
class _EmptyReflectedInstance extends ReflectedInstance {
  /// Constructs an empty [_EmptyReflectedInstance] instance.
  ///
  /// This constructor initializes the instance with empty or default values for all properties.
  ///
  /// @param type The reflected type of the instance, set to an empty [_EmptyReflectedType].
  /// @param reflectedClass The reflected class of the instance, set to an empty [_EmptyReflectedClass].
  /// @param value The underlying value of the instance, set to null.
  const _EmptyReflectedInstance()
      : super(const _EmptyReflectedType(), const _EmptyReflectedClass(), null);

  /// Retrieves the value of a field on this empty reflected instance.
  ///
  /// This method is part of the [_EmptyReflectedInstance] implementation and always
  /// throws an [UnsupportedError] when called. This behavior is consistent with
  /// the purpose of [EmptyReflector], which provides non-functional placeholders
  /// for reflection operations.
  ///
  /// @param name The name of the field to retrieve.
  /// @throws UnsupportedError Always thrown when this method is called.
  /// @return This method never returns as it always throws an exception.
  @override
  ReflectedInstance getField(String name) {
    throw UnsupportedError(
        'Instances reflected via an EmptyReflector cannot call getField().');
  }

  @override
  void setField(String name, value) {
    throw UnsupportedError(
        'Instances reflected via an EmptyReflector cannot call setField().');
  }
}

/// An empty implementation of [ReflectedFunction] used by [EmptyReflector].
///
/// This class provides a non-functional placeholder for reflection operations
/// on functions. It is designed to be used in contexts where reflection capabilities
/// are expected but not actually needed or desired.
///
/// Key features:
/// - Extends [ReflectedFunction] with minimal implementation.
/// - Constructor initializes with empty or default values for all properties.
/// - [invoke] method throws an [UnsupportedError] if called.
///
/// This implementation is consistent with the purpose of [EmptyReflector],
/// providing a lightweight alternative when full reflection capabilities are not required.
class _EmptyReflectedFunction extends ReflectedFunction {
  /// Constructs an empty [_EmptyReflectedFunction] instance.
  ///
  /// This constructor initializes the instance with empty or default values for all properties.
  ///
  /// @param name The name of the function, set to an empty string.
  /// @param typeParameters A list of type parameters for the function, set to an empty list.
  /// @param enclosingInstance A list of enclosing instances for the function, set to an empty list.
  /// @param parameters A list of parameters for the function, set to an empty list.
  /// @param isStatic Indicates whether the function is static, set to false.
  /// @param isConst Indicates whether the function is constant, set to false.
  /// @param returnType The return type of the function, set to an empty [_EmptyReflectedType].
  /// @param isOperator Indicates whether the function is an operator, set to false.
  /// @param isExtensionMember Indicates whether the function is an extension member, set to false.
  const _EmptyReflectedFunction()
      : super(
            '(empty)',
            const <ReflectedTypeParameter>[],
            const <ReflectedInstance>[],
            const <ReflectedParameter>[],
            false,
            false,
            returnType: const _EmptyReflectedType());

  /// Invokes this empty reflected function.
  ///
  /// This method is part of the [_EmptyReflectedFunction] implementation and always
  /// throws an [UnsupportedError] when called. This behavior is consistent with
  /// the purpose of [EmptyReflector], which provides non-functional placeholders
  /// for reflection operations.
  ///
  /// @param invocation The invocation to execute.
  /// @throws UnsupportedError Always thrown when this method is called.
  /// @return This method never returns as it always throws an exception.
  @override
  ReflectedInstance invoke(Invocation invocation) {
    throw UnsupportedError(
        'Instances reflected via an EmptyReflector cannot call invoke().');
  }
}
