import 'package:platform_mirrors/mirrors.dart';

/// Interface for objects that can provide methods to be mixed in
abstract class MacroProvider {
  /// Get all methods that should be mixed in
  Map<String, Function> getMethods();
}

/// A mixin that allows runtime method extension through macros.
///
/// This mixin provides functionality similar to Laravel's Macroable trait,
/// allowing classes to be extended with custom methods at runtime.
@reflectable
mixin Macroable {
  /// The registered macros.
  static final Map<Type, Map<String, Function>> _macros = {};

  /// Register a custom macro.
  ///
  /// Example:
  /// ```dart
  /// class MyClass with Macroable {
  ///   static void registerMacros() {
  ///     Macroable.macro<MyClass>('customMethod', (String arg) {
  ///       print('Custom method called with: $arg');
  ///     });
  ///   }
  /// }
  /// ```
  static void macro<T>(String name, Function macro) {
    _macros.putIfAbsent(T, () => {});
    _macros[T]![name] = macro;
  }

  /// Mix another object's methods into this class.
  ///
  /// [mixin] - The object whose methods should be mixed in
  /// [replace] - Whether to replace existing macros with the same name
  static void mixin<T>(Object mixin, {bool replace = true}) {
    if (mixin is! MacroProvider) {
      throw ArgumentError('Mixin source must implement MacroProvider');
    }

    final methods = mixin.getMethods();
    for (var entry in methods.entries) {
      if (replace || !hasMacro<T>(entry.key)) {
        macro<T>(entry.key, entry.value);
      }
    }
  }

  /// Check if a macro is registered.
  static bool hasMacro<T>(String name) {
    return _macros[T]?.containsKey(name) ?? false;
  }

  /// Remove all registered macros.
  static void flushMacros<T>() {
    _macros.remove(T);
  }

  /// Handle dynamic method calls.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Get method name from Symbol without using reflection
    final name = invocation.memberName
        .toString()
        .substring(8) // Remove "Symbol("
        .split('"')[0]; // Get name part before closing quote

    final macros = _macros[runtimeType];

    if (macros != null && macros.containsKey(name)) {
      final macro = macros[name]!;
      final positionalArgs = invocation.positionalArguments;
      final namedArgs = invocation.namedArguments;

      try {
        return Function.apply(
          macro,
          positionalArgs,
          namedArgs.isNotEmpty ? namedArgs : null,
        );
      } catch (e) {
        throw NoSuchMethodError.withInvocation(this, invocation);
      }
    }

    return super.noSuchMethod(invocation);
  }
}
