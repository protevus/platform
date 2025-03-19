import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('guest tests', () {
    test('renders content when user is not authenticated', () {
      var html = render('''
        <div guest>
          Please log in
        </div>
      ''', values: {'auth': false});

      expect(html, contains('Please log in'));
    });

    test('renders content when auth value is not set', () {
      var html = render('''
        <div guest>
          Please log in
        </div>
      ''');

      expect(html, contains('Please log in'));
    });

    test('does not render content when user is authenticated', () {
      var html = render('''
        <div guest>
          Please log in
        </div>
      ''', values: {'auth': true});

      expect(html, isNot(contains('Please log in')));
    });

    test('handles guest with specific guard', () {
      var html = render('''
        <div guest="admin">
          Not an admin
        </div>
      ''', values: {
        'auth': {'admin': false, 'user': true}
      });

      expect(html, contains('Not an admin'));
    });

    test('does not render content when specific guard is authenticated', () {
      var html = render('''
        <div guest="admin">
          Not an admin
        </div>
      ''', values: {
        'auth': {'admin': true, 'user': false}
      });

      expect(html, isNot(contains('Not an admin')));
    });

    test('handles nested guest checks', () {
      var html = render('''
        <div guest>
          <div guest="admin">
            Not an admin
          </div>
          Not logged in
        </div>
      ''', values: {
        'auth': {'admin': false, 'default': false}
      });

      expect(html, contains('Not an admin'));
      expect(html, contains('Not logged in'));
    });
  });
}
