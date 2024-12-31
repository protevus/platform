import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('Factory Tests', () {
    late Factory factory;

    setUp(() {
      factory = Factory();
    });

    test('command() creates PendingProcess with string command', () {
      final process = factory.command('echo Hello');
      expect(process, isA<PendingProcess>());
    });

    test('command() creates PendingProcess with list command', () {
      final process = factory.command(['echo', 'Hello']);
      expect(process, isA<PendingProcess>());
    });

    test('command() with null throws ArgumentError', () {
      expect(() => factory.command(null), throwsArgumentError);
    });

    test('command() with empty string throws ArgumentError', () {
      expect(() => factory.command(''), throwsArgumentError);
    });

    test('command() with empty list throws ArgumentError', () {
      expect(() => factory.command([]), throwsArgumentError);
    });

    test('command() with invalid type throws ArgumentError', () {
      expect(() => factory.command(123), throwsArgumentError);
    });

    test('command() with list containing non-string throws ArgumentError', () {
      expect(() => factory.command(['echo', 123]), throwsArgumentError);
    });
  });
}
