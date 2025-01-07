import 'package:test/test.dart';
import '../../lib/src/pdo_exception.dart';

void main() {
  group('PDOException', () {
    test('initializes with message only', () {
      final exception = PDOException('Database error');

      expect(exception.message, equals('Database error'));
      expect(exception.sqlState, isNull);
      expect(exception.code, isNull);
      expect(exception.statement, isNull);
      expect(exception.errorInfo, isNull);
    });

    test('initializes with all values', () {
      final exception = PDOException(
        'Invalid SQL syntax',
        sqlState: '42000',
        code: 1064,
        statement: 'SELECT * FORM users',
        errorInfo: {
          'driver_code': 1064,
          'driver_message': 'You have an error in your SQL syntax',
        },
      );

      expect(exception.message, equals('Invalid SQL syntax'));
      expect(exception.sqlState, equals('42000'));
      expect(exception.code, equals(1064));
      expect(exception.statement, equals('SELECT * FORM users'));
      expect(exception.errorInfo, isNotNull);
      expect(exception.errorInfo!['driver_code'], equals(1064));
    });

    test('provides formatted string representation', () {
      final exception = PDOException(
        'Connection failed',
        sqlState: 'HY000',
        code: 2002,
        statement: 'SELECT 1',
      );

      final str = exception.toString();
      expect(str, contains('PDOException: Connection failed'));
      expect(str, contains('SQLSTATE[HY000]'));
      expect(str, contains('Driver Error Code: 2002'));
      expect(str, contains('Statement: SELECT 1'));
    });

    test('handles partial information in string representation', () {
      // Only message
      final e1 = PDOException('Error 1');
      expect(e1.toString(), equals('PDOException: Error 1'));

      // Message and SQLSTATE
      final e2 = PDOException('Error 2', sqlState: '23000');
      expect(e2.toString(), contains('PDOException: Error 2'));
      expect(e2.toString(), contains('SQLSTATE[23000]'));
      expect(e2.toString(), isNot(contains('Driver Error Code')));

      // Message and error info
      final e3 = PDOException(
        'Error 3',
        errorInfo: {'detail': 'Additional info'},
      );
      expect(e3.toString(), contains('PDOException: Error 3'));
      expect(e3.toString(),
          contains('Driver Error Info: {detail: Additional info}'));
    });

    test('handles common SQLSTATE codes', () {
      // Feature not supported
      final e1 = PDOException(
        'Feature not supported',
        sqlState: '0A000',
      );
      expect(e1.toString(), contains('SQLSTATE[0A000]'));

      // Syntax error
      final e2 = PDOException(
        'Syntax error',
        sqlState: '42000',
      );
      expect(e2.toString(), contains('SQLSTATE[42000]'));

      // Constraint violation
      final e3 = PDOException(
        'Duplicate key',
        sqlState: '23000',
      );
      expect(e3.toString(), contains('SQLSTATE[23000]'));
    });

    test('handles empty or invalid values', () {
      // Empty message
      expect(
        () => PDOException(''),
        throwsA(isA<AssertionError>()),
        reason: 'Message should not be empty',
      );

      // Empty SQLSTATE
      expect(
        () => PDOException('Error', sqlState: ''),
        throwsA(isA<AssertionError>()),
        reason: 'SQLSTATE should not be empty if provided',
      );

      // Empty statement
      expect(
        () => PDOException('Error', statement: ''),
        throwsA(isA<AssertionError>()),
        reason: 'Statement should not be empty if provided',
      );

      // Empty error info
      final e = PDOException('Error', errorInfo: {});
      expect(e.toString(), isNot(contains('Driver Error Info')));
    });

    test('preserves error information for rethrowing', () {
      final original = PDOException(
        'Original error',
        sqlState: '42S02',
        code: 1146,
        statement: 'SELECT * FROM nonexistent_table',
      );

      try {
        throw original;
      } catch (e) {
        final caught = e as PDOException;
        expect(caught.message, equals(original.message));
        expect(caught.sqlState, equals(original.sqlState));
        expect(caught.code, equals(original.code));
        expect(caught.statement, equals(original.statement));
      }
    });
  });
}
