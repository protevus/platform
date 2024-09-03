/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async' as async;
import 'dart:core' as core;
import 'dart:core' hide Map, String, int;
import 'package:protevus_typeforge/cast.dart';

/// A cast operation that attempts to cast a dynamic value to either type S or type T.
///
/// This class extends [Cast<dynamic>] and provides a mechanism to attempt casting
/// to two different types in sequence. It first tries to cast to type S using the
/// [_left] cast, and if that fails, it attempts to cast to type T using the [_right] cast.
///
/// The [safeCast] method first attempts to use the [_left] cast. If it succeeds, the result
/// is returned. If it fails (by throwing a [FailedCast] exception), the method then
/// attempts to use the [_right] cast and returns its result.
///
/// This class is useful when you have a value that could be one of two different types
/// and you want to handle both cases.
///
/// Usage:
/// ```dart
/// final oneOfCast = OneOf(IntCast(), StringCast());
/// final resultInt = oneOfCast.cast(42); // Returns 42 as int
/// final resultString = oneOfCast.cast("hello"); // Returns "hello" as String
/// oneOfCast.cast(true); // Throws FailedCast
/// ```
class OneOf<S, T> extends Cast<dynamic> {
  final Cast<S> _left;
  final Cast<T> _right;
  const OneOf(Cast<S> left, Cast<T> right)
      : _left = left,
        _right = right;
  @override
  dynamic safeCast(dynamic from, core.String context, dynamic key) {
    try {
      return _left.safeCast(from, context, key);
    } on FailedCast {
      return _right.safeCast(from, context, key);
    }
  }
}

/// A cast operation that applies a transformation function after casting to an intermediate type.
///
/// This class extends [Cast<T>] and combines two operations:
/// 1. Casting the input to type S using the [_first] cast operation.
/// 2. Applying a transformation function [_transform] to convert the result from S to T.
///
/// [S] is the intermediate type after the first cast.
/// [T] is the final type after applying the transformation.
///
/// The [safeCast] method first uses [_first] to cast the input to type S,
/// then applies [_transform] to convert the result to type T.
///
/// This class is useful when you need to perform a cast followed by a type conversion
/// or when you want to apply some transformation logic after casting.
///
/// Usage:
/// ```dart
/// final stringLengthCast = Apply<String, int>((s) => s.length, StringCast());
/// final result = stringLengthCast.cast("hello"); // Returns 5
/// ```
class Apply<S, T> extends Cast<T> {
  final Cast<S> _first;
  final T Function(S) _transform;
  const Apply(T Function(S) transform, Cast<S> first)
      : _transform = transform,
        _first = first;
  @override
  T safeCast(dynamic from, core.String context, dynamic key) =>
      _transform(_first.safeCast(from, context, key));
}

/// A cast operation for converting dynamic values to [async.Future<E>].
///
/// This class extends [Cast<async.Future<E>>] and implements the [safeCast] method
/// to perform type checking and conversion to [async.Future<E>].
///
/// The class uses a [Cast<E>] instance [_value] for casting the value inside the Future to type E.
///
/// The [safeCast] method checks if the input [from] is already an [async.Future].
/// If it is, it returns a new Future that applies the [_value] cast to the result of the original Future.
/// If not, it throws a [FailedCast] exception with appropriate context information.
///
/// Usage:
/// ```dart
/// final futureCast = Future(IntCast());
/// final result = futureCast.cast(Future.value(42)); // Returns Future<int>
/// futureCast.cast("not a future"); // Throws FailedCast
/// ```
class Future<E> extends Cast<async.Future<E>> {
  final Cast<E> _value;
  const Future(Cast<E> value) : _value = value;
  @override
  async.Future<E> safeCast(dynamic from, core.String context, dynamic key) {
    if (from is async.Future) {
      return from.then(_value.cast);
    }
    return throw FailedCast(context, key, "not a Future");
  }
}
