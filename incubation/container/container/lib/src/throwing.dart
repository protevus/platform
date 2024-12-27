import 'package:platformed_container/src/container_const.dart';
import 'empty/empty.dart';
import 'reflector.dart';

/// A [Reflector] implementation that throws exceptions on all attempts
/// to perform reflection.
///
/// Use this in contexts where you know you won't need any reflective capabilities.
class ThrowingReflector extends Reflector {
  /// The error message to give the end user when an [UnsupportedError] is thrown.
  final String errorMessage;

  /*
  static const String defaultErrorMessage =
      'You attempted to perform a reflective action, but you are using `ThrowingReflector`, '
      'a class which disables reflection. Consider using the `MirrorsReflector` '
      'class if you need reflection.';
  */

  /// Creates a [ThrowingReflector] instance.
  ///
  /// [errorMessage] is the message to be used when throwing an [UnsupportedError].
  /// If not provided, it defaults to [ContainerConst.defaultErrorMessage].
  const ThrowingReflector(
      {this.errorMessage = ContainerConst.defaultErrorMessage});

  /// Retrieves the name associated with the given [symbol].
  ///
  /// This method delegates the task to an instance of [EmptyReflector].
  /// It returns the name as a [String] if found, or `null` if not found.
  ///
  /// [symbol] is the [Symbol] for which to retrieve the name.
  ///
  /// Returns a [String] representing the name of the symbol, or `null` if not found.
  @override
  String? getName(Symbol symbol) => const EmptyReflector().getName(symbol);

  /// Creates and returns an [UnsupportedError] with the specified [errorMessage].
  ///
  /// This method is used internally to generate consistent error messages
  /// when reflection operations are attempted on this [ThrowingReflector].
  ///
  /// Returns an [UnsupportedError] instance with the configured error message.
  UnsupportedError _error() => UnsupportedError(errorMessage);

  /// Reflects on a given class type and throws an [UnsupportedError].
  ///
  /// This method is part of the [ThrowingReflector] implementation and is designed
  /// to prevent reflective operations. When called, it throws an [UnsupportedError]
  /// with the configured error message.
  ///
  /// [clazz] is the [Type] of the class to reflect on.
  ///
  /// Throws an [UnsupportedError] when invoked, as reflection is not supported.
  @override
  ReflectedClass reflectClass(Type clazz) => throw _error();

  /// Reflects on a given object instance and throws an [UnsupportedError].
  ///
  /// This method is part of the [ThrowingReflector] implementation and is designed
  /// to prevent reflective operations on object instances. When called, it throws
  /// an [UnsupportedError] with the configured error message.
  ///
  /// [object] is the object instance to reflect on.
  ///
  /// Throws an [UnsupportedError] when invoked, as reflection is not supported.
  @override
  ReflectedInstance reflectInstance(Object object) => throw _error();

  /// Reflects on a given type and throws an [UnsupportedError].
  ///
  /// This method is part of the [ThrowingReflector] implementation and is designed
  /// to prevent reflective operations on types. When called, it throws an
  /// [UnsupportedError] with the configured error message.
  ///
  /// [type] is the [Type] to reflect on.
  ///
  /// Throws an [UnsupportedError] when invoked, as reflection is not supported.
  @override
  ReflectedType reflectType(Type type) => throw _error();

  /// Reflects on a given function and throws an [UnsupportedError].
  ///
  /// This method is part of the [ThrowingReflector] implementation and is designed
  /// to prevent reflective operations on functions. When called, it throws an
  /// [UnsupportedError] with the configured error message.
  ///
  /// [function] is the [Function] to reflect on.
  ///
  /// Throws an [UnsupportedError] when invoked, as reflection is not supported.
  @override
  ReflectedFunction reflectFunction(Function function) => throw _error();
}
