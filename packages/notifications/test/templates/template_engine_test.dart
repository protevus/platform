import 'package:test/test.dart';
import 'package:platform_notifications/notifications.dart';

void main() {
  group('TemplateEngine', () {
    setUp(() {
      TemplateEngine.clearCache();
    });

    test('renders simple template', () {
      final result = TemplateEngine.render(
        'Hello {{name}}!',
        {'name': 'John'},
      );
      expect(result, equals('Hello John!'));
    });

    test('renders nested template data', () {
      final result = TemplateEngine.render(
        'Hello {{user.name}}!',
        {
          'user': {'name': 'John'}
        },
      );
      expect(result, equals('Hello John!'));
    });

    test('escapes HTML by default', () {
      final result = TemplateEngine.render(
        '{{content}}',
        {'content': '<script>alert("xss")</script>'},
      );
      expect(result,
          equals('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'));
    });

    test('can disable HTML escaping', () {
      final result = TemplateEngine.render(
        '{{content}}',
        {'content': '<b>bold</b>'},
        htmlEscape: false,
      );
      expect(result, equals('<b>bold</b>'));
    });

    test('caches templates', () {
      // First render should cache the template
      final template = 'Hello {{name}}!';

      // Render multiple times with different data
      final result1 = TemplateEngine.render(template, {'name': 'John'});
      final result2 = TemplateEngine.render(template, {'name': 'Jane'});

      // Results should be different despite using same template
      expect(result1, equals('Hello John!'));
      expect(result2, equals('Hello Jane!'));

      // Clear cache and verify template still works
      TemplateEngine.clearCache();
      final result3 = TemplateEngine.render(template, {'name': 'Bob'});
      expect(result3, equals('Hello Bob!'));
    });
  });
}
