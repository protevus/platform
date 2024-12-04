import 'package:platform_macroable/platform_macroable.dart';

// A simple string formatter class that we'll extend with macros
class StringFormatter with Macroable {
  String capitalize(String input) =>
      input.isEmpty ? '' : input[0].toUpperCase() + input.substring(1);
}

// A class with methods we want to mix in
class TextTransformations {
  String reverse(String text) => text.split('').reversed.join();
  String addPrefix(String text, {String prefix = '>> '}) => '$prefix$text';
}

void main() {
  // Create an instance of our formatter
  final formatter = StringFormatter();

  // 1. Basic macro registration
  Macroable.macro<StringFormatter>('repeat', (String text, int times) {
    return text * times;
  });

  print('Basic macro:');
  print(formatter.capitalize('hello')); // Built-in method
  print((formatter as dynamic).repeat('ha ', 3)); // Dynamic macro
  print('---\n');

  // 2. Adding methods with named parameters
  Macroable.macro<StringFormatter>(
    'wrap',
    ({required String text, String start = '[', String end = ']'}) {
      return '$start$text$end';
    },
  );

  print('Named parameters:');
  print((formatter as dynamic).wrap(text: 'hello')); // Uses defaults
  print((formatter as dynamic).wrap(
    text: 'hello',
    start: '<<',
    end: '>>',
  ));
  print('---\n');

  // 3. Mixing in methods from another class
  final transformations = TextTransformations();
  Macroable.mixin<StringFormatter>(transformations);

  print('Mixed-in methods:');
  print((formatter as dynamic).reverse('hello')); // From TextTransformations
  print((formatter as dynamic).addPrefix('hello')); // From TextTransformations
  print((formatter as dynamic).addPrefix(
    'custom prefix',
    prefix: '=> ',
  ));
  print('---\n');

  // 4. Method existence checking
  print('Method checking:');
  print(
      'Has "reverse" macro: ${Macroable.hasMacro<StringFormatter>('reverse')}');
  print(
      'Has "unknown" macro: ${Macroable.hasMacro<StringFormatter>('unknown')}');
  print('---\n');

  // 5. Chaining different operations
  print('Chaining operations:');
  final result = formatter.capitalize(
    (formatter as dynamic).reverse(
      (formatter as dynamic).wrap(text: 'hello world'),
    ),
  );
  print(result);
  print('---\n');

  // 6. Clearing macros
  print('Clearing macros:');
  print('Before clear - has "reverse": '
      '${Macroable.hasMacro<StringFormatter>('reverse')}');

  Macroable.flushMacros<StringFormatter>();

  print('After clear - has "reverse": '
      '${Macroable.hasMacro<StringFormatter>('reverse')}');
}
