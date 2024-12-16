# Platform Macroable

A Dart implementation of Laravel's Macroable trait, allowing runtime method extension of classes.

## Features

- Add methods to classes at runtime through macros
- Mix in methods from other objects
- Support for both positional and named parameters
- Type-safe macro registration and usage
- Easy method existence checking
- Ability to clear registered macros

## Usage

```dart
import 'package:platform_macroable/platform_macroable.dart';

// 1. Add the Macroable mixin to your class
class StringFormatter with Macroable {
  String capitalize(String input) => 
      input.isEmpty ? '' : input[0].toUpperCase() + input.substring(1);
}

void main() {
  final formatter = StringFormatter();

  // 2. Register a macro with positional parameters
  Macroable.macro<StringFormatter>('repeat', (String text, int times) {
    return text * times;
  });

  // 3. Register a macro with named parameters
  Macroable.macro<StringFormatter>(
    'wrap',
    ({required String text, String start = '[', String end = ']'}) {
      return '$start$text$end';
    },
  );

  // 4. Use the macros (requires dynamic casting)
  print(formatter.capitalize('hello')); // Built-in method
  print((formatter as dynamic).repeat('ha ', 3)); // Prints: ha ha ha
  print((formatter as dynamic).wrap(text: 'hello')); // Prints: [hello]

  // 5. Mix in methods from another class
  class TextTransformations {
    String reverse(String text) => text.split('').reversed.join();
  }

  Macroable.mixin<StringFormatter>(TextTransformations());
  print((formatter as dynamic).reverse('hello')); // Prints: olleh

  // 6. Check if a macro exists
  print(Macroable.hasMacro<StringFormatter>('reverse')); // Prints: true

  // 7. Clear all macros
  Macroable.flushMacros<StringFormatter>();
}
```

## Features in Detail

### Basic Macro Registration

Register methods that can be called on instances of your class:

```dart
Macroable.macro<YourClass>('methodName', (String arg) {
  return arg.toUpperCase();
});
```

### Named Parameters

Support for methods with named parameters:

```dart
Macroable.macro<YourClass>(
  'format',
  ({required String text, String prefix = '>> '}) {
    return '$prefix$text';
  },
);
```

### Method Mixing

Add all public methods from another object:

```dart
class Helper {
  String process(String input) => input.trim();
  int calculate(int x, int y) => x + y;
}

Macroable.mixin<YourClass>(Helper());
```

### Utility Methods

Check for macro existence and clear macros:

```dart
// Check if a macro exists
bool exists = Macroable.hasMacro<YourClass>('methodName');

// Remove all macros
Macroable.flushMacros<YourClass>();
```

## Important Notes

1. Macro calls require dynamic casting since they're resolved at runtime:
   ```dart
   (instance as dynamic).macroMethod()
   ```

2. Macros are registered per-type, not per-instance:
   ```dart
   // All instances of YourClass will have access to this macro
   Macroable.macro<YourClass>('method', () => 'result');
   ```

3. Type safety is maintained at registration time through generics.

## Example

See the [example](example/platform_macroable_example.dart) for a complete demonstration of all features.
