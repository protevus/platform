import 'dart:convert';
import 'package:test/test.dart';
import 'package:platform_support/platform_support.dart';
import 'package:platform_contracts/contracts.dart';

class TestClass with InteractsWithData implements Arrayable, Jsonable {
  @override
  Map<String, dynamic> toArray() {
    return getData();
  }

  @override
  String toJson([Map<String, dynamic>? options]) {
    return jsonEncode(toArray());
  }
}

void main() {
  late TestClass instance;

  setUp(() {
    instance = TestClass();
  });

  group('InteractsWithData', () {
    test('can get and set data using dot notation', () {
      instance.set('user.name', 'John');
      instance.set('user.email', 'john@example.com');

      expect(instance.get('user.name'), equals('John'));
      expect(instance.get('user.email'), equals('john@example.com'));
    });

    test('can check if data exists', () {
      instance.set('user.name', 'John');

      expect(instance.has('user.name'), isTrue);
      expect(instance.has('user.email'), isFalse);
    });

    test('can remove data', () {
      instance.set('user.name', 'John');
      instance.set('user.email', 'john@example.com');

      instance.remove('user.name');

      expect(instance.has('user.name'), isFalse);
      expect(instance.has('user.email'), isTrue);
    });

    test('can merge data', () {
      instance.set('user.name', 'John');

      instance.merge({
        'user': {
          'email': 'john@example.com',
          'age': 30,
        }
      });

      expect(instance.get('user.name'), equals('John'));
      expect(instance.get('user.email'), equals('john@example.com'));
      expect(instance.get('user.age'), equals(30));
    });

    test('can get all data', () {
      final data = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
        }
      };

      instance.merge(data);

      expect(instance.getData(), equals(data));
    });

    test('implements Arrayable correctly', () {
      final data = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
        }
      };

      instance.merge(data);

      expect(instance.toArray(), equals(data));
    });

    test('implements Jsonable correctly', () {
      final data = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
        }
      };

      instance.merge(data);

      expect(instance.toJson(), equals(jsonEncode(data)));
    });

    test('returns default value when getting non-existent data', () {
      expect(instance.get('user.name', 'default'), equals('default'));
    });

    test('handles nested data correctly', () {
      instance.set('user.profile.address.street', '123 Main St');
      instance.set('user.profile.address.city', 'New York');

      expect(
          instance.get('user.profile.address.street'), equals('123 Main St'));
      expect(instance.get('user.profile.address.city'), equals('New York'));
    });

    test('handles array-like data correctly', () {
      instance.set('users.0.name', 'John');
      instance.set('users.1.name', 'Jane');

      expect(instance.get('users.0.name'), equals('John'));
      expect(instance.get('users.1.name'), equals('Jane'));
    });
  });
}
