/// Interface for database query expressions.
///
/// This contract defines how raw SQL expressions should be handled.
abstract class Expression {
  /// Get the value of the expression.
  dynamic getValue(dynamic grammar);
}
