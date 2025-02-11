import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('NamespacedItemResolver', () {
    late NamespacedItemResolver resolver;
    late Map<String, dynamic> data;

    setUp(() {
      resolver = const NamespacedItemResolver();
      data = {
        'database': {
          'connections': {
            'mysql': {
              'host': 'localhost',
              'port': 3306,
              'settings': ['cache', 'pool'],
            },
            'pgsql': {
              'host': 'localhost',
              'port': 5432,
            },
          },
          'redis': {
            'cache': {
              'host': '127.0.0.1',
              'port': 6379,
            },
          },
        },
        'array': ['first', 'second', 'third'],
        'nested': {
          'array': [
            'one',
            'two',
            {'key': 'value'}
          ],
        },
      };
    });

    test('parses key into segments', () {
      expect(resolver.parseKey(''), isEmpty);
      expect(resolver.parseKey('database'), equals(['database']));
      expect(
        resolver.parseKey('database.connections.mysql'),
        equals(['database', 'connections', 'mysql']),
      );
    });

    test('gets value using dot notation', () {
      expect(resolver.get(data, ''), equals(data));
      expect(resolver.get(data, 'database.connections.mysql.host'),
          equals('localhost'));
      expect(
          resolver.get(data, 'database.connections.mysql.port'), equals(3306));
      expect(resolver.get<String>(data, 'missing'), isNull);
      expect(resolver.get(data, 'missing', 'default'), equals('default'));
    });

    test('gets array values using dot notation', () {
      expect(resolver.get(data, 'array.0'), equals('first'));
      expect(resolver.get(data, 'array.1'), equals('second'));
      expect(resolver.get(data, 'nested.array.2.key'), equals('value'));
    });

    test('sets value using dot notation', () {
      resolver.set(data, 'new.key.path', 'value');
      expect(data['new']['key']['path'], equals('value'));

      resolver.set(data, 'database.connections.mysql.host', '127.0.0.1');
      expect(data['database']['connections']['mysql']['host'],
          equals('127.0.0.1'));
    });

    test('sets array values using dot notation', () {
      resolver.set(data, 'array.1', 'updated');
      expect(data['array'][1], equals('updated'));

      resolver.set(data, 'new.array.0', 'first');
      expect(data['new']['array'][0], equals('first'));
    });

    test('removes value using dot notation', () {
      resolver.remove(data, 'database.connections.mysql.host');
      expect(data['database']['connections']['mysql'].containsKey('host'),
          isFalse);

      resolver.remove(data, 'array.1');
      expect(data['array'].length, equals(2));
      expect(data['array'][1], equals('third'));
    });

    test('checks existence using dot notation', () {
      expect(resolver.has(data, 'database.connections.mysql.host'), isTrue);
      expect(resolver.has(data, 'database.connections.missing'), isFalse);
      expect(resolver.has(data, ''), isFalse);
      expect(
          resolver.has(data, [
            'database.connections.mysql.host',
            'database.connections.mysql.port'
          ]),
          isTrue);
      expect(
          resolver.has(data, [
            'database.connections.mysql.host',
            'database.connections.mysql.missing'
          ]),
          isFalse);
    });

    test('handles invalid array indices', () {
      expect(resolver.get(data, 'array.999'), isNull);
      expect(resolver.get(data, 'array.-1'), isNull);
      expect(resolver.get(data, 'array.invalid'), isNull);
    });

    test('handles null values in path', () {
      data['nulled'] = null;
      expect(resolver.get(data, 'nulled.anything'), isNull);
      expect(resolver.has(data, 'nulled.anything'), isFalse);
    });

    test('uses custom separator', () {
      final customResolver = NamespacedItemResolver('/');
      expect(
        customResolver.parseKey('database/connections/mysql'),
        equals(['database', 'connections', 'mysql']),
      );
      expect(
        customResolver.get(data, 'database/connections/mysql/host'),
        equals('localhost'),
      );
    });

    test('handles type safety', () {
      expect(resolver.get<String>(data, 'database.connections.mysql.host'),
          equals('localhost'));
      expect(resolver.get<int>(data, 'database.connections.mysql.port'),
          equals(3306));
      expect(
          resolver.get<List<String>>(
              data, 'database.connections.mysql.settings'),
          equals(['cache', 'pool']));
      expect(
          resolver.get<Map<String, dynamic>>(
              data, 'database.connections.mysql'),
          isA<Map<String, dynamic>>());
    });

    test('sets nested arrays correctly', () {
      resolver.set(data, 'new.nested.array.0', 'value');
      print('After first set: $data');

      resolver.set(data, 'new.nested.array.1.key', 'nested');
      print('After second set: $data');

      expect(data['new']['nested']['array'][0], equals('value'));
      expect(data['new']['nested']['array'][1]['key'], equals('nested'));
    });

    test('handles empty segments', () {
      expect(resolver.get(data, '..'), isNull);
      resolver.set(data, '..', 'value'); // Should not throw
      resolver.remove(data, '..'); // Should not throw
      expect(resolver.has(data, '..'), isFalse);
    });
  });
}
