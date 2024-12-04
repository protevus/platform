import 'dart:mirrors';

/// A mixin that allows runtime method extension through macros.
///
/// This mixin provides functionality similar to Laravel's Macroable trait,
/// allowing classes to be extended with custom methods at runtime.
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
    final instanceMirror = reflect(mixin);
    final classMirror = instanceMirror.type;

    for (var declarationKey in classMirror.declarations.keys) {
      final declaration = classMirror.declarations[declarationKey];

      if (declaration is MethodMirror &&
          declaration.isRegularMethod &&
          !declaration.isPrivate) {
        final methodName = MirrorSystem.getName(declaration.simpleName);

        if (replace || !hasMacro<T>(methodName)) {
          final method =
              instanceMirror.getField(declaration.simpleName).reflectee;
          macro<T>(methodName, method);
        }
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
    final name = MirrorSystem.getName(invocation.memberName);
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
