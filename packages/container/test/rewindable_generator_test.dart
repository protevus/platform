import 'package:platform_container/container.dart';
import 'package:test/test.dart';

void main() {
  test('count uses provided value', () {
    final generator = RewindableGenerator(
      () sync* {
        yield 'foo';
      },
      999,
    );

    expect(generator.length, equals(999));
  });

  test('count uses provided value as callback', () {
    var called = 0;

    final generator = RewindableGenerator(
      () sync* {
        yield 'foo';
      },
      () {
        called++;
        return 500;
      },
    );

    // The count callback is called lazily
    expect(called, equals(0));

    expect(generator.length, equals(500));

    // Force another count
    generator.length;

    // The count callback is called only once
    expect(called, equals(1));
  });

  test('can iterate multiple times', () {
    final generator = RewindableGenerator(
      () sync* {
        yield 'foo';
        yield 'bar';
      },
      2,
    );

    // First iteration
    final firstRun = generator.toList();
    expect(firstRun, equals(['foo', 'bar']));

    // Second iteration
    final secondRun = generator.toList();
    expect(secondRun, equals(['foo', 'bar']));
  });

  test('count matches actual items', () {
    final generator = RewindableGenerator(
      () sync* {
        yield 'foo';
        yield 'bar';
        yield 'baz';
      },
      3,
    );

    expect(generator.length, equals(3));
    expect(generator.toList().length, equals(3));
  });
}
