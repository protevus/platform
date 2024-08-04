/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/cast.dart';

/// A constant instance of [AnyCast] that can be used for casting any dynamic value.
///
/// This constant provides a convenient way to use the [AnyCast] functionality
/// without needing to create a new instance each time. It can be used in situations
/// where type-checking is not required, and you want to allow any type to pass through.
///
/// Example usage:
/// ```dart
/// final result = any.cast(someValue); // Returns someValue unchanged, regardless of its type
/// ```
const any = AnyCast();

/// A constant instance of [BoolCast] that can be used for casting dynamic values to [core.bool].
///
/// This constant provides a convenient way to use the [BoolCast] functionality
/// without needing to create a new instance each time. It can be used to perform
/// boolean type checking and casting operations.
///
/// Example usage:
/// ```dart
/// final result = bool.cast(true); // Returns true
/// bool.cast("not a bool"); // Throws FailedCast
/// ```
const bool = BoolCast();

/// A constant instance of [IntCast] that can be used for casting dynamic values to [core.int].
///
/// This constant provides a convenient way to use the [IntCast] functionality
/// without needing to create a new instance each time. It can be used to perform
/// integer type checking and casting operations.
///
/// Example usage:
/// ```dart
/// final result = int.cast(42); // Returns 42
/// int.cast("not an int"); // Throws FailedCast
/// ```
const int = IntCast();

/// A constant instance of [DoubleCast] that can be used for casting dynamic values to [core.double].
///
/// This constant provides a convenient way to use the [DoubleCast] functionality
/// without needing to create a new instance each time. It can be used to perform
/// double type checking and casting operations.
///
/// Example usage:
/// ```dart
/// final result = double.cast(3.14); // Returns 3.14
/// double.cast("not a double"); // Throws FailedCast
/// ```
const double = DoubleCast();

/// A constant instance of [StringCast] that can be used for casting dynamic values to [core.String].
///
/// This constant provides a convenient way to use the [StringCast] functionality
/// without needing to create a new instance each time. It can be used to perform
/// string type checking and casting operations.
///
/// Example usage:
/// ```dart
/// final result = string.cast("Hello"); // Returns "Hello"
/// string.cast(42); // Throws FailedCast
/// ```
const string = StringCast();
