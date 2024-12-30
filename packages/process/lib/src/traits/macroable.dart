import 'dart:async';

/// A mixin that provides macro functionality to classes.
mixin Macroable {
  /// The registered string macros.
  static final Map<String, Function> _macros = {};

  /// Register a custom macro.
  static void macro(String name, Function macro) {
    _macros[name] = macro;
  }

  /// Handle dynamic method calls into the class.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      final name = invocation.memberName.toString().split('"')[1];
      if (_macros.containsKey(name)) {
        final result = Function.apply(
          _macros[name]!,
          invocation.positionalArguments,
          invocation.namedArguments,
        );

        if (result is Future) {
          return result.then((value) => value ?? this);
        }

        return result ?? this;
      }
    }

    return super.noSuchMethod(invocation);
  }
}
