import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('ValidatedInput', () {
    late ValidatedInput input;

    setUp(() {
      input = ValidatedInput({
        'name': 'John',
        'age': '25',
        'active': 'yes',
        'score': '9.5',
        'tags': ['one', 'two'],
        'meta': {'key': 'value'},
        'date': '2023-01-01T00:00:00Z',
      });
    });

    test('implements array access', () {
      expect(input['name'], equals('John'));
      input['name'] = 'Jane';
      expect(input['name'], equals('Jane'));
      input.remove('name');
      expect(input.containsKey('name'), isFalse);
    });

    test('converts to array', () {
      final array = input.toArray();
      expect(array, isA<Map<String, dynamic>>());
      expect(array['name'], equals('John'));
    });

    test('provides iterator', () {
      final entries = <MapEntry<String, dynamic>>[];
      final iterator = input.iterator;
      while (iterator.moveNext()) {
        entries.add(iterator.current);
      }
      expect(entries, hasLength(7));
      expect(entries.first.key, isA<String>());
      expect(entries.first.value, isA<dynamic>());
    });

    test('gets all data', () {
      final all = input.all();
      expect(all, equals(input.toArray()));
    });

    test('gets subset of data', () {
      final subset = input.only(['name', 'age']);
      expect(subset.keys, equals(['name', 'age'].toSet()));
      expect(subset['name'], equals('John'));
      expect(subset['age'], equals('25'));
    });

    test('gets data except specified keys', () {
      final filtered = input.except(['name', 'age']);
      expect(filtered.containsKey('name'), isFalse);
      expect(filtered.containsKey('age'), isFalse);
      expect(filtered['active'], equals('yes'));
    });

    test('merges new data', () {
      input.merge({'email': 'john@example.com'});
      expect(input['email'], equals('john@example.com'));
      expect(input['name'], equals('John'));
    });

    test('replaces all data', () {
      input.replace({'email': 'john@example.com'});
      expect(input['email'], equals('john@example.com'));
      expect(input.containsKey('name'), isFalse);
    });

    test('parses date values', () {
      final date = input.date('date');
      expect(date, isA<DateTime>());
      expect(date?.year, equals(2023));
      expect(date?.month, equals(1));
      expect(date?.day, equals(1));
    });

    test('parses boolean values', () {
      expect(input.boolean('active'), isTrue);
      input['active'] = '0';
      expect(input.boolean('active'), isFalse);
      input['active'] = true;
      expect(input.boolean('active'), isTrue);
    });

    test('parses integer values', () {
      expect(input.integer('age'), equals(25));
      input['age'] = 30;
      expect(input.integer('age'), equals(30));
      input['age'] = 'invalid';
      expect(input.integer('age'), isNull);
    });

    test('parses decimal values', () {
      expect(input.decimal('score'), equals(9.5));
      input['score'] = 9.8;
      expect(input.decimal('score'), equals(9.8));
      input['score'] = 'invalid';
      expect(input.decimal('score'), isNull);
    });

    test('gets string values', () {
      expect(input.string('name'), equals('John'));
      input['name'] = 123;
      expect(input.string('name'), equals('123'));
    });

    test('gets list values', () {
      expect(input.list<String>('tags'), equals(['one', 'two']));
      input['tags'] = [1, 2];
      expect(input.list<String>('tags'), equals(['1', '2']));
      input['tags'] = ['one', 2, true];
      expect(input.list<String>('tags'), equals(['one', '2', 'true']));
    });

    test('gets map values', () {
      expect(input.map<String>('meta'), equals({'key': 'value'}));
      input['meta'] = {'count': 1};
      expect(input.map<String>('meta'), equals({'count': '1'}));
      input['meta'] = {'key': 'value', 'count': 1, 'active': true};
      expect(input.map<String>('meta'),
          equals({'key': 'value', 'count': '1', 'active': 'true'}));
    });

    test('checks key presence', () {
      expect(input.has('name'), isTrue);
      expect(input.has('email'), isFalse);
      expect(input.missing('email'), isTrue);
      expect(input.missing('name'), isFalse);
    });

    test('checks filled values', () {
      expect(input.filled('name'), isTrue);
      input['empty'] = '';
      expect(input.filled('empty'), isFalse);
      input['list'] = [];
      expect(input.filled('list'), isFalse);
      input['map'] = {};
      expect(input.filled('map'), isFalse);
    });

    test('gets keys and values', () {
      expect(input.keys(), equals(input.toArray().keys.toSet()));
      expect(input.values(), equals(input.toArray().values.toList()));
    });
  });
}
