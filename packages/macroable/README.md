# Platform Macroable

A Dart implementation of Laravel's Macroable trait, allowing you to add methods to classes at runtime.

## Features

- Add custom methods to classes at runtime
- Mix in methods from other classes
- Check for the existence of macros
- Flush all macros for a given class

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  platform_macroable: ^1.0.0
```

Then run `dart pub get` or `flutter pub get` to install the package.

## Usage

Here's a simple example of how to use the `Macroable` mixin:

```dart
import 'package:platform_macroable/macroable.dart';

class MyClass with Macroable {
  String regularMethod() => 'This is a regular method';
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
  class MyMixin {
    String mixinMethod() => 'This is a mixin method';
  }

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
```

## Additional Information

For more detailed examples, please refer to the `example/macroable_example.dart` file in the package.

If you encounter any issues or have feature requests, please file them on the [issue tracker](https://github.com/yourusername/platform_macroable/issues).

Contributions are welcome! Please read our [contributing guidelines](https://github.com/yourusername/platform_macroable/blob/main/CONTRIBUTING.md) before submitting a pull request.
