import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('error tests', () {
    test('renders content when field has error', () {
      var html = render('''
        <div error="email">
          Invalid email format
        </div>
      ''', values: {
        'errors': {
          'email': ['Invalid email format']
        }
      });

      expect(html, contains('Invalid email format'));
    });

    test('renders first error message when multiple errors exist', () {
      var html = render('''
        <div error="email">
          {{ message }}
        </div>
      ''', values: {
        'errors': {
          'email': ['Invalid format', 'Email required']
        }
      });

      expect(html, contains('Invalid format'));
      expect(html, isNot(contains('Email required')));
    });

    test('does not render content when field has no errors', () {
      var html = render('''
        <div error="email">
          Invalid email format
        </div>
      ''', values: {
        'errors': {
          'name': ['Name is required']
        }
      });

      expect(html, isNot(contains('Invalid email format')));
    });

    test('does not render content when errors are not set', () {
      var html = render('''
        <div error="email">
          Invalid email format
        </div>
      ''');

      expect(html, isNot(contains('Invalid email format')));
    });

    test('handles nested field names with dot notation', () {
      var html = render('''
        <div error="user.email">
          Invalid email format
        </div>
      ''', values: {
        'errors': {
          'user.email': ['Invalid email format']
        }
      });

      expect(html, contains('Invalid email format'));
    });

    test('handles array field names with array notation', () {
      var html = render('''
        <div error="phones.0">
          Invalid phone number
        </div>
      ''', values: {
        'errors': {
          'phones.0': ['Invalid phone number']
        }
      });

      expect(html, contains('Invalid phone number'));
    });

    test('can be combined with other directives', () {
      var html = render('''
        <div error="email" class="alert">
          {{ message }}
        </div>
      ''', values: {
        'errors': {
          'email': ['Invalid format']
        }
      });

      expect(html, contains('class="alert"'));
      expect(html, contains('Invalid format'));
    });
  });
}
