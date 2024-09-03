/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:core' as core;
import 'dart:core' hide Map, String, int;
import 'package:protevus_typeforge/cast.dart';

/// A cast operation for converting dynamic values to [core.int].
///
/// This class extends [Cast<core.int>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.int].
///
/// The [safeCast] method checks if the input [from] is already a [core.int].
/// If it is, it returns the value unchanged. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final intCast = IntCast();
/// final result = intCast.cast(42); // Returns 42
/// intCast.cast("not an int"); // Throws FailedCast
/// ```
class IntCast extends Cast<core.int> {
  const IntCast();
  @override
  core.int safeCast(dynamic from, core.String context, dynamic key) =>
      from is core.int
          ? from
          : throw FailedCast(context, key, "$from is not an int");
}

/// A cast operation for converting dynamic values to [core.double].
///
/// This class extends [Cast<core.double>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.double].
///
/// The [safeCast] method checks if the input [from] is already a [core.double].
/// If it is, it returns the value unchanged. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final doubleCast = DoubleCast();
/// final result = doubleCast.cast(3.14); // Returns 3.14
/// doubleCast.cast("not a double"); // Throws FailedCast
/// ```
class DoubleCast extends Cast<core.double> {
  const DoubleCast();
  @override
  core.double safeCast(dynamic from, core.String context, dynamic key) =>
      from is core.double
          ? from
          : throw FailedCast(context, key, "$from is not an double");
}

/// A cast operation for converting dynamic values to [core.String].
///
/// This class extends [Cast<core.String>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.String].
///
/// The [safeCast] method checks if the input [from] is already a [core.String].
/// If it is, it returns the value unchanged. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final stringCast = StringCast();
/// final result = stringCast.cast("Hello"); // Returns "Hello"
/// stringCast.cast(42); // Throws FailedCast
/// ```
class StringCast extends Cast<core.String> {
  const StringCast();
  @override
  core.String safeCast(dynamic from, core.String context, dynamic key) =>
      from is core.String
          ? from
          : throw FailedCast(context, key, "$from is not a String");
}

/// A cast operation for converting dynamic values to [core.bool].
///
/// This class extends [Cast<core.bool>] and implements the [safeCast] method
/// to perform type checking and conversion to [core.bool].
///
/// The [safeCast] method checks if the input [from] is already a [core.bool].
/// If it is, it returns the value unchanged. If not, it throws a [FailedCast]
/// exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final boolCast = BoolCast();
/// final result = boolCast.cast(true); // Returns true
/// boolCast.cast("not a bool"); // Throws FailedCast
/// ```
class BoolCast extends Cast<core.bool> {
  const BoolCast();
  @override
  core.bool safeCast(dynamic from, core.String context, dynamic key) =>
      from is core.bool
          ? from
          : throw FailedCast(context, key, "$from is not a bool");
}
