import 'package:illuminate_console/console.dart';
import 'package:test/test.dart';

import '../utils/test_output.dart';

void main() {
  group('ConsoleOutput', () {
    late TestOutput output;

    setUp(() {
      output = TestOutput();
    });

    test('writes messages', () {
      output.write('Hello');
      output.write(' World');

      expect(output.output, equals('Hello World'));
    });

    test('writes messages with newlines', () {
      output.writeln('Line 1');
      output.writeln('Line 2');

      expect(output.output, equals('Line 1\nLine 2\n'));
    });

    test('writes blank lines', () {
      output.writeln('Before');
      output.newLine(2);
      output.writeln('After');

      expect(output.output, equals('Before\n\n\nAfter\n'));
    });

    test('writes info messages', () {
      output.info('Information');
      expect(output.output, contains('Information'));
    });

    test('writes error messages', () {
      output.error('Error occurred');
      expect(output.errorOutput, contains('Error occurred'));
    });

    test('writes warning messages', () {
      output.warning('Warning');
      expect(output.output, contains('Warning'));
    });

    test('writes success messages', () {
      output.success('Success');
      expect(output.output, contains('Success'));
    });

    test('writes comment messages', () {
      output.comment('Comment');
      expect(output.output, contains('Comment'));
    });

    test('writes question messages', () {
      output.question('Question?');
      expect(output.output, contains('Question?'));
    });

    test('formats tables', () {
      output.table(
        ['ID', 'Name'],
        [
          ['1', 'John'],
          ['2', 'Jane'],
        ],
      );

      final lines = output.output.split('\n');
      expect(lines[0], contains('┌'));
      expect(lines[0], contains('┐'));
      expect(lines[1], contains('ID'));
      expect(lines[1], contains('Name'));
    });

    test('clears captured output', () {
      output.writeln('Before');
      output.error('Error');

      output.clear();

      expect(output.output, isEmpty);
      expect(output.errorOutput, isEmpty);
    });
  });

  group('BufferedOutput', () {
    late BufferedOutput output;

    setUp(() {
      output = BufferedOutput();
    });

    test('buffers output', () {
      output.writeln('Line 1');
      output.writeln('Line 2');

      expect(output.content, equals('Line 1\nLine 2\n'));
    });

    test('buffers styled output', () {
      output.info('Info');
      output.error('Error');
      output.warning('Warning');

      expect(output.content, contains('Info'));
      expect(output.content, contains('Error'));
      expect(output.content, contains('Warning'));
    });

    test('clears buffer', () {
      output.writeln('Content');
      output.clear();

      expect(output.content, isEmpty);
    });

    test('respects verbosity level', () {
      final output = BufferedOutput(verbosity: Verbosity.quiet);
      expect(output.verbosity, equals(Verbosity.quiet));
    });
  });
}
