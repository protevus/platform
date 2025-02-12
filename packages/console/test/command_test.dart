import 'package:test/test.dart';

import 'utils/test_command.dart';
import 'utils/test_output.dart';

void main() {
  group('Command', () {
    late TestOutput output;
    late TestCommand command;

    setUp(() {
      output = TestOutput();
      command = TestCommand();
      command.setOutput(output);
    });

    test('parses signature correctly', () {
      final command = TestCommand(
        signature: 'test {name} {--flag} {--option=} {--default=value}',
      );

      expect(command.name, equals('test'));
      expect(command.hasArgument('name'), isTrue); // Check if defined
      expect(command.hasOption('flag'), isTrue); // Check if defined
      expect(command.hasOption('option'), isTrue); // Check if defined
      expect(command.hasOption('default'), isTrue); // Check if defined
    });

    test('handles required arguments', () async {
      final command = TestCommand(
        signature: 'test {name}',
      );
      command.setOutput(output);

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles optional arguments', () async {
      final command = TestCommand(
        signature: 'test {name?}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.argument<String>('name'), isNull);

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles default argument values', () async {
      final command = TestCommand(
        signature: 'test {name=World}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.argument<String>('name'), equals('World'));

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles flags', () async {
      final command = TestCommand(
        signature: 'test {--flag}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.option<bool>('flag'), isFalse);

      await command.run(['--flag']);
      expect(command.option<bool>('flag'), isTrue);
    });

    test('handles options with values', () async {
      final command = TestCommand(
        signature: 'test {--option=}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.option('option'), isNull);

      await command.run(['--option', 'value']);
      expect(command.option('option'), equals('value'));
    });

    test('handles options with default values', () async {
      final command = TestCommand(
        signature: 'test {--option=default}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.option('option'), equals('default'));

      await command.run(['--option', 'value']);
      expect(command.option('option'), equals('value'));
    });

    test('handles option shortcuts', () async {
      final command = TestCommand(
        signature: 'test {-f|--flag}',
      );
      command.setOutput(output);

      await command.run([]);
      expect(command.option<bool>('flag'), isFalse);

      await command.run(['-f']);
      expect(command.option<bool>('flag'), isTrue);

      await command.run(['--flag']);
      expect(command.option<bool>('flag'), isTrue);
    });

    test('throws on missing required arguments', () async {
      final command = TestCommand(
        signature: 'test {name}',
      );
      command.setOutput(output);

      expect(() => command.run([]), throwsA(isA<ArgumentError>()));
    });

    test('throws on invalid option format', () async {
      final command = TestCommand(
        signature: 'test {--option=}',
      );
      command.setOutput(output);

      expect(() => command.run(['--option']), throwsA(isA<ArgumentError>()));
    });

    test('provides access to output', () {
      expect(command.output, equals(output));
    });
  });
}
