import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Js', () {
    test('converts null to JavaScript', () {
      expect(Js(null).toJs(), equals('null'));
    });

    test('converts boolean to JavaScript', () {
      expect(Js(true).toJs(), equals('true'));
      expect(Js(false).toJs(), equals('false'));
    });

    test('converts numbers to JavaScript', () {
      expect(Js(42).toJs(), equals('42'));
      expect(Js(3.14).toJs(), equals('3.14'));
    });

    test('converts strings to JavaScript', () {
      expect(Js('hello').toJs(), equals("'hello'"));
      expect(Js("it's").toJs(), equals("'it\\'s'"));
    });

    test('escapes special characters', () {
      expect(Js('line\nbreak').toJs(), equals("'line\\nbreak'"));
      expect(Js('tab\there').toJs(), equals("'tab\\there'"));
      expect(Js('back\\slash').toJs(), equals("'back\\\\slash'"));
    });

    test('implements Arrayable contract', () {
      expect(Js('hello').toArray(), equals({'value': 'hello'}));
      expect(Js(42).toArray(), equals({'value': 42}));
      expect(Js(true).toArray(), equals({'value': true}));
      expect(Js(null).toArray(), equals({}));
    });

    test('implements Jsonable contract', () {
      expect(Js('hello').toJson(), equals('{"value":"hello"}'));
      expect(Js(42).toJson(), equals('{"value":42}'));
      expect(Js(true).toJson(), equals('{"value":true}'));
      expect(Js(null).toJson(), equals('{}'));
    });

    test('implements Htmlable contract', () {
      expect(Js('hello').toHtml(), equals("<script>'hello'</script>"));
      expect(Js(42).toHtml(), equals("<script>42</script>"));
      expect(Js(true).toHtml(), equals("<script>true</script>"));
      expect(Js(null).toHtml(), equals("<script>null</script>"));
    });

    test('extends Stringable functionality', () {
      final js = Js('hello world');
      expect(js.upper().toString(), equals("'HELLO WORLD'"));
      expect(js.camel().toString(), equals("'helloWorld'"));
      expect(js.snake().toString(), equals("'hello_world'"));
    });

    test('provides static from factory method', () {
      final js = Js.from('hello');
      expect(js, isA<Js>());
      expect(js.toJs(), equals("'hello'"));
    });

    test('works with string interpolation', () {
      final js = Js('hello');
      expect('Value: $js', equals("Value: 'hello'"));
    });
  });
}
