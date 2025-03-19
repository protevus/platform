import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('method tests', () {
    test('adds _method field for PUT requests', () {
      var html = render('''
        <form method="POST">
          <div method="PUT">
          </div>
        </form>
      ''');

      expect(html, contains('name="_method"'));
      expect(html, contains('value="PUT"'));
    });

    test('adds _method field for PATCH requests', () {
      var html = render('''
        <form method="POST">
          <div method="PATCH">
          </div>
        </form>
      ''');

      expect(html, contains('name="_method"'));
      expect(html, contains('value="PATCH"'));
    });

    test('adds _method field for DELETE requests', () {
      var html = render('''
        <form method="POST">
          <div method="DELETE">
          </div>
        </form>
      ''');

      expect(html, contains('name="_method"'));
      expect(html, contains('value="DELETE"'));
    });

    test('does not add _method field for GET requests', () {
      var html = render('''
        <form method="POST">
          <div method="GET">
          </div>
        </form>
      ''');

      expect(html, isNot(contains('name="_method"')));
    });

    test('does not add _method field for POST requests', () {
      var html = render('''
        <form method="POST">
          <div method="POST">
          </div>
        </form>
      ''');

      expect(html, isNot(contains('name="_method"')));
    });

    test('handles case-insensitive method names', () {
      var html = render('''
        <form method="POST">
          <div method="put">
          </div>
        </form>
      ''');

      expect(html, contains('name="_method"'));
      expect(html, contains('value="PUT"'));
    });

    test('only works inside form elements', () {
      var html = render('''
        <div method="PUT">
        </div>
      ''');

      expect(html, isNot(contains('name="_method"')));
    });

    test('works with csrf token', () {
      var html = render('''
        <form method="POST">
          <div method="PUT">
          </div>
        </form>
      ''', values: {'_token': 'test-token'});

      expect(html, contains('name="_method"'));
      expect(html, contains('value="PUT"'));
      expect(html, contains('name="_token"'));
      expect(html, contains('value="test-token"'));
    });
  });
}
