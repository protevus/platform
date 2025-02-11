import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Support Helpers', () {
    test('env retrieves environment variables', () {
      Env.put('TEST_KEY', 'test_value');
      expect(env('TEST_KEY'), equals('test_value'));
      expect(env('NON_EXISTENT', 'default'), equals('default'));
    });

    test('collect creates collection from value', () {
      final collection = collect([1, 2, 3]);
      expect(collection, isNotNull);
      expect(collection, contains(2));
    });

    test('string creates fluent string instance', () {
      final str = string('hello');
      expect(str, isA<Fluent>());
      expect(str.get('value'), equals('hello'));
    });

    test('optional creates optional instance', () {
      final opt = optional('value');
      expect(opt, isA<Optional>());
      expect(opt.value, equals('value'));

      final empty = optional(null);
      expect(empty.isEmpty, isTrue);
    });

    test('tap executes callback and returns value', () {
      var called = false;
      final result = tap(10, (value) {
        called = true;
        expect(value, equals(10));
      });
      expect(called, isTrue);
      expect(result, equals(10));
    });

    test('createOnce creates once instance', () {
      var count = 0;
      final once = createOnce();
      once.call(() => count++);
      once.call(() => count++);
      expect(count, equals(1));
    });

    test('createOnceable creates onceable instance', () {
      var count = 0;
      final onceable = createOnceable();
      onceable.once('key', () => count++);
      onceable.once('key', () => count++);
      expect(count, equals(1));
    });

    test('sleepFor pauses execution', () async {
      final start = DateTime.now();
      await sleepFor(Duration(milliseconds: 100));
      final duration = DateTime.now().difference(start);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('stringify converts values to strings', () {
      expect(stringify(123), equals('123'));
      expect(stringify(null), equals(''));
      expect(stringify('hello'), equals('hello'));
    });

    test('snakeCase converts strings to snake_case', () {
      expect(snakeCase('fooBar'), equals('foo_bar'));
      expect(snakeCase('FooBar'), equals('foo_bar'));
      expect(snakeCase('foo-bar'), equals('foo_bar'));
    });

    test('camelCase converts strings to camelCase', () {
      expect(camelCase('foo_bar'), equals('fooBar'));
      expect(camelCase('FooBar'), equals('fooBar'));
      expect(camelCase('foo-bar'), equals('fooBar'));
    });

    test('studlyCase converts strings to StudlyCase', () {
      expect(studlyCase('foo_bar'), equals('FooBar'));
      expect(studlyCase('fooBar'), equals('FooBar'));
      expect(studlyCase('foo-bar'), equals('FooBar'));
    });

    test('randomString generates random string', () {
      final str1 = randomString();
      final str2 = randomString();
      expect(str1.length, equals(16));
      expect(str2.length, equals(16));
      expect(str1, isNot(equals(str2)));

      final customLength = randomString(8);
      expect(customLength.length, equals(8));
    });

    test('slugify creates URL friendly slug', () {
      expect(slugify('Hello World'), equals('hello-world'));
      expect(slugify('Hello  World!'), equals('hello-world'));
      expect(slugify('Hello_World', separator: '_'), equals('hello_world'));
    });

    test('data gets value using dot notation', () {
      final target = {
        'user': {'name': 'John', 'age': 30},
        'active': true
      };

      expect(data('user.name', target), equals('John'));
      expect(data('user.age', target), equals(30));
      expect(data('active', target), equals(true));
      expect(data('missing', target, 'default'), equals('default'));
    });

    test('blank determines if value is empty', () {
      expect(blank(null), isTrue);
      expect(blank(''), isTrue);
      expect(blank(' '), isTrue);
      expect(blank([]), isTrue);
      expect(blank({}), isTrue);

      expect(blank('hello'), isFalse);
      expect(blank([1, 2]), isFalse);
      expect(blank({'key': 'value'}), isFalse);
    });

    test('filled determines if value is not empty', () {
      expect(filled(null), isFalse);
      expect(filled(''), isFalse);
      expect(filled(' '), isFalse);
      expect(filled([]), isFalse);
      expect(filled({}), isFalse);

      expect(filled('hello'), isTrue);
      expect(filled([1, 2]), isTrue);
      expect(filled({'key': 'value'}), isTrue);
    });

    test('value_of returns value from callback', () {
      expect(value_of(() => 'hello'), equals('hello'));
      expect(value_of(() => 42), equals(42));
    });

    test('when transforms value based on condition', () {
      expect(when(true, () => 'yes', orElse: () => 'no'), equals('yes'));
      expect(when(false, () => 'yes', orElse: () => 'no'), equals('no'));
    });

    test('class_basename gets class name', () {
      expect(class_basename('hello'), equals('String'));
      expect(class_basename(123), equals('int'));
      expect(class_basename([]), equals('List<dynamic>'));
    });
  });
}
