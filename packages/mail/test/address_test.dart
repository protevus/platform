import 'package:test/test.dart';
import 'package:illuminate_mail/mail.dart';

void main() {
  group('Address', () {
    test('creates with email only', () {
      final address = Address('test@example.com');
      expect(address.email, equals('test@example.com'));
      expect(address.name, isNull);
      expect(address.toString(), equals('test@example.com'));
    });

    test('creates with email and name', () {
      final address = Address('test@example.com', 'Test User');
      expect(address.email, equals('test@example.com'));
      expect(address.name, equals('Test User'));
      expect(address.toString(), equals('Test User <test@example.com>'));
    });

    test('parses from string with email only', () {
      final address = Address.parse('test@example.com');
      expect(address.email, equals('test@example.com'));
      expect(address.name, isNull);
    });

    test('parses from string with name and email', () {
      final address = Address.parse('Test User <test@example.com>');
      expect(address.email, equals('test@example.com'));
      expect(address.name, equals('Test User'));
    });

    test('parses from string with quoted name', () {
      final address = Address.parse('"Test, User" <test@example.com>');
      expect(address.email, equals('test@example.com'));
      expect(address.name, equals('Test, User'));
    });

    test('validates email format', () {
      expect(() => Address('invalid'), throwsArgumentError);
      expect(() => Address('invalid@'), throwsArgumentError);
      expect(() => Address('@invalid'), throwsArgumentError);
      expect(() => Address('invalid@.com'), throwsArgumentError);
    });

    test('compares addresses correctly', () {
      final address1 = Address('test@example.com', 'Test User');
      final address2 = Address('test@example.com', 'Test User');
      final address3 = Address('other@example.com', 'Test User');
      final address4 = Address('test@example.com', 'Other User');

      expect(address1, equals(address2));
      expect(address1.hashCode, equals(address2.hashCode));
      expect(address1, isNot(equals(address3)));
      expect(address1, isNot(equals(address4)));
    });

    test('handles special characters in name', () {
      final address = Address('test@example.com', 'Test 😀 User');
      expect(address.toString(), equals('Test 😀 User <test@example.com>'));
    });

    test('handles empty name as email only', () {
      final address = Address('test@example.com', '');
      expect(address.toString(), equals('test@example.com'));
    });

    test('handles whitespace in name', () {
      final address = Address('test@example.com', '  Test User  ');
      expect(address.name, equals('Test User'));
      expect(address.toString(), equals('Test User <test@example.com>'));
    });
  });
}
