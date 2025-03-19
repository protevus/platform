import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('auth tests', () {
    test('renders content when user is authenticated', () {
      var html = render('''
        <div auth>
          Welcome back!
        </div>
      ''', values: {'auth': true});

      expect(html, contains('Welcome back!'));
    });

    test('does not render content when user is not authenticated', () {
      var html = render('''
        <div auth>
          Welcome back!
        </div>
      ''', values: {'auth': false});

      expect(html, isNot(contains('Welcome back!')));
    });

    test('does not render content when auth value is not set', () {
      var html = render('''
        <div auth>
          Welcome back!
        </div>
      ''');

      expect(html, isNot(contains('Welcome back!')));
    });

    test('handles auth with specific guard', () {
      var html = render('''
        <div auth="admin">
          Admin panel
        </div>
      ''', values: {
        'auth': {'admin': true, 'user': false}
      });

      expect(html, contains('Admin panel'));
    });

    test('does not render content when specific guard is not authenticated',
        () {
      var html = render('''
        <div auth="admin">
          Admin panel
        </div>
      ''', values: {
        'auth': {'admin': false, 'user': true}
      });

      expect(html, isNot(contains('Admin panel')));
    });

    test('handles nested auth checks', () {
      var html = render('''
        <div auth>
          <div auth="admin">
            Admin content
          </div>
          Regular user content
        </div>
      ''', values: {
        'auth': {'admin': true, 'default': true}
      });

      expect(html, contains('Admin content'));
      expect(html, contains('Regular user content'));
    });
  });
}
