import 'package:platform_config/src/repository.dart';
import 'package:test/test.dart';

void main() {
  late Repository config;

  setUp(() {
    config = Repository({
      'app': {
        'name': 'My App',
        'debug': true,
      },
      'database': {
        'default': 'mysql',
        'connections': {
          'mysql': {
            'host': 'localhost',
            'port': 3306,
          },
        },
      },
      'numbers': [1, 2, 3, 4, 5],
    });
  });

  group('Repository', () {
    test('has() returns correct boolean for existing and non-existing keys',
        () {
      expect(config.has('app.name'), isTrue);
      expect(config.has('app.non_existent'), isFalse);
    });

    test('get() returns correct values for existing keys', () {
      expect(config.get('app.name'), equals('My App'));
      expect(config.get('database.connections.mysql.port'), equals(3306));
    });

    test('get() returns default value for non-existing keys', () {
      expect(config.get('non_existent', 'default'), equals('default'));
    });

    test('string() returns correct string value', () {
      expect(config.string('app.name'), equals('My App'));
    });

    test('string() throws ArgumentError for non-string values', () {
      expect(() => config.string('app.debug'), throwsArgumentError);
    });

    test('integer() returns correct integer value', () {
      expect(config.integer('database.connections.mysql.port'), equals(3306));
    });

    test('integer() throws ArgumentError for non-integer values', () {
      expect(() => config.integer('app.name'), throwsArgumentError);
    });

    test('boolean() returns correct boolean value', () {
      expect(config.boolean('app.debug'), isTrue);
    });

    test('boolean() throws ArgumentError for non-boolean values', () {
      expect(() => config.boolean('app.name'), throwsArgumentError);
    });

    test('array() returns correct list value', () {
      expect(config.array('numbers'), equals([1, 2, 3, 4, 5]));
    });

    test('array() throws ArgumentError for non-list values', () {
      expect(() => config.array('app.name'), throwsArgumentError);
    });

    test('set() correctly sets a new value', () {
      config.set('new.key', 'new value');
      expect(config.get('new.key'), equals('new value'));
    });

    test('prepend() correctly prepends a value to an array', () {
      config.prepend('numbers', 0);
      expect(config.array('numbers'), equals([0, 1, 2, 3, 4, 5]));
    });

    test('push() correctly appends a value to an array', () {
      config.push('numbers', 6);
      expect(config.array('numbers'), equals([1, 2, 3, 4, 5, 6]));
    });

    test('all() returns all config items', () {
      expect(
          config.all(),
          equals({
            'app': {
              'name': 'My App',
              'debug': true,
            },
            'database': {
              'default': 'mysql',
              'connections': {
                'mysql': {
                  'host': 'localhost',
                  'port': 3306,
                },
              },
            },
            'numbers': [1, 2, 3, 4, 5],
          }));
    });
  });
}
