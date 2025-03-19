import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('env tests', () {
    test('renders content when environment matches', () {
      var html = render('''
        <div env="local">
          Local environment content
        </div>
      ''', values: {
        'app': {'env': 'local'}
      });

      expect(html, contains('Local environment content'));
    });

    test('renders content when any of multiple environments match', () {
      var html = render('''
        <div env="local,development">
          Development or local content
        </div>
      ''', values: {
        'app': {'env': 'development'}
      });

      expect(html, contains('Development or local content'));
    });

    test('does not render content when environment does not match', () {
      var html = render('''
        <div env="production">
          Production content
        </div>
      ''', values: {
        'app': {'env': 'local'}
      });

      expect(html, isNot(contains('Production content')));
    });

    test('does not render content when app env is not set', () {
      var html = render('''
        <div env="local">
          Local content
        </div>
      ''');

      expect(html, isNot(contains('Local content')));
    });

    test('handles nested env checks', () {
      var html = render('''
        <div env="local">
          <div>
            Outer local content
            <div env="local,development">
              Inner development content
            </div>
          </div>
        </div>
      ''', values: {
        'app': {'env': 'local'}
      });

      expect(html, contains('Outer local content'));
      expect(html, contains('Inner development content'));
    });

    test('can be combined with other directives', () {
      var html = render('''
        <div env="local">
          <div auth>
            Local and authenticated content
          </div>
        </div>
      ''', values: {
        'app': {'env': 'local'},
        'auth': true
      });

      expect(html, contains('Local and authenticated content'));
    });

    test('handles case-insensitive environment matching', () {
      var html = render('''
        <div env="LOCAL,DEVELOPMENT">
          Case insensitive content
        </div>
      ''', values: {
        'app': {'env': 'local'}
      });

      expect(html, contains('Case insensitive content'));
    });
  });
}
