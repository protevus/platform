/// Exception thrown when a mathematical operation fails.
class MathException implements Exception {
  /// The operation that failed.
  final String operation;

  /// The operands involved in the failed operation.
  final List<dynamic> operands;

  /// The error message.
  final String message;

  /// The error code.
  final dynamic code;

  /// The previous exception that caused this one.
  final Exception? previous;

  /// Creates a new math exception.
  MathException(
    this.operation,
    this.operands, [
    String? message,
    this.code,
    this.previous,
  ]) : message = message ?? _buildMessage(operation, operands);

  /// Build a default error message.
  static String _buildMessage(String operation, List<dynamic> operands) {
    final operandsStr = operands.map((e) => e.toString()).join(', ');
    return 'Math operation "$operation" failed with operands: $operandsStr';
  }

  /// Creates a division by zero exception.
  factory MathException.divisionByZero([
    dynamic dividend,
    Exception? previous,
  ]) {
    return MathException(
      'division',
      [dividend, 0],
      'Division by zero',
      'division_by_zero',
      previous,
    );
  }

  /// Creates an overflow exception.
  factory MathException.overflow(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in overflow',
      'overflow',
      previous,
    );
  }

  /// Creates an underflow exception.
  factory MathException.underflow(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in underflow',
      'underflow',
      previous,
    );
  }

  /// Creates an invalid operand exception.
  factory MathException.invalidOperand(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Invalid operand for operation',
      'invalid_operand',
      previous,
    );
  }

  /// Creates a precision loss exception.
  factory MathException.precisionLoss(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in precision loss',
      'precision_loss',
      previous,
    );
  }

  /// Creates an undefined result exception.
  factory MathException.undefinedResult(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in undefined value',
      'undefined_result',
      previous,
    );
  }

  /// Creates an invalid domain exception.
  factory MathException.invalidDomain(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation not defined for given domain',
      'invalid_domain',
      previous,
    );
  }

  /// Creates a not a number exception.
  factory MathException.notANumber(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in NaN',
      'not_a_number',
      previous,
    );
  }

  /// Creates an infinite result exception.
  factory MathException.infiniteResult(
    String operation,
    List<dynamic> operands, [
    Exception? previous,
  ]) {
    return MathException(
      operation,
      operands,
      'Operation resulted in infinite value',
      'infinite_result',
      previous,
    );
  }

  @override
  String toString() {
    final base = 'MathException: $message';
    if (previous != null) {
      return '$base\nCaused by: $previous';
    }
    return base;
  }
}
