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
      expect(command.hasArgument('name'), isFalse); // Not parsed until run
      expect(command.hasOption('flag'), isFalse); // Not parsed until run
      expect(command.hasOption('option'), isFalse); // Not parsed until run
      expect(command.hasOption('default'), isFalse); // Not parsed until run
    });

    test('handles required arguments', () async {
      final command = TestCommand(
        signature: 'test {name}',
      );

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles optional arguments', () async {
      final command = TestCommand(
        signature: 'test {name?}',
      );

      await command.run([]);
      expect(command.argument<String>('name'), isNull);

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles default argument values', () async {
      final command = TestCommand(
        signature: 'test {name=World}',
      );

      await command.run([]);
      expect(command.argument<String>('name'), equals('World'));

      await command.run(['John']);
      expect(command.argument<String>('name'), equals('John'));
    });

    test('handles flags', () async {
      final command = TestCommand(
        signature: 'test {--flag}',
      );

      await command.run([]);
      expect(command.option<bool>('flag'), isFalse);

      await command.run(['--flag']);
      expect(command.option<bool>('flag'), isTrue);
    });

    test('handles options with values', () async {
      final command = TestCommand(
        signature: 'test {--option=}',
      );

      await command.run([]);
      expect(command.option('option'), isNull);

      await command.run(['--option', 'value']);
      expect(command.option('option'), equals('value'));
    });

    test('handles options with default values', () async {
      final command = TestCommand(
        signature: 'test {--option=default}',
      );

      await command.run([]);
      expect(command.option('option'), equals('default'));

      await command.run(['--option', 'value']);
      expect(command.option('option'), equals('value'));
    });

    test('handles option shortcuts', () async {
      final command = TestCommand(
        signature: 'test {-f|--flag}',
      );

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

      expect(() => command.run([]), throwsArgumentError);
    });

    test('throws on invalid option format', () async {
      final command = TestCommand(
        signature: 'test {--option=}',
      );

      expect(() => command.run(['--option']), throwsArgumentError);
    });

    test('provides access to output', () {
      expect(command.output, equals(output));
    });
  });
}
