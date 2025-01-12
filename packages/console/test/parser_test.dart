import 'package:platform_console/platform_console.dart';
import 'package:platform_console/src/output/table.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    test('extracts command name', () {
      final (name, _, _) = Parser.parse('test {arg}');
      expect(name, equals('test'));
    });

    test('parses required arguments', () {
      final (_, args, _) = Parser.parse('test {name}');

      expect(args.length, equals(1));
      expect(args.first.name, equals('name'));
      expect(args.first.mode, equals(InputArgumentMode.required));
      expect(args.first.description, isEmpty);
    });

    test('parses optional arguments', () {
      final (_, args, _) = Parser.parse('test {name?}');

      expect(args.length, equals(1));
      expect(args.first.name, equals('name'));
      expect(args.first.mode, equals(InputArgumentMode.optional));
      expect(args.first.defaultValue, isEmpty);
    });

    test('parses arguments with defaults', () {
      final (_, args, _) = Parser.parse('test {name=World}');

      expect(args.length, equals(1));
      expect(args.first.name, equals('name'));
      expect(args.first.mode, equals(InputArgumentMode.optional));
      expect(args.first.defaultValue, equals('World'));
    });

    test('parses array arguments', () {
      final (_, args, _) = Parser.parse('test {names*}');

      expect(args.length, equals(1));
      expect(args.first.name, equals('names'));
      expect(args.first.mode, equals(InputArgumentMode.isArray));
    });

    test('parses argument descriptions', () {
      final (_, args, _) = Parser.parse('test {name : The name to use}');

      expect(args.length, equals(1));
      expect(args.first.name, equals('name'));
      expect(args.first.description, equals('The name to use'));
    });

    test('parses flag options', () {
      final (_, _, options) = Parser.parse('test {--flag}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('flag'));
      expect(options.first.mode, equals(InputOptionMode.none));
      expect(options.first.shortcut, isNull);
    });

    test('parses value options', () {
      final (_, _, options) = Parser.parse('test {--option=}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('option'));
      expect(options.first.mode, equals(InputOptionMode.optional));
      expect(options.first.defaultValue, isEmpty);
    });

    test('parses options with defaults', () {
      final (_, _, options) = Parser.parse('test {--option=default}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('option'));
      expect(options.first.mode, equals(InputOptionMode.optional));
      expect(options.first.defaultValue, equals('default'));
    });

    test('parses array options', () {
      final (_, _, options) = Parser.parse('test {--options=*}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('options'));
      expect(options.first.mode, equals(InputOptionMode.isArray));
    });

    test('parses option shortcuts', () {
      final (_, _, options) = Parser.parse('test {-o|--option}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('option'));
      expect(options.first.shortcut, equals('o'));
    });

    test('parses option descriptions', () {
      final (_, _, options) = Parser.parse('test {--flag : Enable the flag}');

      expect(options.length, equals(1));
      expect(options.first.name, equals('flag'));
      expect(options.first.description, equals('Enable the flag'));
    });

    test('parses multiple arguments and options', () {
      final (name, args, options) = Parser.parse(
        'test {name} {age?} {--flag} {-v|--verbose} {--log=error}',
      );

      expect(name, equals('test'));

      expect(args.length, equals(2));
      expect(args[0].name, equals('name'));
      expect(args[0].mode, equals(InputArgumentMode.required));
      expect(args[1].name, equals('age'));
      expect(args[1].mode, equals(InputArgumentMode.optional));

      expect(options.length, equals(3));
      expect(options[0].name, equals('flag'));
      expect(options[0].mode, equals(InputOptionMode.none));
      expect(options[1].name, equals('verbose'));
      expect(options[1].shortcut, equals('v'));
      expect(options[2].name, equals('log'));
      expect(options[2].mode, equals(InputOptionMode.optional));
      expect(options[2].defaultValue, equals('error'));
    });

    test('throws on invalid signature format', () {
      expect(
        () => Parser.parse(''),
        throwsArgumentError,
      );
      expect(
        () => Parser.parse('test {invalid'),
        throwsArgumentError,
      );
    });
  });
}
