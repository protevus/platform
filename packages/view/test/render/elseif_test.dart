import 'package:test/test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('elseif tests', () {
    test('renders if block when first condition is true', () {
      var html = render('''
        <div if="true">
          First condition
        </div>
        <div else-if="true">
          Second condition
        </div>
        <div else>
          Else condition
        </div>
      ''');

      expect(html, contains('First condition'));
      expect(html, isNot(contains('Second condition')));
      expect(html, isNot(contains('Else condition')));
    });

    test(
        'renders else-if block when first condition is false and second is true',
        () {
      var html = render('''
        <div>
          <div if="false">
            First condition
          </div>
          <div else-if="true">
            Second condition
          </div>
          <div else>
            Else condition
          </div>
        </div>
      ''');

      expect(html, isNot(contains('First condition')));
      expect(html, contains('Second condition'));
      expect(html, isNot(contains('Else condition')));
    });

    test('renders else block when all conditions are false', () {
      var html = render('''
        <div>
          <div if="false">
            First condition
          </div>
          <div else-if="false">
            Second condition
          </div>
          <div else>
            Else condition
          </div>
        </div>
      ''');

      expect(html, isNot(contains('First condition')));
      expect(html, isNot(contains('Second condition')));
      expect(html, contains('Else condition'));
    });

    test('handles multiple else-if conditions', () {
      var html = render('''
        <div>
          <div if="false">
            First condition
          </div>
          <div else-if="false">
            Second condition
          </div>
          <div else-if="true">
            Third condition
          </div>
          <div else-if="true">
            Fourth condition
          </div>
          <div else>
            Else condition
          </div>
        </div>
      ''');

      expect(html, isNot(contains('First condition')));
      expect(html, isNot(contains('Second condition')));
      expect(html, contains('Third condition'));
      expect(html, isNot(contains('Fourth condition')));
      expect(html, isNot(contains('Else condition')));
    });

    test('handles dynamic conditions from scope', () {
      var html = render('''
        <div>
          <div if="firstValue">
            First condition
          </div>
          <div else-if="secondValue">
            Second condition
          </div>
          <div else>
            Else condition
          </div>
        </div>
      ''', values: {'firstValue': false, 'secondValue': true});

      expect(html, isNot(contains('First condition')));
      expect(html, contains('Second condition'));
      expect(html, isNot(contains('Else condition')));
    });
  });
}
