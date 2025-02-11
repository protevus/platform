import 'package:test/test.dart';
import 'package:illuminate_support/src/str.dart';

void main() {
  group('Str', () {
    test('camel converts string to camel case', () {
      expect(Str.camel('foo_bar'), equals('fooBar'));
      expect(Str.camel('foo-bar'), equals('fooBar'));
      expect(Str.camel('foo bar'), equals('fooBar'));
      expect(Str.camel('FooBar'), equals('fooBar'));
    });

    test('studly converts string to studly case', () {
      expect(Str.studly('foo_bar'), equals('FooBar'));
      expect(Str.studly('foo-bar'), equals('FooBar'));
      expect(Str.studly('foo bar'), equals('FooBar'));
      expect(Str.studly('fooBar'), equals('FooBar'));
    });

    test('snake converts string to snake case', () {
      expect(Str.snake('fooBar'), equals('foo_bar'));
      expect(Str.snake('foo-bar'), equals('foo_bar'));
      expect(Str.snake('foo bar'), equals('foo_bar'));
      expect(Str.snake('FooBar'), equals('foo_bar'));
    });

    test('kebab converts string to kebab case', () {
      expect(Str.kebab('fooBar'), equals('foo-bar'));
      expect(Str.kebab('foo_bar'), equals('foo-bar'));
      expect(Str.kebab('foo bar'), equals('foo-bar'));
      expect(Str.kebab('FooBar'), equals('foo-bar'));
    });

    test('random generates string of specified length', () {
      expect(Str.random(10).length, equals(10));
      expect(Str.random(20).length, equals(20));
      expect(Str.random(), equals(hasLength(16))); // default length
    });

    test('title converts string to title case', () {
      expect(Str.title('foo bar'), equals('Foo Bar'));
      expect(Str.title('foo_bar'), equals('Foo Bar'));
      expect(Str.title('foo-bar'), equals('Foo Bar'));
      expect(Str.title('fooBar'), equals('Foo Bar'));
    });

    test('lower converts string to lowercase', () {
      expect(Str.lower('FOO BAR'), equals('foo bar'));
      expect(Str.lower('FooBar'), equals('foobar'));
    });

    test('upper converts string to uppercase', () {
      expect(Str.upper('foo bar'), equals('FOO BAR'));
      expect(Str.upper('fooBar'), equals('FOOBAR'));
    });

    test('slug generates URL-friendly slug', () {
      expect(Str.slug('foo bar'), equals('foo-bar'));
      expect(Str.slug('foo_bar'), equals('foo-bar'));
      expect(Str.slug('föö bàr'), equals('foo-bar'));
      expect(Str.slug('foo bar', separator: '_'), equals('foo_bar'));
    });

    test('ascii converts string to ASCII', () {
      expect(Str.ascii('föö bàr'), equals('foo bar'));
      expect(Str.ascii('ñ'), equals('n'));
      expect(Str.ascii('ß'), equals('ss'));
    });

    test('startsWith checks string start', () {
      expect(Str.startsWith('foo bar', 'foo'), isTrue);
      expect(Str.startsWith('foo bar', 'bar'), isFalse);
      expect(Str.startsWith('foo bar', ['foo', 'bar']), isTrue);
      expect(Str.startsWith('foo bar', ['baz', 'qux']), isFalse);
    });

    test('endsWith checks string end', () {
      expect(Str.endsWith('foo bar', 'bar'), isTrue);
      expect(Str.endsWith('foo bar', 'foo'), isFalse);
      expect(Str.endsWith('foo bar', ['foo', 'bar']), isTrue);
      expect(Str.endsWith('foo bar', ['baz', 'qux']), isFalse);
    });

    test('finish caps string', () {
      expect(Str.finish('foo', 'bar'), equals('foobar'));
      expect(Str.finish('foobar', 'bar'), equals('foobar'));
    });

    test('start prefixes string', () {
      expect(Str.start('bar', 'foo'), equals('foobar'));
      expect(Str.start('foobar', 'foo'), equals('foobar'));
    });

    test('contains checks string content', () {
      expect(Str.contains('foo bar', 'bar'), isTrue);
      expect(Str.contains('foo bar', 'baz'), isFalse);
      expect(Str.contains('foo bar', ['baz', 'bar']), isTrue);
      expect(Str.contains('foo bar', ['baz', 'qux']), isFalse);
    });

    test('length returns string length', () {
      expect(Str.length('foo'), equals(3));
      expect(Str.length('foo bar'), equals(7));
    });

    test('limit truncates string', () {
      expect(Str.limit('foo bar', 3), equals('foo...'));
      expect(Str.limit('foo bar', 3, '---'), equals('foo---'));
      expect(Str.limit('foo', 4), equals('foo'));
    });

    test('toBase64 encodes string to base64', () {
      expect(Str.toBase64('foo bar'), equals('Zm9vIGJhcg=='));
    });

    test('fromBase64 decodes base64 to string', () {
      expect(Str.fromBase64('Zm9vIGJhcg=='), equals('foo bar'));
    });

    test('parseCallback parses callback string', () {
      expect(Str.parseCallback('Class@method'), equals(['Class', 'method']));
      expect(Str.parseCallback('InvalidCallback'), isNull);
    });

    test('uuid generates valid UUID', () {
      final uuid = Str.uuid();
      expect(
          uuid,
          matches(RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    });

    test('format replaces named parameters', () {
      expect(
          Str.format('Hello :name', {'name': 'World'}), equals('Hello World'));
      expect(Str.format('Hello :name :age', {'name': 'John', 'age': '25'}),
          equals('Hello John 25'));
    });

    test('mask masks portion of string', () {
      expect(Str.mask('1234567890', 6), equals('123456****'));
      expect(Str.mask('1234567890', 6, 2), equals('123456**90'));
      expect(Str.mask('1234567890', 0, 4, '#'), equals('####567890'));
    });

    test('padBoth pads string on both sides', () {
      expect(Str.padBoth('foo', 7), equals('  foo  '));
      expect(Str.padBoth('foo', 7, '_'), equals('__foo__'));
    });

    test('padLeft pads string on left side', () {
      expect(Str.padLeft('foo', 5), equals('  foo'));
      expect(Str.padLeft('foo', 5, '_'), equals('__foo'));
    });

    test('padRight pads string on right side', () {
      expect(Str.padRight('foo', 5), equals('foo  '));
      expect(Str.padRight('foo', 5, '_'), equals('foo__'));
    });
  });
}
