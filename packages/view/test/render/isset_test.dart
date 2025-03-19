import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('isset tests', () {
    test('renders content when variable is set', () {
      var html = render('''
        <div isset="user">
          User is set
        </div>
      ''', values: {'user': 'John'});

      expect(html, contains('User is set'));
    });

    test('does not render content when variable is not set', () {
      var html = render('''
        <div isset="user">
          User is set
        </div>
      ''');

      expect(html, isNot(contains('User is set')));
    });

    test('does not render content when variable is null', () {
      var html = render('''
        <div isset="user">
          User is set
        </div>
      ''', values: {'user': null});

      expect(html, isNot(contains('User is set')));
    });

    test('handles nested variables', () {
      var html = render('''
        <div isset="user.name">
          User name is set
        </div>
      ''', values: {
        'user': {'name': 'John'}
      });

      expect(html, contains('User name is set'));
    });

    test('handles multiple variables with and operator', () {
      var html = render('''
        <div isset="user && profile">
          Both user and profile are set
        </div>
      ''', values: {
        'user': 'John',
        'profile': {'age': 25}
      });

      expect(html, contains('Both user and profile are set'));
    });
  });
}
