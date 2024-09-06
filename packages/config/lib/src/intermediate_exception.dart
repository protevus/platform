/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// An exception class used for intermediate error handling.
///
/// This class encapsulates an underlying exception and a key path,
/// allowing for more detailed error reporting in nested structures.
///
/// [underlying] is the original exception that was caught.
/// [keyPath] is a list representing the path to the error in a nested structure.
class IntermediateException implements Exception {
  /// Creates an [IntermediateException] with the given [underlying] exception and [keyPath].
  ///
  /// [underlying] is the original exception that was caught.
  /// [keyPath] is a list representing the path to the error in a nested structure.
  IntermediateException(this.underlying, this.keyPath);

  /// The original exception that was caught.
  ///
  /// This field stores the underlying exception that triggered the creation
  /// of this [IntermediateException]. It can be of any type, hence the
  /// [dynamic] type annotation.
  final dynamic underlying;

  /// A list representing the path to the error in a nested structure.
  ///
  /// This field stores the key path as a list of dynamic elements. Each element
  /// in the list represents a key or index in the nested structure, helping to
  /// pinpoint the exact location of the error.
  final List<dynamic> keyPath;
}
