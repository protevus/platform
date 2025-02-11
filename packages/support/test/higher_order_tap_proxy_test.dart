import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

// Test class to use with HigherOrderTapProxy
class TestTarget {
  String value = '';

  void appendText(String text) {
    value += text;
  }

  void clear() {
    value = '';
  }

  String getValue() => value;

  @override
  String toString() => 'TestTarget($value)';
}

void main() {
  group('HigherOrderTapProxy', () {
    late TestTarget target;
    late HigherOrderTapProxy<TestTarget> proxy;

    setUp(() {
      target = TestTarget();
      proxy = HigherOrderTapProxy(target);
    });

    test('can access target object', () {
      expect(proxy.target, equals(target));
    });

    test('forwards method calls to target', () {
      target.appendText('Hello');
      expect(target.value, equals('Hello'));
    });

    test('supports method chaining', () {
      target
        ..appendText('Hello')
        ..appendText(' ')
        ..appendText('World');

      expect(target.value, equals('Hello World'));
    });

    test('maintains proxy instance through chaining', () {
      final result = proxy;
      target.appendText('Hello');
      expect(result, same(proxy));
    });

    test('handles non-existent methods', () {
      expect(
        () => (target as dynamic).nonExistentMethod(),
        throwsNoSuchMethodError,
      );
    });

    test('toString provides meaningful representation', () {
      target.appendText('test');
      expect(
        proxy.toString(),
        equals('HigherOrderTapProxy(TestTarget(test))'),
      );
    });

    test('can clear and modify target state', () {
      target
        ..appendText('Hello')
        ..clear();

      expect(target.value, isEmpty);
    });

    test('can get target state after modifications', () {
      target
        ..appendText('Hello')
        ..appendText(' World');

      expect(target.getValue(), equals('Hello World'));
    });
  });
}
