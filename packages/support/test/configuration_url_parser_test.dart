import 'package:test/test.dart';
import 'package:platform_support/src/configuration_url_parser.dart';

void main() {
  group('ConfigurationUrlParser', () {
    test('parses simple URL', () {
      final result = ConfigurationUrlParser.parse('mysql://localhost');
      expect(result['driver'], equals('mysql'));
      expect(result['host'], equals('localhost'));
      expect(result['port'], isNull);
      expect(result['database'], isNull);
      expect(result['username'], isNull);
      expect(result['password'], isNull);
      expect(result['options'], isEmpty);
    });

    test('parses URL with port', () {
      final result = ConfigurationUrlParser.parse('mysql://localhost:3306');
      expect(result['driver'], equals('mysql'));
      expect(result['host'], equals('localhost'));
      expect(result['port'], equals(3306));
    });

    test('parses URL with credentials', () {
      final result =
          ConfigurationUrlParser.parse('mysql://user:pass@localhost');
      expect(result['username'], equals('user'));
      expect(result['password'], equals('pass'));
      expect(result['host'], equals('localhost'));
    });

    test('parses URL with database', () {
      final result = ConfigurationUrlParser.parse('mysql://localhost/mydb');
      expect(result['driver'], equals('mysql'));
      expect(result['host'], equals('localhost'));
      expect(result['database'], equals('mydb'));
    });

    test('parses URL with options', () {
      final result = ConfigurationUrlParser.parse(
          'mysql://localhost/mydb?charset=utf8&timezone=UTC');
      expect(result['options'], {
        'charset': 'utf8',
        'timezone': 'UTC',
      });
    });

    test('parses URL with array options', () {
      final result = ConfigurationUrlParser.parse(
          'mysql://localhost/mydb?servers[]=1&servers[]=2');
      expect(result['options']['servers'], equals(['1', '2']));
    });

    test('parses URL with boolean options', () {
      final result = ConfigurationUrlParser.parse(
          'mysql://localhost/mydb?ssl=true&verify=false&enabled=1&disabled=0');
      expect(result['options'], {
        'ssl': true,
        'verify': false,
        'enabled': true,
        'disabled': false,
      });
    });

    test('parses URL with numeric options', () {
      final result = ConfigurationUrlParser.parse(
          'mysql://localhost/mydb?timeout=30&retries=3');
      expect(result['options'], {
        'timeout': 30,
        'retries': 3,
      });
    });

    test('parses URL with special characters', () {
      final result = ConfigurationUrlParser.parse(
          'mysql://user%21:pass%40word@localhost/my%20db?name=John+Doe');
      expect(result['username'], equals('user!'));
      expect(result['password'], equals('pass@word'));
      expect(result['database'], equals('my db'));
      expect(result['options']['name'], equals('John Doe'));
    });

    test('parses URL with empty components', () {
      final result = ConfigurationUrlParser.parse('mysql://');
      expect(result['driver'], equals('mysql'));
      expect(result['host'], isNull);
      expect(result['database'], isNull);
    });

    test('parses empty URL', () {
      final result = ConfigurationUrlParser.parse('');
      expect(result['driver'], isNull);
      expect(result['host'], isNull);
      expect(result['database'], isNull);
    });

    test('formats simple configuration', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost'),
      );
    });

    test('formats configuration with port', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'port': 3306,
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost:3306'),
      );
    });

    test('formats configuration with credentials', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'username': 'user',
        'password': 'pass',
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://user:pass@localhost'),
      );
    });

    test('formats configuration with database', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'database': 'mydb',
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost/mydb'),
      );
    });

    test('formats configuration with options', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'database': 'mydb',
        'options': {
          'charset': 'utf8',
          'timezone': 'UTC',
        },
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost/mydb?charset=utf8&timezone=UTC'),
      );
    });

    test('formats configuration with array options', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'options': {
          'servers': ['1', '2'],
        },
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost?servers[]=1&servers[]=2'),
      );
    });

    test('formats configuration with boolean options', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'options': {
          'ssl': true,
          'verify': false,
        },
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://localhost?ssl=true&verify=false'),
      );
    });

    test('formats configuration with special characters', () {
      final config = {
        'driver': 'mysql',
        'host': 'localhost',
        'username': 'user!',
        'password': 'pass@word',
        'database': 'my db',
        'options': {
          'name': 'John Doe',
        },
      };
      expect(
        ConfigurationUrlParser.format(config),
        equals('mysql://user%21:pass%40word@localhost/my+db?name=John+Doe'),
      );
    });

    test('formats empty configuration', () {
      final config = <String, dynamic>{};
      expect(ConfigurationUrlParser.format(config), isEmpty);
    });

    test('round trip parsing and formatting', () {
      const url = 'mysql://user:pass@localhost:3306/mydb?charset=utf8&ssl=true';
      final parsed = ConfigurationUrlParser.parse(url);
      final formatted = ConfigurationUrlParser.format(parsed);
      expect(formatted, equals(url));
    });
  });
}
