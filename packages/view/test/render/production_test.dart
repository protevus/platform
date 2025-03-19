import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('production tests', () {
    test('renders content when in production mode', () {
      var html = render('''
        <div production>
          Production mode content
        </div>
      ''', values: {
        'app': {'env': 'production'}
      });

      expect(html, contains('Production mode content'));
    });

    test('does not render content when not in production mode', () {
      var html = render('''
        <div production>
          Production mode content
        </div>
      ''', values: {
        'app': {'env': 'local'}
      });

      expect(html, isNot(contains('Production mode content')));
    });

    test('does not render content when app env is not set', () {
      var html = render('''
        <div production>
          Production mode content
        </div>
      ''');

      expect(html, isNot(contains('Production mode content')));
    });

    test('handles nested production checks', () {
      var html = render('''
        <div production>
          <div>
            Outer production content
            <div production>
              Inner production content
            </div>
          </div>
        </div>
      ''', values: {
        'app': {'env': 'production'}
      });

      expect(html, contains('Outer production content'));
      expect(html, contains('Inner production content'));
    });

    test('can be combined with other directives', () {
      var html = render('''
        <div production>
          <div auth>
            Production and authenticated content
          </div>
        </div>
      ''', values: {
        'app': {'env': 'production'},
        'auth': true
      });

      expect(html, contains('Production and authenticated content'));
    });
  });
}
