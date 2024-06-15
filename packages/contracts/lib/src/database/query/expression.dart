// File path: lib/Illuminate/Contracts/Database/Query/expression.dart

import 'package:your_project/Illuminate/Database/grammar.dart';

abstract class Expression {
  /// Get the value of the expression.
  ///
  /// @param Grammar grammar
  /// @return String|int|double
  dynamic getValue(Grammar grammar);
}
