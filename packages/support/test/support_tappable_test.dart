import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_mirrors/mirrors.dart';

@reflectable
class TappableTest with Tappable {
  String value = '';

  TappableTest setValue(String newValue) {
    value = newValue;
    return this;
  }

  String getValue() => value;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #setValue &&
        invocation.positionalArguments.length == 1) {
      return setValue(invocation.positionalArguments[0] as String);
    }
    if (invocation.memberName == #getValue &&
        invocation.positionalArguments.isEmpty) {
      return getValue();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late TappableTest instance;

  setUp(() {
    instance = TappableTest();

    // Register class and methods for reflection
    ReflectionRegistry.reset();
    ReflectionRegistry.register(TappableTest);

    // Register setValue method
    ReflectionRegistry.registerMethod(
      TappableTest,
      'setValue',
      [String],
      false, // not void
      parameterNames: ['newValue'],
      isRequired: [true],
    );

    // Register getValue method
    ReflectionRegistry.registerMethod(
      TappableTest,
      'getValue',
      [],
      false, // not void
    );

    // Register tap method
    ReflectionRegistry.registerMethod(
      TappableTest,
      'tap',
      [Function],
      false, // not void
      parameterNames: ['callback'],
      isRequired: [false],
    );
  });

  group('Tappable', () {
    test('tap executes callback and returns instance', () {
      var callbackExecuted = false;
      final result = instance.tap((obj) {
        callbackExecuted = true;
        expect(obj, equals(instance));
      });

      expect(callbackExecuted, isTrue);
      expect(result, equals(instance));
    });

    test('tap can be used in method chains', () {
      var beforeValue = '';
      var afterValue = '';

      instance
          .tap((obj) => beforeValue = obj.getValue())
          .setValue('test')
          .tap((obj) => afterValue = obj.getValue());

      expect(beforeValue, equals(''));
      expect(afterValue, equals('test'));
      expect(instance.value, equals('test'));
    });

    test('tap returns HigherOrderTapProxy when no callback provided', () {
      final proxy = instance.tap();
      expect(proxy, isA<HigherOrderTapProxy>());
    });

    test('tap proxy forwards method calls to target', () {
      instance.tap().setValue('via proxy');
      expect(instance.value, equals('via proxy'));
    });

    test('tap proxy can be chained', () {
      instance
          .tap() // Returns proxy
          .setValue('first')
          .setValue('second');

      expect(instance.value, equals('second'));
    });

    test('tap proxy maintains instance state', () {
      instance
          .tap() // Returns proxy
          .setValue('test'); // Called on instance via proxy

      final result = instance.getValue(); // Called directly
      expect(result, equals('test'));
    });

    test('tap callback can modify instance state', () {
      instance.tap((obj) {
        (obj as TappableTest).setValue('modified');
      });

      expect(instance.value, equals('modified'));
    });

    test('tap callback receives correct instance', () {
      instance.setValue('initial');

      instance.tap((obj) {
        expect(obj, equals(instance));
        expect((obj as TappableTest).value, equals('initial'));
      });
    });

    test('tap proxy forwards multiple method calls', () {
      instance.tap().setValue('first').setValue('second').setValue('third');

      expect(instance.value, equals('third'));
    });

    test('tap can mix callbacks and proxies', () {
      var middleValue = '';

      instance
          .setValue('first')
          .tap((obj) => middleValue = obj.getValue())
          .setValue('last');

      expect(middleValue, equals('first'));
      expect(instance.value, equals('last'));
    });
  });
}
