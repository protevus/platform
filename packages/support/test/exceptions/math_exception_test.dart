import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:platform_support/src/exceptions/math_exception.dart';

void main() {
  group('MathException', () {
    test('creates basic exception with default message', () {
      final exception = MathException('add', [1, 2]);
      expect(exception.operation, equals('add'));
      expect(exception.operands, equals([1, 2]));
      expect(exception.message,
          equals('Math operation "add" failed with operands: 1, 2'));
      expect(exception.code, isNull);
      expect(exception.previous, isNull);
    });

    test('creates exception with custom message', () {
      final exception = MathException('add', [1, 2], 'Custom error');
      expect(exception.message, equals('Custom error'));
    });

    test('creates exception with code and previous exception', () {
      final previous = Exception('Previous error');
      final exception =
          MathException('add', [1, 2], 'Error', 'error_code', previous);
      expect(exception.code, equals('error_code'));
      expect(exception.previous, equals(previous));
    });

    test('creates division by zero exception', () {
      final exception = MathException.divisionByZero(10);
      expect(exception.operation, equals('division'));
      expect(exception.operands, equals([10, 0]));
      expect(exception.message, equals('Division by zero'));
      expect(exception.code, equals('division_by_zero'));
    });

    test('creates overflow exception', () {
      final exception =
          MathException.overflow('multiply', [double.maxFinite, 2]);
      expect(exception.operation, equals('multiply'));
      expect(exception.operands, equals([double.maxFinite, 2]));
      expect(exception.message, equals('Operation resulted in overflow'));
      expect(exception.code, equals('overflow'));
    });

    test('creates underflow exception', () {
      final exception =
          MathException.underflow('divide', [1, double.maxFinite]);
      expect(exception.operation, equals('divide'));
      expect(exception.operands, equals([1, double.maxFinite]));
      expect(exception.message, equals('Operation resulted in underflow'));
      expect(exception.code, equals('underflow'));
    });

    test('creates invalid operand exception', () {
      final exception = MathException.invalidOperand('sqrt', [-1]);
      expect(exception.operation, equals('sqrt'));
      expect(exception.operands, equals([-1]));
      expect(exception.message, equals('Invalid operand for operation'));
      expect(exception.code, equals('invalid_operand'));
    });

    test('creates precision loss exception', () {
      final exception = MathException.precisionLoss('divide', [10, 3]);
      expect(exception.operation, equals('divide'));
      expect(exception.operands, equals([10, 3]));
      expect(exception.message, equals('Operation resulted in precision loss'));
      expect(exception.code, equals('precision_loss'));
    });

    test('creates undefined result exception', () {
      final exception = MathException.undefinedResult('log', [0]);
      expect(exception.operation, equals('log'));
      expect(exception.operands, equals([0]));
      expect(
          exception.message, equals('Operation resulted in undefined value'));
      expect(exception.code, equals('undefined_result'));
    });

    test('creates invalid domain exception', () {
      final exception = MathException.invalidDomain('asin', [2]);
      expect(exception.operation, equals('asin'));
      expect(exception.operands, equals([2]));
      expect(
          exception.message, equals('Operation not defined for given domain'));
      expect(exception.code, equals('invalid_domain'));
    });

    test('creates not a number exception', () {
      final exception = MathException.notANumber('sqrt', [-1]);
      expect(exception.operation, equals('sqrt'));
      expect(exception.operands, equals([-1]));
      expect(exception.message, equals('Operation resulted in NaN'));
      expect(exception.code, equals('not_a_number'));
    });

    test('creates infinite result exception', () {
      final exception = MathException.infiniteResult('tan', [math.pi / 2]);
      expect(exception.operation, equals('tan'));
      expect(exception.operands, equals([math.pi / 2]));
      expect(exception.message, equals('Operation resulted in infinite value'));
      expect(exception.code, equals('infinite_result'));
    });

    test('formats toString without previous exception', () {
      final exception = MathException('add', [1, 2], 'Error message');
      expect(exception.toString(), equals('MathException: Error message'));
    });

    test('formats toString with previous exception', () {
      final previous = Exception('Previous error');
      final exception =
          MathException('add', [1, 2], 'Error message', null, previous);
      expect(
          exception.toString(),
          equals(
              'MathException: Error message\nCaused by: Exception: Previous error'));
    });
  });
}
