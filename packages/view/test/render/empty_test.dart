import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('empty tests', () {
    test('renders content when value is null', () {
      var html = render('''
        <div empty="user">
          User is empty
        </div>
      ''', values: {'user': null});

      expect(html, contains('User is empty'));
    });

    test('renders content when value is empty string', () {
      var html = render('''
        <div empty="message">
          Message is empty
        </div>
      ''', values: {'message': ''});

      expect(html, contains('Message is empty'));
    });

    test('renders content when value is empty list', () {
      var html = render('''
        <div empty="items">
          Items is empty
        </div>
      ''', values: {'items': []});

      expect(html, contains('Items is empty'));
    });

    test('renders content when value is zero', () {
      var html = render('''
        <div empty="count">
          Count is empty
        </div>
      ''', values: {'count': 0});

      expect(html, contains('Count is empty'));
    });

    test('renders content when value is false', () {
      var html = render('''
        <div empty="active">
          Active is empty
        </div>
      ''', values: {'active': false});

      expect(html, contains('Active is empty'));
    });

    test('does not render content when value is non-empty string', () {
      var html = render('''
        <div empty="message">
          Message is empty
        </div>
      ''', values: {'message': 'Hello'});

      expect(html, isNot(contains('Message is empty')));
    });

    test('does not render content when value is non-empty list', () {
      var html = render('''
        <div empty="items">
          Items is empty
        </div>
      ''', values: {
        'items': [1, 2, 3]
      });

      expect(html, isNot(contains('Items is empty')));
    });

    test('does not render content when value is non-zero', () {
      var html = render('''
        <div empty="count">
          Count is empty
        </div>
      ''', values: {'count': 42});

      expect(html, isNot(contains('Count is empty')));
    });

    test('does not render content when value is true', () {
      var html = render('''
        <div empty="active">
          Active is empty
        </div>
      ''', values: {'active': true});

      expect(html, isNot(contains('Active is empty')));
    });

    test('handles nested properties', () {
      var html = render('''
        <div empty="user.items">
          User items is empty
        </div>
      ''', values: {
        'user': {'items': []}
      });

      expect(html, contains('User items is empty'));
    });

    test('handles undefined values', () {
      var html = render('''
        <div empty="unknown">
          Unknown is empty
        </div>
      ''');

      expect(html, contains('Unknown is empty'));
    });
  });
}
