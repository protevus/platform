import 'dart:mirrors';

mixin Macroable {
  static final Map<Type, Map<Symbol, Function>> _macros = {};

  static void macro(Type type, String name, Function macro) {
    _macros.putIfAbsent(type, () => {});
    _macros[type]![Symbol(name)] = macro;
  }

  static bool hasMacro(Type type, String name) {
    return _macros[type]?.containsKey(Symbol(name)) ?? false;
  }

  static void mixin(Type type, Object mixin, {bool replace = true}) {
    final methods = reflect(mixin)
        .type
        .declarations
        .values
        .whereType<MethodMirror>()
        .where((m) => m.isRegularMethod && !m.isPrivate);

    for (final method in methods) {
      final name = MirrorSystem.getName(method.simpleName);
      if (replace || !hasMacro(type, name)) {
        macro(type, name, (List args,
            [Map<Symbol, dynamic> namedArgs = const {}]) {
          return reflect(mixin)
              .invoke(method.simpleName, args, namedArgs)
              .reflectee;
        });
      }
    }
  }

  static void flushMacros(Type type) {
    _macros.remove(type);
  }

  dynamic noSuchMethod(Invocation invocation) {
    final macro = _macros[runtimeType]?[invocation.memberName];

    if (macro != null) {
      try {
        return Function.apply(
            macro, [invocation.positionalArguments], invocation.namedArguments);
      } catch (e) {
        try {
          return Function.apply(
              macro, invocation.positionalArguments, invocation.namedArguments);
        } catch (e) {
          return (macro as dynamic)();
        }
      }
    }

    return super.noSuchMethod(invocation);
  }
}
