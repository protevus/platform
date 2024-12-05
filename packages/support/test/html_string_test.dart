import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';

void main() {
  group('HtmlString', () {
    test('creates instance from string', () {
      final html = HtmlString('<p>Hello</p>');
      expect(html.toString(), equals('<p>Hello</p>'));
    });

    test('creates instance using from factory', () {
      final html = HtmlString.from('<p>Hello</p>');
      expect(html.toString(), equals('<p>Hello</p>'));
    });

    test('creates empty instance', () {
      expect(HtmlString.empty.toString(), equals(''));
    });

    test('implements Htmlable interface', () {
      final html = HtmlString('<p>Hello</p>');
      expect(html.toHtml(), equals('<p>Hello</p>'));
    });

    test('preserves raw HTML', () {
      final html = HtmlString('<p>Hello <strong>World</strong>!</p>');
      expect(html.toString(), equals('<p>Hello <strong>World</strong>!</p>'));
    });

    test('compares equal instances', () {
      final html1 = HtmlString('<p>Hello</p>');
      final html2 = HtmlString('<p>Hello</p>');
      final html3 = HtmlString('<p>World</p>');

      expect(html1, equals(html2));
      expect(html1, isNot(equals(html3)));
    });

    test('provides consistent hash codes', () {
      final html1 = HtmlString('<p>Hello</p>');
      final html2 = HtmlString('<p>Hello</p>');
      final html3 = HtmlString('<p>World</p>');

      expect(html1.hashCode, equals(html2.hashCode));
      expect(html1.hashCode, isNot(equals(html3.hashCode)));
    });

    test('works with string interpolation', () {
      final html = HtmlString('<strong>World</strong>');
      final result = 'Hello, $html!';
      expect(result, equals('Hello, <strong>World</strong>!'));
    });
  });
}
