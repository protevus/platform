import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

class DumpableTest with Dumpable {
  final String value;
  DumpableTest(this.value);

  @override
  String toString() => value;
}

void main() {
  late List<String> dumpOutput;
  late DumpableTest instance;

  setUp(() {
    dumpOutput = [];
    instance = DumpableTest('test value');

    // Set custom dump function that captures output
    Dumpable.setDumpFunction((value) {
      dumpOutput.add('Dump: $value');
    });
  });

  tearDown(() {
    Dumpable.resetDumpFunction();
  });

  group('Dumpable', () {
    test('dump outputs object state', () {
      instance.dump([]);
      expect(dumpOutput, equals(['Dump: test value']));
    });

    test('dump outputs additional arguments', () {
      instance.dump(['arg1', 42, null]);
      expect(
          dumpOutput,
          equals([
            'Dump: test value',
            'Dump: arg1',
            'Dump: 42',
            'Dump: null',
          ]));
    });

    test('dump returns this for chaining', () {
      final result = instance.dump([]);
      expect(result, equals(instance));
    });

    test('dd outputs and throws', () {
      expect(
        () => instance.dd(['arg1']),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Execution terminated by dd()',
        )),
      );

      expect(
          dumpOutput,
          equals([
            'Dump: test value',
            'Dump: arg1',
          ]));
    });

    test('custom dump function can be set', () {
      final customOutput = <String>[];
      Dumpable.setDumpFunction((value) {
        customOutput.add('Custom: $value');
      });

      instance.dump(['test']);

      expect(
          customOutput,
          equals([
            'Custom: test value',
            'Custom: test',
          ]));
      expect(dumpOutput, isEmpty);
    });

    test('dump function can be reset', () {
      Dumpable.resetDumpFunction();
      instance.dump([]); // Will use default print function
      expect(dumpOutput, isEmpty); // Our test capture won't see default output
    });

    test('dump handles various types', () {
      instance.dump([
        'string',
        42,
        3.14,
        true,
        null,
        [1, 2, 3],
        {'key': 'value'},
      ]);

      expect(
          dumpOutput,
          equals([
            'Dump: test value',
            'Dump: string',
            'Dump: 42',
            'Dump: 3.14',
            'Dump: true',
            'Dump: null',
            'Dump: [1, 2, 3]',
            'Dump: {key: value}',
          ]));
    });

    test('dump handles nested dumpable objects', () {
      final nested = DumpableTest('nested value');
      instance.dump([nested]);

      expect(
          dumpOutput,
          equals([
            'Dump: test value',
            'Dump: nested value',
          ]));
    });

    test('dd terminates execution immediately', () {
      var executed = false;
      try {
        instance.dd([]);
        executed = true;
      } catch (_) {}
      expect(executed, isFalse);
    });
  });
}
