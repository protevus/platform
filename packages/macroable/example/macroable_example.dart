import 'package:platform_macroable/macroable.dart';

class MyClass with Macroable {
  String regularMethod() => 'This is a regular method';
}

class MyMixin {
  String mixinMethod() => 'This is a mixin method';
}

void main() {
  // Register a macro
  Macroable.macro(MyClass, 'customMethod', () => 'This is a custom method');

  final instance = MyClass();

  // Call the regular method
  print(instance.regularMethod());

  // Call the macro method
  print((instance as dynamic).customMethod());

  // Check if a macro exists
  print(Macroable.hasMacro(MyClass, 'customMethod')); // true
  print(Macroable.hasMacro(MyClass, 'nonExistentMethod')); // false

  // Add methods from a mixin
  Macroable.mixin(MyClass, MyMixin());

  // Call the mixin method
  print((instance as dynamic).mixinMethod());

  // Flush all macros
  Macroable.flushMacros(MyClass);

  // This will now throw a NoSuchMethodError
  try {
    (instance as dynamic).customMethod();
  } catch (e) {
    print('Caught exception: $e');
  }
}
