import 'package:test/test.dart';

void main() {
  group('Dummy Test', () {
    test('Always passes', () {
      expect(true, isTrue);
    });

    test('Basic arithmetic', () {
      expect(2 + 2, equals(4));
    });

    test('String manipulation', () {
      String testString = 'Protevus Platform';
      expect(testString.contains('Platform'), isTrue);
      expect(testString.toLowerCase(), equals('protevus platform'));
    });
  });
}
