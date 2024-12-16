import 'package:test/test.dart';
import 'package:platform_collections/collections.dart';

void main() {
  group('Helper Functions', () {
    group('collect()', () {
      test('creates collection from iterable', () {
        final collection = collect([1, 2, 3]);
        expect(collection, isA<Collection<int>>());
        expect(collection, equals([1, 2, 3]));
      });

      test('creates empty collection when null', () {
        final collection = collect<int>(null);
        expect(collection, isA<Collection<int>>());
        expect(collection, isEmpty);
      });
    });

    group('dataGet()', () {
      test('gets simple key', () {
        final data = <String, dynamic>{'name': 'John'};
        expect(dataGet(data, 'name'), equals('John'));
      });

      test('gets nested key', () {
        final data = <String, dynamic>{
          'user': <String, dynamic>{'name': 'John'}
        };
        expect(dataGet(data, 'user.name'), equals('John'));
      });

      test('gets array index', () {
        final data = <String, dynamic>{
          'users': <String>['John', 'Jane']
        };
        expect(dataGet(data, 'users.0'), equals('John'));
      });

      test('gets wildcard values', () {
        final data = <String, dynamic>{
          'users': <Map<String, dynamic>>[
            {'name': 'John'},
            {'name': 'Jane'}
          ]
        };
        expect(dataGet(data, 'users.*.name'), equals(['John', 'Jane']));
      });

      test('returns default value when key not found', () {
        final data = <String, dynamic>{'name': 'John'};
        expect(dataGet(data, 'age', 25), equals(25));
      });

      test('handles special segments', () {
        final data = <String, dynamic>{
          'users': <Map<String, dynamic>>[
            {'name': 'John'},
            {'name': 'Jane'}
          ]
        };
        expect(dataGet(data, 'users.{first}.name'), equals('John'));
        expect(dataGet(data, 'users.{last}.name'), equals('Jane'));
      });
    });

    group('dataSet()', () {
      test('sets simple key', () {
        final data = <String, dynamic>{};
        dataSet(data, 'name', 'John');
        expect(data['name'], equals('John'));
      });

      test('sets nested key', () {
        final data = <String, dynamic>{};
        dataSet(data, 'user.name', 'John');
        expect(data['user']!['name'], equals('John'));
      });

      test('sets array index', () {
        final data = <String, dynamic>{};
        dataSet(data, 'users.0', 'John');
        expect((data['users'] as List)[0], equals('John'));
      });

      test('sets wildcard values', () {
        final data = <String, dynamic>{
          'users': <Map<String, dynamic>>[
            <String, dynamic>{'name': ''},
            <String, dynamic>{'name': ''}
          ]
        };
        dataSet(data, 'users.*.name', 'John');
        expect((data['users'] as List)[0]['name'], equals('John'));
        expect((data['users'] as List)[1]['name'], equals('John'));
      });

      test('respects overwrite flag', () {
        final data = <String, dynamic>{'name': 'John'};
        dataSet(data, 'name', 'Jane', overwrite: false);
        expect(data['name'], equals('John'));
      });
    });

    group('dataFill()', () {
      test('fills missing values', () {
        final data = <String, dynamic>{
          'user': <String, dynamic>{'name': 'John'}
        };
        dataFill(data, 'user.age', 25);
        expect(data['user']!['age'], equals(25));
      });

      test('does not overwrite existing values', () {
        final data = <String, dynamic>{
          'user': <String, dynamic>{'name': 'John', 'age': 30}
        };
        dataFill(data, 'user.age', 25);
        expect(data['user']!['age'], equals(30));
      });
    });

    group('dataForget()', () {
      test('removes simple key', () {
        final data = <String, dynamic>{'name': 'John'};
        dataForget(data, 'name');
        expect(data.containsKey('name'), isFalse);
      });

      test('removes nested key', () {
        final data = <String, dynamic>{
          'user': <String, dynamic>{'name': 'John', 'age': 30}
        };
        dataForget(data, 'user.age');
        expect((data['user'] as Map).containsKey('age'), isFalse);
      });

      test('removes array index', () {
        final data = <String, dynamic>{
          'users': <String>['John', 'Jane']
        };
        dataForget(data, 'users.0');
        expect(data['users'], equals(['Jane']));
      });

      test('removes wildcard values', () {
        final data = <String, dynamic>{
          'users': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'John'},
            <String, dynamic>{'name': 'Jane'}
          ]
        };
        dataForget(data, 'users.*.name');
        expect((data['users'] as List)[0], equals(<String, dynamic>{}));
        expect((data['users'] as List)[1], equals(<String, dynamic>{}));
      });
    });

    group('head()', () {
      test('returns first element', () {
        expect(head([1, 2, 3]), equals(1));
      });

      test('returns null for empty list', () {
        expect(head([]), isNull);
      });
    });

    group('last()', () {
      test('returns last element', () {
        expect(last([1, 2, 3]), equals(3));
      });

      test('returns null for empty list', () {
        expect(last([]), isNull);
      });
    });

    group('value()', () {
      test('returns value from factory', () {
        expect(value(() => 42), equals(42));
      });

      test('evaluates factory each time', () {
        var counter = 0;
        final factory = () {
          counter++;
          return counter;
        };
        expect(value(factory), equals(1));
        expect(value(factory), equals(2));
      });
    });
  });
}
