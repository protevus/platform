import 'package:test/test.dart';
import '../lib/conditionable.dart';

class TestClass with Conditionable {
  String value = '';

  TestClass append(String text) {
    value += text;
    return this;
  }
}

void main() {
  group('Conditionable', () {
    late TestClass instance;

    setUp(() {
      instance = TestClass();
    });

    group('when', () {
      test('executes callback when condition is true', () {
        instance.when(true, (self, value) {
          (self as TestClass).append('true');
        });

        expect(instance.value, equals('true'));
      });

      test('skips callback when condition is false', () {
        instance.when(false, (self, value) {
          (self as TestClass).append('false');
        });

        expect(instance.value, isEmpty);
      });

      test('executes orElse when condition is false', () {
        instance.when(
          false,
          (self, value) {
            (self as TestClass).append('false');
          },
          orElse: (self, value) {
            (self as TestClass).append('else');
          },
        );

        expect(instance.value, equals('else'));
      });

      test('evaluates closure conditions', () {
        instance.when(() => true, (self, value) {
          (self as TestClass).append('closure');
        });

        expect(instance.value, equals('closure'));
      });

      test('supports method chaining', () {
        instance.when(true, (self, value) {
          (self as TestClass).append('first');
          return self;
        }).when(true, (self, value) {
          (self as TestClass).append('-second');
          return self;
        });

        expect(instance.value, equals('first-second'));
      });
    });

    group('unless', () {
      test('executes callback when condition is false', () {
        instance.unless(false, (self, value) {
          (self as TestClass).append('false');
        });

        expect(instance.value, equals('false'));
      });

      test('skips callback when condition is true', () {
        instance.unless(true, (self, value) {
          (self as TestClass).append('true');
        });

        expect(instance.value, isEmpty);
      });

      test('executes orElse when condition is true', () {
        instance.unless(
          true,
          (self, value) {
            (self as TestClass).append('true');
          },
          orElse: (self, value) {
            (self as TestClass).append('else');
          },
        );

        expect(instance.value, equals('else'));
      });

      test('evaluates closure conditions', () {
        instance.unless(() => false, (self, value) {
          (self as TestClass).append('closure');
        });

        expect(instance.value, equals('closure'));
      });
    });

    group('whenThen', () {
      test('executes callback in method cascade when condition is true', () {
        instance
          ..whenThen(true, () {
            instance.append('cascade');
          })
          ..append('-end');

        expect(instance.value, equals('cascade-end'));
      });

      test('executes orElse in method cascade when condition is false', () {
        instance
          ..whenThen(
            false,
            () {
              instance.append('false');
            },
            orElse: () {
              instance.append('else');
            },
          )
          ..append('-end');

        expect(instance.value, equals('else-end'));
      });
    });

    group('unlessThen', () {
      test('executes callback in method cascade when condition is false', () {
        instance
          ..unlessThen(false, () {
            instance.append('cascade');
          })
          ..append('-end');

        expect(instance.value, equals('cascade-end'));
      });

      test('executes orElse in method cascade when condition is true', () {
        instance
          ..unlessThen(
            true,
            () {
              instance.append('true');
            },
            orElse: () {
              instance.append('else');
            },
          )
          ..append('-end');

        expect(instance.value, equals('else-end'));
      });
    });

    test('complex chaining with mixed conditions', () {
      instance
        ..when(true, (self, value) {
          (self as TestClass).append('1');
          return self;
        })
        ..unless(false, (self, value) {
          (self as TestClass).append('-2');
          return self;
        })
        ..whenThen(true, () {
          instance.append('-3');
        })
        ..unlessThen(false, () {
          instance.append('-4');
        });

      expect(instance.value, equals('1-2-3-4'));
    });
  });
}
