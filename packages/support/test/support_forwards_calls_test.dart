import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_reflection/mirrors.dart';

@reflectable
class TargetClass {
  String value = '';

  String getValue() => value;
  void setValue(String newValue) => value = newValue;
  TargetClass chainedMethod() => this;
  void throwingMethod() => throw Exception('Test exception');
}

class ForwarderClass with ForwardsCalls {
  final TargetClass? target;

  ForwarderClass(this.target);

  dynamic forward(String method, List<dynamic> args) {
    return forwardCallTo(target!, method, args);
  }

  dynamic forwardDecorated(String method, List<dynamic> args) {
    return forwardDecoratedCallTo(target!, method, args);
  }
}

void main() {
  late ForwarderClass forwarder;
  late TargetClass target;

  setUp(() {
    // Register classes for reflection
    Reflector.reset();
    Reflector.register(TargetClass);

    // Register methods
    Reflector.registerMethod(
      TargetClass,
      'getValue',
      [/* no parameters */],
      false, // not void
    );

    Reflector.registerMethod(
      TargetClass,
      'setValue',
      [String],
      true, // void
      parameterNames: ['newValue'],
      isRequired: [true],
    );

    Reflector.registerMethod(
      TargetClass,
      'chainedMethod',
      [/* no parameters */],
      false, // not void
    );

    Reflector.registerMethod(
      TargetClass,
      'throwingMethod',
      [/* no parameters */],
      true, // void
    );

    target = TargetClass();
    forwarder = ForwarderClass(target);
  });

  group('ForwardsCalls', () {
    test('forwards method calls to target object', () {
      target.value = 'test';
      expect(forwarder.forward('getValue', []), equals('test'));

      forwarder.forward('setValue', ['new value']);
      expect(target.value, equals('new value'));
    });

    test('handles chained method calls', () {
      final result = forwarder.forwardDecorated('chainedMethod', []);
      expect(result, equals(forwarder));
    });

    test('throws on undefined methods', () {
      expect(
        () => forwarder.forward('undefinedMethod', []),
        throwsNoSuchMethodError,
      );
    });

    test('throws on null target', () {
      final invalidForwarder = ForwarderClass(null);
      expect(
        () => invalidForwarder.forward('getValue', []),
        throwsA(isA<Error>()),
      );
    });

    test('preserves original exceptions', () {
      expect(
        () => forwarder.forward('throwingMethod', []),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Test exception',
        )),
      );
    });

    test('handles method calls with arguments', () {
      forwarder.forward('setValue', ['test value']);
      expect(target.value, equals('test value'));
    });

    test('forwards return values correctly', () {
      target.value = 'test value';
      expect(forwarder.forward('getValue', []), equals('test value'));
    });

    test('handles decorated method calls', () {
      // Test with method that returns target
      var result = forwarder.forwardDecorated('chainedMethod', []);
      expect(result, equals(forwarder));

      // Test with method that returns other value
      target.value = 'test';
      result = forwarder.forwardDecorated('getValue', []);
      expect(result, equals('test'));
    });
  });
}
