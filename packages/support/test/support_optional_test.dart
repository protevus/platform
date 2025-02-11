import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';
import 'package:illuminate_mirrors/mirrors.dart';

@reflectable
class TestObject {
  String? item;
  TestObject([this.item]);
}

void main() {
  late RuntimeReflector reflector;

  setUp(() {
    reflector = RuntimeReflector.instance;
    ReflectionRegistry.reset();

    // Register TestObject for reflection
    ReflectionRegistry.register(TestObject);

    // Register property
    ReflectionRegistry.registerProperty(TestObject, 'item', String);

    // Register constructors
    ReflectionRegistry.registerConstructor(
      TestObject,
      '',
      parameterTypes: [String],
      parameterNames: ['item'],
      isRequired: [false],
      creator: (String? item) => TestObject(item),
    );
  });

  group('SupportOptional', () {
    test('getExistItemOnObject', () {
      final expected = 'test';
      final targetObj = TestObject(expected);
      final optional = Optional(targetObj);

      expect(optional.prop('item'), equals(expected));
    });

    test('getNotExistItemOnObject', () {
      final targetObj = TestObject();
      final optional = Optional(targetObj);

      expect(optional.prop('item'), isNull);
    });

    test('issetExistItemOnObject', () {
      final targetObj = TestObject('');
      final optional = Optional(targetObj);

      expect(optional.has('item'), isTrue);
    });

    test('issetNotExistItemOnObject', () {
      final targetObj = TestObject();
      final optional = Optional(targetObj);

      expect(optional.has('item'), isTrue); // Property exists but value is null
    });

    test('getExistItemOnMap', () {
      final expected = 'test';
      final targetMap = {
        'item': expected,
      };
      final optional = Optional(targetMap);

      expect(optional.prop('item'), equals(expected));
    });

    test('getNotExistItemOnMap', () {
      final targetMap = <String, dynamic>{};
      final optional = Optional(targetMap);

      expect(optional.prop('item'), isNull);
    });

    test('issetExistItemOnMap', () {
      final targetMap = {
        'item': '',
      };
      final optional = Optional(targetMap);

      expect(optional.has('item'), isTrue);
      expect(optional.has('item'), isTrue);
    });

    test('issetNotExistItemOnMap', () {
      final targetMap = <String, dynamic>{};
      final optional = Optional(targetMap);

      expect(optional.has('item'), isFalse);
      expect(optional.has('item'), isFalse);
    });

    test('issetExistItemOnNull', () {
      final optional = Optional(null);

      expect(optional.has('item'), isFalse);
    });

    test('array access works like object access', () {
      final targetMap = {
        'item': 'test',
      };
      final optional = Optional(targetMap);

      expect(optional['item'], equals(optional.prop('item')));
      expect(optional.has('item'), isTrue);
    });
  });
}
