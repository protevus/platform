import 'package:meta/meta.dart';

/// Function type for custom dumpers
typedef DumpFunction = void Function(Object? value);

/// A mixin that provides dump functionality.
///
/// Similar to Laravel's Dumpable trait, this allows classes to dump their state
/// for debugging purposes.
mixin Dumpable {
  /// The global dump function to use
  static DumpFunction _dumpFunction = _defaultDump;

  /// Sets the global dump function.
  ///
  /// Example:
  /// ```dart
  /// Dumpable.setDumpFunction((value) {
  ///   print('Custom dump: $value');
  /// });
  /// ```
  static void setDumpFunction(DumpFunction dumper) {
    _dumpFunction = dumper;
  }

  /// Resets the dump function to the default.
  ///
  /// Example:
  /// ```dart
  /// Dumpable.resetDumpFunction();
  /// ```
  static void resetDumpFunction() {
    _dumpFunction = _defaultDump;
  }

  /// Default dump implementation that uses print.
  static void _defaultDump(Object? value) {
    print('Dump: $value');
  }

  /// Dump the given arguments and terminate execution.
  ///
  /// Example:
  /// ```dart
  /// class MyClass with Dumpable {
  ///   void someMethod() {
  ///     dd('Debug value'); // Dumps and exits
  ///   }
  /// }
  /// ```
  @alwaysThrows
  Never dd([List<Object?> args = const []]) {
    dump(args);
    throw _DumpAndDieException();
  }

  /// Dump the given arguments.
  ///
  /// Example:
  /// ```dart
  /// class MyClass with Dumpable {
  ///   void someMethod() {
  ///     dump('Debug value').someOtherMethod(); // Dumps and continues
  ///   }
  /// }
  /// ```
  @useResult
  T dump<T extends Object>(List<Object?> args) {
    _dumpFunction(this);
    for (final arg in args) {
      _dumpFunction(arg);
    }
    return this as T;
  }
}

/// Exception thrown by [Dumpable.dd] to terminate execution.
class _DumpAndDieException implements Exception {
  @override
  String toString() => 'Execution terminated by dd()';
}
