import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

void main() {
  group('Stringable', () {
    late Stringable str;

    setUp(() {
      str = Stringable('hello world');
    });

    test('creates instance from string', () {
      expect(str.toString(), equals('hello world'));
    });

    test('converts to camel case', () {
      str = Stringable('hello_world');
      expect(str.camel().toString(), equals('helloWorld'));
    });

    test('converts to studly case', () {
      str = Stringable('hello_world');
      expect(str.studly().toString(), equals('HelloWorld'));
    });

    test('converts to snake case', () {
      str = Stringable('helloWorld');
      expect(str.snake().toString(), equals('hello_world'));
      expect(str.snake('-').toString(), equals('hello-world'));
    });

    test('converts to kebab case', () {
      str = Stringable('helloWorld');
      expect(str.kebab().toString(), equals('hello-world'));
    });

    test('converts to title case', () {
      expect(str.title().toString(), equals('Hello World'));
    });

    test('converts to lower case', () {
      str = Stringable('HELLO WORLD');
      expect(str.lower().toString(), equals('hello world'));
    });

    test('converts to upper case', () {
      expect(str.upper().toString(), equals('HELLO WORLD'));
    });

    test('generates slug', () {
      str = Stringable('Hello World!');
      expect(str.slug().toString(), equals('hello-world'));
      expect(str.slug('_').toString(), equals('hello_world'));
    });

    test('converts to ASCII', () {
      str = Stringable('café');
      expect(str.ascii().toString(), equals('cafe'));
    });

    test('checks if string starts with', () {
      expect(str.startsWith('hello'), isTrue);
      expect(str.startsWith('world'), isFalse);
    });

    test('checks if string ends with', () {
      expect(str.endsWith('world'), isTrue);
      expect(str.endsWith('hello'), isFalse);
    });

    test('finishes string with value', () {
      str = Stringable('hello');
      expect(str.finish('!').toString(), equals('hello!'));
      expect(str.finish('!').finish('!').toString(), equals('hello!'));
    });

    test('starts string with value', () {
      str = Stringable('world');
      expect(str.start('hello ').toString(), equals('hello world'));
      expect(str.start('hello ').start('hello ').toString(),
          equals('hello world'));
    });

    test('checks if string contains value', () {
      expect(str.contains('hello'), isTrue);
      expect(str.contains('goodbye'), isFalse);
    });

    test('gets string length', () {
      str = Stringable('hello');
      expect(str.getLength(), equals(5));
    });

    test('limits string length', () {
      expect(str.limit(5).toString(), equals('hello...'));
      expect(str.limit(5, '!').toString(), equals('hello!'));
    });

    test('converts to and from base64', () {
      final base64 = str.toBase64();
      expect(base64.fromBase64().toString(), equals('hello world'));
    });

    test('parses callback string', () {
      str = Stringable('Class@method');
      expect(str.parseCallback(), equals(['Class', 'method']));
      expect(str.parseCallback('#'), isNull);
    });

    test('masks string', () {
      expect(str.mask(5).toString(), equals('hello******'));
      str = Stringable('hello world');
      expect(str.mask(5, 3, '#').toString(), equals('hello###rld'));
    });

    test('pads string', () {
      str = Stringable('hello');
      var padded = str.padRight(6);
      expect(padded.toString(), equals('hello '));
      str = Stringable('hello');
      padded = str.padLeft(6);
      expect(padded.toString(), equals(' hello'));
      str = Stringable('hello');
      padded = str.padBoth(7);
      expect(padded.toString(), equals(' hello '));
    });

    test('splits string', () {
      expect(str.split(' '), equals(['hello', 'world']));
    });

    test('gets substring', () {
      expect(str.substr(0, 5).toString(), equals('hello'));
      str = Stringable('hello world');
      expect(str.substr(6).toString(), equals('world'));
    });

    test('replaces string', () {
      expect(str.replace('hello', 'hi').toString(), equals('hi world'));
      expect(str.replaceFirst('o', 'a').toString(), equals('hi warld'));
      expect(str.replaceLast('o', 'a').toString(), equals('hi warld'));
    });

    test('converts to boolean', () {
      expect(Stringable('true').toBoolean(), isTrue);
      expect(Stringable('1').toBoolean(), isTrue);
      expect(Stringable('yes').toBoolean(), isTrue);
      expect(Stringable('on').toBoolean(), isTrue);
      expect(Stringable('false').toBoolean(), isFalse);
      expect(Stringable('0').toBoolean(), isFalse);
      expect(Stringable('no').toBoolean(), isFalse);
      expect(Stringable('off').toBoolean(), isFalse);
    });

    test('trims string', () {
      str = Stringable('  hello  ');
      expect(str.trim().toString(), equals('hello'));
      expect(str.trimChars(' h').toString(), equals('ello'));
    });

    test('gets string between delimiters', () {
      str = Stringable('[hello] world');
      expect(str.between('[', ']').toString(), equals('hello'));
    });

    test('gets string before and after', () {
      expect(Stringable('hello world').before(' ').toString(), equals('hello'));
      expect(Stringable('hello world').after(' ').toString(), equals('world'));
      expect(Stringable('hello').beforeLast('o').toString(), equals('hell'));
      expect(
          Stringable('hello world').afterLast('o').toString(), equals('rld'));
    });

    test('checks if string matches pattern', () {
      expect(str.matches(RegExp(r'hello \w+')), isTrue);
      expect(str.matches(RegExp(r'goodbye \w+')), isFalse);
    });

    test('supports method chaining', () {
      final result = str.upper().replace(' ', '-').limit(7);
      expect(result.toString(), equals('HELLO-W...'));
    });

    test('supports tap for side effects', () {
      var sideEffect = '';
      str = Stringable('hello')
        ..tap((s) => sideEffect = s.toString())
        ..upper();

      expect(sideEffect, equals('hello'));
      expect(str.toString(), equals('HELLO'));
    });

    test('supports when/unless conditions', () {
      str = Stringable('hello');

      str.when(true, (self, _) => self.upper());
      expect(str.toString(), equals('HELLO'));

      str.unless(true, (self, _) => self.lower());
      expect(str.toString(), equals('HELLO'));

      str.unless(false, (self, _) => self.lower());
      expect(str.toString(), equals('hello'));
    });

    test('supports dump and dd', () {
      expect(() => str.dump(), returnsNormally);
      expect(() => str.dd(), throwsException);
    });
  });
}
